pragma ton-solidity ^0.44.0;
pragma AbiHeader time;
pragma AbiHeader expire;

import "IConstants.sol";
import "IWallet.sol";
import "IBuildable.sol";

// Subscriptions are storage of the Subscription Manager contract.
// They hold the payment information.
// A subscription is specific to a user. A subscription starts when the
// contract is built or when it calls the 'start' method.
interface ISubscription is IConstants, IBuildable {

    // address static s_manager;
    
    // address static s_subscriber;
    
    // IWallet static s_wallet;

    // Payment m_subscription;

    // uint128 m_until;

    // bool m_paused;

    // Views

    function getManager() external view responsible returns(address);
    function getSubscriber() external view responsible returns(address);
    function getWallet() external view responsible returns(address);
    function getStart() external view responsible returns(uint128);
    function subscribedUntil() external view responsible returns(uint128);

    // Entry points

    function refillAccount(uint128) external; 
    // Fills the subscription wallet and starts the subscription if 
    // there is enough funds.

    function cancelSubscription() external;
    // Cancels the current subscription.

    //function subscriberClaim(uint128) external;
    // Claims the amount in argument from the wallet.

    function providerClaim() external;
    // Claims all the funds available for the subscription
    // and update the 'start date' of the subscription

}