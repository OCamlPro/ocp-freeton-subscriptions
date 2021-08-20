pragma ton-solidity ^0.44.0;
pragma AbiHeader time;
pragma AbiHeader expire;

import "Constants.sol";
import "interfaces/IBuilder.sol";
import "interfaces/IBuildable.sol";

abstract contract Builder is Constants {

    IBuildable ref;
    optional(TvmCell) code;
    
    function init() external view{
        require(tvm.pubkey() == msg.pubkey(), E_UNAUTHORIZED);
        require(!code.hasValue(), E_ALREADY_INITIALIZED);
        ref.thisIsMyCode{value:0, flag:128, callback:this.updateCode}();
    }

    function updateCode(TvmCell c) external onlyFrom(address(ref)){
        require(!code.hasValue(), E_ALREADY_INITIALIZED);
        code.set(c);
    }

    modifier initialized() {
        require(code.hasValue(), E_UNINITIALIZED);
        _;
    }
}