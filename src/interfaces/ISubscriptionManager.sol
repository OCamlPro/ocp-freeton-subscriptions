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
    
    // Views
    
    function getOwner() external view returns(address);
    // Returns the owner of the manager

    function getWallet() external view returns(address);
    // Returns the address of the wallet ; 0 if there is no address

    function isTIP3Compatible(address) external view returns(bool);
    // Returns [true] if the subscription can be done with the TIP3
    // whose root wallet is the argument; [false] otherwise.

    function getSubscription(address) external view returns(Payment);
    // Returns the subscription details of the subscriber address 
    // in argument

    // Entry points

    function subscribe(Payment, bool) external; 
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