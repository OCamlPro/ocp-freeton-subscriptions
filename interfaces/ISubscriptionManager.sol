pragma solidity >=0.5.0;
pragma AbiHeader time;
pragma AbiHeader expire;

// Subscriptions
interface ISubscriptionManager is IConstants {

    address static s_wallet; // Wallet to which transfer funds
    address static s_owner; // Owner of the manager

    // Views

    function getWallet() external view returns(address);
    
    function getOwner() external view returns(address);

    function getSubscription(address) external view returns(Payment);

    // Entry points

    function subscribe(Payment) external; 
    // Starts a new subscription or extends one.

    function pause() external; 
    // Pauses the subscription 
    // Can only be called by the subscriber
    
    function resume() external;
    // Resumes a paused the subscription 
    // Can only be called by the subscriber

    function cancel() external;
    // Cancels the current subscription 
    // Can only be called by the subscriber
}