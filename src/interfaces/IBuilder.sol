pragma ton-solidity >=0.44;

// THe basis of a contract deploying contracts
interface IBuilder {

    // Initializes the globals of the contract
    function init() external view;

    // Sets the code of the contract to build
    function updateCode(TvmCell c) external;

}