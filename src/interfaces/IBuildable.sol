pragma ton-solidity >=0.44;

// A small contract to inherit for sharing one's own code

interface IBuildable {

    // Returns the code of the contract
    function thisIsMyCode() external responsible returns(TvmCell);

}