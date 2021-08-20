pragma ton-solidity ^0.44.0;
pragma AbiHeader time;
pragma AbiHeader expire;

import "IConstants.sol";

// Subscription managers holds the owner address.
// They can deploy two kind of contracts:
// - The subscription contracts (ISubscription)
// - The PaymentPlan contracts (IPaymentPlans)
interface ISubscriptionManager is IConstants {

    // address static s_owner; 
    // Owner of the manager

    // address static s_wallet;
    // The wallet of the manager

    // address[] m_subscriptions;
    // Subscriptions (TODO: remove)
    
    // Views
    
    function getOwner() external view returns(address);
    // Returns the owner of the manager

    function getWallet() external view returns(address);
    // Returns the address of the owner wallet

    function getSubscriptions() external view returns(address);
    // Return subscriptions (TODO: remove)

    // Entry points

    function subscribe() external; 
    // Starts a new subscription or extends one.

    function pause() external; 
    // Pauses the subscription of the subscriber
    // Can only be called by the subscriber
    
    function resume() external;
    // Resumes a paused the subscription 
    // Can only be called by the subscriber

    function cancel() external;
    // Cancels the current subscription 
    // Can only be called by the subscriber
}