pragma ton-solidity >=0.44.0;
pragma AbiHeader time;
pragma AbiHeader expire;

import "IConstants.sol";

// The Service List, saving the services of a given provider
interface IServiceList is IConstants {

    // Returns the information of the services deployed by a provider
    function getServices() external view returns(ServiceInfo[] services);

}