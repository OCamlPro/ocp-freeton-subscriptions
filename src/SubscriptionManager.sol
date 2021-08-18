pragma ton-solidity ^0.44.0;
pragma AbiHeader time;
pragma AbiHeader expire;

import "interfaces/ISubscriptionManager.sol";
import "Constants.sol";

contract SubscriptionManager is ISubscriptionManager, Constants {

    address static s_owner; // Owner of the manager
    // Owner of the manager
    
    constructor() public{
        require(false);
    }

    // Views
    
    function getOwner() override external view returns(address){
        return s_owner;
    }
    // Returns the owner of the manager


    // Returns the address of the wallet ; 0 if there is no address
    function getWallet() override external view returns(address){
        require(false);
    }

    // Returns [true] if the subscription can be done with the TIP3
    // whose root wallet is the argument; [false] otherwise.
    function isTIP3Compatible(address) override external view returns(bool){
        require(false);
    }

    // Returns the subscription details of the subscriber address 
    // in argument
    function getSubscription(address) override external view returns(Payment){
        require(false);
    }

    // Entry points

    // Starts a new subscription or extends one.
    function subscribe(Payment, bool) override external{
        require(false);
    } 

    // Pauses the subscription 
    // Can only be called by the subscriber
    function pause() override external{
        require(false);
    }
    
    // Resumes a paused the subscription 
    // Can only be called by the subscriber
    function resume() override external{
        require(false);
    }

    // Cancels the current subscription 
    // Can only be called by the subscriber
    function cancel() override external{
        require(false);
    }
}