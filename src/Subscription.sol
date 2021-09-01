pragma ton-solidity >=0.44.0;
pragma AbiHeader time;
pragma AbiHeader expire;

import "interfaces/ISubscription.sol";
import "interfaces/IWallet.sol";
import "Constants.sol";
import "Buildable.sol";

// A subscription is an interface between the Wallet, the service provider
// and the subscriber.
contract Subscription is ISubscription, Constants, Buildable {

    address static s_manager; // The subscription manager
    address static s_service_provider; // The service provider
    address static s_subscriber; // The user
    uint64 static s_id; // A unique ID

    PaymentPlan c_payment_plan; // The payment plan (constant)
    IWallet c_wallet; // The wallet associated to the subscription (constant)
    
    uint128 m_wallet_balance; // The wallet balance
    uint128 m_start; // The start of the first subscription due to the service provider
    //uint128 m_paused; // !=0 -> Subscription has been paused at `m_paused`
    //uint32  m_skipped; // Skipped payments due to pausing

    optional(uint128) m_expected_start; // Used by ownerClaim: if claim succeeds, will replace m_start

    // Some events (mostly for debugging)
    event Manager(address);
    event Subscriber(address);
    event Wallet(address);
    event Start(uint128);
    event LockedFunds(uint128);
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
        require(msg.value >= 0.001 ton, E_INVALID_AMOUNT);
        tvm.accept();
        emit Manager(s_manager);
        return s_manager;
    }

    function getSubscriber() override external view responsible returns(address){
        require(msg.value >= 0.001 ton, E_INVALID_AMOUNT);
        tvm.accept();
        emit Subscriber(s_subscriber);
        return s_subscriber;
    }

    function getWallet() override external view responsible returns(address){
        require(msg.value >= 0.001 ton, E_INVALID_AMOUNT);
        tvm.accept();
        emit Wallet(c_wallet);
        return address(c_wallet);
    }

    function getStart() override external view responsible returns(uint128){
        require(msg.value >= 0.001 ton, E_INVALID_AMOUNT);
        tvm.accept();
        emit Start(m_start);
        return m_start;
    }

    function getBalance() external view responsible returns(uint128){
        require(msg.value >= 0.001 ton, E_INVALID_AMOUNT);
        tvm.accept();
        emit WalletBalance(m_wallet_balance);
        return m_wallet_balance;
    }

    // A `tick` is defined as a subscription period.
    // A `tick` is said to be `locked` if the user subscribed to its 
    // corresponding period. 

    // Returns the number of locked ticks.
    // It is equals to the min of the number of ticks payable
    // and the number of ticks from m_start.
    function _numberOfTicksLocked() internal view returns(uint128){
        uint128 number_of_ticks_until_now;
        uint128 number_of_ticks_payable;
        uint128 number_of_ticks_locked;

        if (now <= m_start) {
            number_of_ticks_until_now = 0;
        } else {
            // now > m_start
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

    // Returns the locked funds, i.e. the funds the subscriber has lost access to.
    function lockedFunds() public view responsible returns(uint128){
        uint128 res = _numberOfTicksLocked() * c_payment_plan.amount;
        return {value:0, flag:64} res;
    }

    // Returns the end of the last period the user subscribed to
    function subscribedUntil() override external view returns(uint128 end) {
        end = pubSubscribedUntil();
    }

    function pubSubscribedUntil() public view returns(uint128 end) {
        end = m_start + _numberOfTicksLocked() * c_payment_plan.period;
    }


    // Entry points

    // Refills the wallet with the value of the message.
    // The `expected_gas` argument is deduced from the transfer ; it
    // will be used as the gas for the rest of the execution and refund 
    // to the user.
    function refillAccount(uint128 expected_gas) override external {
        require (expected_gas >= 0.01 ton, E_INVALID_AMOUNT);
        // 0.01 is enough for the rest of the execution
        require (c_payment_plan.root_token == address(0), E_NOT_CALLABLE_IF_TIP3);
        tvm.accept();

        c_wallet.transfer{
            value:msg.value - expected_gas,
            flag:0,
            callback:this.onRefillAccount
        }();
    }

    // Continuation of refill.
    // If there has been locked funds so far, transfering it to the service provider
    // Otherwise, calling continuation `onOnRefillAccount`
    function onRefillAccount(uint128 wallet_balance) external {
        require(msg.sender == address(c_wallet), E_UNAUTHORIZED);
        tvm.accept();
        // Now using the 'expected_gas' from the refillAccount call.
        emit WalletBalance(wallet_balance);

        uint128 locked = lockedFunds();
        // m_wallet_balance has not been updated yet 
        // => locked = funds locked before refill.

        if (locked > 0) {
            // There were some funds locked from a previous subscription
            // Paying them now
            c_wallet.transferToCallback{
                value:0, 
                flag:128, 
                callback:this.onOnRefillAccount
            }(s_service_provider,int128(locked));
        } else {
            onOnRefillAccount(wallet_balance);
        }
    }

    // Continuation of `onRefillAccount`.
    // Updates the current balance & the timestamp of the subscription
    function onOnRefillAccount(uint128 wallet_balance) public {
        require(msg.sender == address(c_wallet), E_UNAUTHORIZED);
        m_wallet_balance = wallet_balance;
        if (now > pubSubscribedUntil()) {
            // Subscription stopped at some point.
            // If there is now enough funds to start a new subscription,
            // we have to update m_start
            if (wallet_balance >= c_payment_plan.amount){
                m_start = now;
            }
        }
        s_subscriber.transfer(0,false,128); // The remaining "gas" from expected_gas
    }

    // Cancels a subscription & refunds the subscriber of all the unlocked funds
    function cancelSubscription() override external {
        require(msg.sender == s_subscriber, E_UNAUTHORIZED);
        tvm.accept();
        int128 locked = -1 * int128(lockedFunds());
        c_wallet.transferTo{value:0, flag:128}(s_subscriber, locked);
    }

    // Transfers the locked funds to the service provider
    function providerClaim() override external {
        require (msg.value >= 0.03 ton, E_INVALID_AMOUNT);
        // Guarantees the proper execution of providerClaim & its continuation
        tvm.accept();

        if (m_expected_start.hasValue()){
            // Prevents two simultaneous claims 
            c_wallet.balance{value:0,flag:128,callback:this.onProviderClaim}();
        } else {
            uint128 locked_ticks = _numberOfTicksLocked();
            if (locked_ticks == 0) { 
                s_service_provider.transfer(0,false,128);
            } else {
                m_expected_start.set(m_start + locked_ticks * c_payment_plan.period); 
                // Value will be used on onProviderClaim

                c_wallet.transferTo{
                    value:0.01 ton, 
                    flag:0
                }
                (s_service_provider,int128(locked_ticks * c_payment_plan.amount));

                c_wallet.balance{value:0,flag:128,callback:this.onProviderClaim}();
            }
        }
    }

    function onProviderClaim(uint128 balance) external {
        
        require(msg.sender == address(c_wallet), E_UNAUTHORIZED);
        m_wallet_balance = balance;
        
        // This condition is important if two calls of providerClaim
        // are sent simultaneously : the second one would fail otherwise
        if (m_expected_start.hasValue()){
            m_start = m_expected_start.get();
            m_expected_start.reset();
        }

        s_service_provider.transfer(0,false,128);
    }
}
