pragma solidity >=0.5.0;
pragma AbiHeader time;
pragma AbiHeader expire;

// Subscriptions are storage of the Subscription Manager contract.
// They hold the payment information.
// A subscription is specific to a user. A subscription starts when the
// contract is built or when it calls the 'start' method.
interface ISubscription is IConstants {

    address static s_manager;
    address static s_subscriber;
    Payment m_latest;

    // Views

    function getManager() external view responsible returns(address);
    function getSubscriber() external view responsible returns(address);
    function getSubscriptionInfo() external view responsible returns(Payment);


    // Entry points

    function start(Payment) external; 
    // Starts a new subscription or extends the current one.
    // Can only be called by the manager

    function pause() external; 
    // Pauses the subscription 
    // Can only be called by the manager & the subscriber
    
    function resume() external;
    // Resumes the subscription 
    // Can only be called by the manager & the subscriber

    function cancel() external;
    // Cancels the current subscription 
    // Can only be called by the manager & the subscriber
}