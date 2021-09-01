pragma ton-solidity >=0.44.0;
pragma AbiHeader time;
pragma AbiHeader expire;

interface IServiceListBuilder {

    // Returns the address of the service list
    function getServicesList(address provider) external view returns(address list);

}