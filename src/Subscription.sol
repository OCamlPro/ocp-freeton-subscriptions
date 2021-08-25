pragma ton-solidity ^0.44.0;
pragma AbiHeader time;
pragma AbiHeader expire;

import "interfaces/ISubscription.sol";
import "interfaces/IWallet.sol";
import "Constants.sol";
import "Buildable.sol";

contract Subscription is ISubscription, Constants, Buildable {

    address static s_manager; // The subscription manager
    address static s_service_provider; // The service provider
    address static s_subscriber; // The user

    PaymentPlan c_payment_plan; // The payment plan (constant)
    IWallet c_wallet; // The wallet associated to the subscription (constant)
    
    uint128 m_wallet_balance; // The wallet balance
    uint128 m_start; // The start of the subscription
    //uint128 m_paused; // !=0 -> Subscription has been paused at `m_paused`
    //uint32  m_skipped; // Skipped payments due to pausing

    optional(uint128) m_expected_start; // Used by ownerClaim: if claim succeeds, will replace m_start

    event Manager(address);
    event Subscriber(address);
    event Wallet(address);
    event Start(uint128);
    event LockedFunds(uint128);
    event SubscribedUntil(uint128);
    event WalletBalance(uint128);


    constructor(PaymentPlan p, address wallet) public{
        tvm.accept();
        c_payment_plan = p;
        c_wallet = IWallet(wallet);
        m_wallet_balance = 0;
        m_start = now;
    }

    // Views

    function getManager() override external view responsible returns(address){
        emit Manager(s_manager);
        return s_manager;
    }

    function getSubscriber() override external view responsible returns(address){
        emit Subscriber(s_subscriber);
        return s_subscriber;
    }

    function getWallet() override external view responsible returns(address){
        emit Wallet(c_wallet);
        return address(c_wallet);
    }

    function getStart() override external view responsible returns(uint128){
        emit Start(m_start);
        return m_start;
    }

    function _numberOfTicksLocked() internal view returns(uint128){
        uint128 number_of_ticks_until_now;
        uint128 number_of_ticks_payable;
        uint128 number_of_ticks_locked;

        require (now >= m_start, E_INVARIANT_BROKEN);
        
        if (now == m_start) {
            number_of_ticks_until_now = 0;
        } else {
            number_of_ticks_until_now = ((now - m_start) / c_payment_plan.period) + 1;
        }

        number_of_ticks_payable = m_wallet_balance / c_payment_plan.amount;

        if (number_of_ticks_until_now <= number_of_ticks_payable) {
            number_of_ticks_locked = number_of_ticks_until_now;
        } else {
            number_of_ticks_locked = number_of_ticks_payable;
        }

        return number_of_ticks_locked;
    }

    function lockedFunds() public view responsible returns(uint128){
        uint128 res = _numberOfTicksLocked() * c_payment_plan.amount;
        return res;
    
    }

    function subscribedUntil() override public view responsible returns(uint128) {
        uint128 res = m_start + _numberOfTicksLocked() * c_payment_plan.period;
        emit Start(m_start);
        emit SubscribedUntil(res);
        return res;
    }


    // Entry points

    function refillAccount(uint128 expected_gas) override external {
        tvm.accept();
        c_wallet.transfer{
            value:msg.value - expected_gas,
            flag:0,
            callback:this.onRefillAccount
        }();
    }

    function onRefillAccount(uint128 wallet_balance) external onlyFrom(address(c_wallet)){
        tvm.accept();
        // Now using the 'expected_gas' from the refillAccount call.
        emit WalletBalance(wallet_balance);
        uint128 locked = lockedFunds();

        if (locked > 0) {
            c_wallet.transferToCallback{
                value:0, 
                flag:64, 
                callback:this.onOnRefillAccount
            }(s_service_provider,int128(locked));
        } else {
            onOnRefillAccount(wallet_balance);
        }

    }

    function onOnRefillAccount(uint128 wallet_balance) public onlyFrom(address(c_wallet)){
        m_wallet_balance = wallet_balance;
        if (now > subscribedUntil()) {
            // Subscription stopped at some point.
            // If there is now enough funds to start a new subscription,
            // we have to update m_start
            if (wallet_balance >= c_payment_plan.amount){
                m_start = now;
            }
        }
        s_subscriber.transfer(0,false,128); // The remaining "gas" from expected_gas
    }

    function cancelSubscription() override external onlyFrom(s_subscriber){
        tvm.accept();
        int128 locked = -1 * int128(lockedFunds());
        c_wallet.transferTo{value:0, flag:64}(s_subscriber, locked);
    }

    function providerClaim() override external {
        
        tvm.accept();
        uint128 locked_ticks = _numberOfTicksLocked();
        if (locked_ticks == 0) { 
               s_service_provider.transfer(0,false,128);
        } else {
            m_expected_start.set(m_start + locked_ticks * c_payment_plan.period); 
            // Value will be used on onProviderClaim

            c_wallet.transferTo{
                value:0.1 ton, 
                flag:0
            }
            (s_service_provider,int128(locked_ticks * c_payment_plan.amount));

            c_wallet.balance{value:0,flag:128,callback:this.onProviderClaim}();
        }

    }

    function onProviderClaim(uint128 balance) external onlyFrom(address(c_wallet)) {
        
        m_wallet_balance = balance;
        
        // This condition is important if two calls of providerClaim
        // are sent simultaneously : the second one would fail otherwise
        if (m_expected_start.hasValue()){
            m_start = m_expected_start.get();
            m_expected_start.reset();
        }        
    }
}