pragma ton-solidity >=0.44.0;
pragma AbiHeader time;
pragma AbiHeader expire;

import "interfaces/ISubscriptionManager.sol";
import "interfaces/IWallet.sol";
import "Constants.sol";
import "SubscriptionBuilder.sol";
import "WalletBuilder.sol";

// Subscription Managers are the Services from which you can subscribe.
contract SubscriptionManager is ISubscriptionManager, Constants, Buildable {

    uint64 static s_id;
    // Unique ID for the subscription manager

    address static s_service_provider;
    // Service provider
    
    address static s_wallet;
    // The wallet of the manager

    string static s_description;
    // The description of the service

    SubscriptionBuilder c_sub_builder;
    // Subscription builder

    WalletBuilder c_wal_builder;
    // Wallet builder

    PaymentPlan c_payment_plan;
    // The payment plan
    // TODO: multiple payment plans

    event SubscriptionComplete(address subscriber, address subscription, address wallet);

    mapping(address => Subscription) m_subscriptions;
    // Subscriptions
    // This should not be in the contract, as it is only useful for
    // claiming all due subscriptions, which can be done outside the blockchain
    // TODO: decentralized mapping
    
    constructor(address sub_builder_address, address wal_builder_address, PaymentPlan pplan) public {
        tvm.accept();
        c_sub_builder = SubscriptionBuilder(sub_builder_address);
        c_wal_builder = WalletBuilder(wal_builder_address);
        c_payment_plan = pplan;
    }


    // Views
    
    function getProvider() override external view returns(address){
        return s_service_provider;
    }
    // Returns the owner of the manager


    // Returns the address of the wallet
    function getWallet() override external view returns(address){
        return s_wallet;
    }

    // Returns the subscription details of the subscriber address 
    // in argument
    function getSubscription(address subscriber) override external view returns(address value){
        if (m_subscriptions.exists(subscriber)){
            value = m_subscriptions[subscriber];
        } else {
            value = address(0);
        }
    }

    function getDescription() override external view returns(string description){
        description = s_description;
    }

    // Entry points

    // Starts a new subscription.
    function subscribe(address subscriber) override external{
        require (!m_subscriptions.exists(subscriber), E_ALREADY_SUBSCRIBED);
        tvm.accept();
        c_wal_builder.deploy{
            value:0, 
            flag:128, 
            callback: this.onWalletDeploy
        } (subscriber);
    }

    function onWalletDeploy(address subscriber, address wallet) external view {
        require(msg.sender == address(c_wal_builder), E_UNAUTHORIZED);
        c_sub_builder.deploy{
            value:0,
            flag:128,
            callback:this.onSubscriptionDeploy
        }(
        wallet,
        address(this), 
        s_service_provider, 
        subscriber,
        c_payment_plan);
    }

    function onSubscriptionDeploy(address subscriber, address subscription, address wallet) external {
        require(msg.sender == address(c_sub_builder), E_UNAUTHORIZED);
        m_subscriptions.add(subscriber, Subscription(subscription));
        emit SubscriptionComplete(subscriber, subscription, wallet);
        IWallet(wallet).init{value:0, flag:128}(subscription);
    }

    // Claims all the subscriptions
    function claimSubscriptions() external override {
        tvm.accept();
        for(( ,Subscription s) : m_subscriptions) {
            s.providerClaim{value:0.035 ton}();
        }
        s_service_provider.transfer(0,false,128);
    }
}

// 11 - 11 - cf663cf172a6497775386e80cd1eba98884e2dbb37f63824be0cc456369ee81b