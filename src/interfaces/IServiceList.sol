pragma ton-solidity >=0.44.0;
pragma AbiHeader time;
pragma AbiHeader expire;

import "IConstants.sol";

// The Root contract, allowing to deploy services
interface IServiceList is IConstants {

    function getServices() external view returns(ServiceInfo[] services);

}