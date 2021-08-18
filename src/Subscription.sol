pragma ton-solidity ^0.44.0;
pragma AbiHeader time;
pragma AbiHeader expire;

import "interfaces/ISubscription.sol";
import "Constants.sol";

contract Subscription is ISubscription, Constants {

    address static s_manager;
    
    address static s_subscriber;
    
    Payment m_latest;

    constructor() public{
        require(false);
    }

    // Views

    function getManager() override external view responsible returns(address){
        return s_manager;
    }

    function getSubscriber() override external view responsible returns(address){
        return s_subscriber;
    }

    // Returns the current payment info of this subscription
    function getSubscriptionInfo() override external responsible returns(Payment){
        require(false);
    }

    // Entry points

    // Starts a new subscription or extends the current one.
    // Can only be called by the manager
    function start(Payment) override external{
        require(false);
    }

    // Pauses the subscription 
    // Can only be called by the manager & the subscriber
    function pause() override external{
        require(false);
    }
    
    // Resumes the subscription 
    // Can only be called by the manager & the subscriber
    function resume() override external{
        require(false);
    }

    // Cancels the current subscription 
    // Can only be called by the manager & the subscriber
    function cancel() override external{
        require(false);
    }
}