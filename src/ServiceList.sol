pragma ton-solidity >=0.44.0;
pragma AbiHeader time;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "interfaces/IRecurringPaymentsRoot.sol";
import "interfaces/ISubscriptionManager.sol";

import "Constants.sol";
import "Buildable.sol";

// The Root contract, allowing to deploy services
contract ServiceList is Constants, Buildable {
    address static s_service_provider;
    address static s_root;
    address static s_deployer;

    address[] m_services;
    
    constructor(uint64) public {
        tvm.accept();
        address[] serv;
        m_services = serv;
    }

    function addService(address service) public {
        require (msg.sender == s_deployer, E_UNAUTHORIZED);
        m_services.push(service);
        IRecurringPaymentsRoot(s_root).onAddService{value:0, flag:128}(s_service_provider,service);
    }

    function getServices() public view responsible returns(address[]) {
        return {value:0, flag:128} m_services;
    }
}

