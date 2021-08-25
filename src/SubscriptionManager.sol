pragma ton-solidity ^0.44.0;
pragma AbiHeader time;
pragma AbiHeader expire;

import "interfaces/ISubscriptionManager.sol";
import "interfaces/IWallet.sol";
import "Constants.sol";
import "SubscriptionBuilder.sol";
import "WalletBuilder.sol";

// Subscription Managers are the services from which you can subscribe.
contract SubscriptionManager is ISubscriptionManager, Constants, Buildable {

    uint64 static s_id;
    // Unique ID for the subscription manager

    address static s_service_provider;
    // Service provider
    
    address static s_wallet;
    // The wallet of the manager

    SubscriptionBuilder c_sub_builder;
    // Subscription builder

    WalletBuilder c_wal_builder;
    // Wallet builder

    PaymentPlan c_payment_plan;
    // The payment plan
    // TODO: multiple payment plans

    event SubscriptionComplete(address subscriber, address subscription, address wallet);

    mapping(address => Subscription) m_subscriptions;
    // Subscriptions (TODO: remove)
    
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
    function getSubscription(address subscriber) override external view returns(address){
        return m_subscriptions[subscriber];
    }

    // Entry points

    // Starts a new subscription.
    function subscribe(address subscriber) override external{
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

    // TODO: service provider payment

    //// Pauses the subscription 
    //// Can only be called by the subscriber
    //function pause() override external{
    //    require(false);
    //}
    
    //// Resumes a paused the subscription 
    //// Can only be called by the subscriber
    //function resume() override external{
    //    require(false);
    //}

    //// Cancels the current subscription 
    //// Can only be called by the subscriber
    //function cancel() override external{
    //    require(false);
    //}
}