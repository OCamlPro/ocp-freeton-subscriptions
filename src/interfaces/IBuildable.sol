pragma ton-solidity >=0.44;

// A small contract to inherit for sharing one's own code

interface IBuildable {
    function thisIsMyCode() external responsible returns(TvmCell);
}