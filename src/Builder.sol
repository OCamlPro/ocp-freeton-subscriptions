pragma ton-solidity ^0.44.0;
pragma AbiHeader time;
pragma AbiHeader expire;

import "Constants.sol";
import "interfaces/IBuilder.sol";
import "interfaces/IBuildable.sol";

// Abstract contract for defining builders
// Builders are contracts dedicatedto deploying a specific type of contract
abstract contract Builder is Constants {

    IBuildable ref;
    // The contract reference.
    // It represents a useless instance of the contract,
    // from which the builder will initialize its code.

    optional(TvmCell) code;
    // The code of the contract to build.
    // It is initialized once and never updated again.

    // Entry points

    // Starts the initialization procedure by requesting the code of `ref`    
    function init() external view{
        require(!code.hasValue(), E_ALREADY_INITIALIZED);
        tvm.accept();
        ref.thisIsMyCode{value: 0, flag:64, callback:this.updateCode}();
    }

    // Continuation of `init` ; initializes the code.
    function updateCode(TvmCell c) external{
        require(msg.sender == address(ref), E_UNAUTHORIZED);
        require(!code.hasValue(), E_ALREADY_INITIALIZED);
        code.set(c);
    }

}