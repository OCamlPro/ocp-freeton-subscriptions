pragma ton-solidity ^0.44.0;
pragma AbiHeader time;
pragma AbiHeader expire;

import "Builder.sol";
import "Wallet.sol";

// Crystal Wallet Builder
contract WalletBuilder is Builder {

    constructor(address buildable) public {
        tvm.accept();
        ref = IBuildable(buildable);
        optional(TvmCell) o;
        code = o;
    }

    // Deploys a crystal wallet
    function deploy(address subscriber) external responsible returns(address, address) {
        require (code.hasValue(), E_UNINITIALIZED);
        
        Wallet ctr = new Wallet {
            value:(msg.value / 2),
            code: code.get(),
            varInit:{
                s_manager: msg.sender,
                s_subscriber: subscriber
            }
        }();
        return {value:0, flag:128} (subscriber, address(ctr));
    }

}