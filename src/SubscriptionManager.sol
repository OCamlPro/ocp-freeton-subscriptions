pragma ton-solidity ^0.44.0;
pragma AbiHeader time;
pragma AbiHeader expire;

import "interfaces/ISubscriptionManager.sol";
import "Constants.sol";

contract SubscriptionManager is ISubscriptionManager, Constants {

    address static s_owner; // Owner of the manager
    // Owner of the manager
    
    address static s_wallet;
    // The wallet of the manager

    address[] m_subscriptions;
    // Subscriptions (TODO: remove)
    
    constructor() public{
        require(false);
    }

    // Views
    
    function getOwner() override external view returns(address){
        return s_owner;
    }
    // Returns the owner of the manager


    // Returns the address of the wallet
    function getWallet() override external view returns(address){
        return s_wallet;
    }


    // Returns the subscription details of the subscriber address 
    // in argument
    function getSubscriptions(address) override external view returns(address[]){
        return m_subscriptions;
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