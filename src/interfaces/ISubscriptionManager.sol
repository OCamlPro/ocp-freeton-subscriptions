pragma ton-solidity >=0.44.0;
pragma AbiHeader time;
pragma AbiHeader expire;

import "IConstants.sol";

// Subscription managers holds the owner address.
// They can deploy two kind of contracts:
// - The subscription contracts (ISubscription)
// - The PaymentPlan contracts (IPaymentPlans)
interface ISubscriptionManager is IConstants {
    
    // Views
    
    function getProvider() external view returns(address);
    // Returns the owner of the manager

    function getWallet() external view returns(address);
    // Returns the address of the owner wallet

    function getSubscription(address) external view returns(address value);
    // Return subscriptions

    function getDescription() external view returns(string description);
    // Returns the description of the service

    // Entry points

    function subscribe(address) external; 

    function claimSubscriptions() external;
    // Starts a new subscription.

}
