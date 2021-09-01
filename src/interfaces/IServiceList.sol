pragma ton-solidity >=0.44.0;
pragma AbiHeader time;
pragma AbiHeader expire;

// The Root contract, allowing to deploy services
interface IServiceList {

    function getServices() external view returns(address[] services);

}