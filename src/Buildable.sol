pragma ton-solidity >=0.44;
pragma AbiHeader time;
pragma AbiHeader expire;

import "interfaces/IBuildable.sol";

// A small contract to inherit for sharing one's own code

contract Buildable is IBuildable {

    // Shares its own code.
    function thisIsMyCode() external override responsible returns(TvmCell){
        return {value:0, flag:64} tvm.code();
    }

}