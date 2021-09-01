pragma ton-solidity >=0.44.0;
pragma AbiHeader time;
pragma AbiHeader expire;

// The Root contract, allowing to deploy services
interface IServiceListBuilder {

    function getServicesList(address provider) external view returns(address list);

}