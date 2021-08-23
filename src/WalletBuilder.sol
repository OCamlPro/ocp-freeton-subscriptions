pragma ton-solidity ^0.44.0;
pragma AbiHeader time;
pragma AbiHeader expire;

import "Builder.sol";
import "Wallet.sol";

contract WalletBuilder is Builder {

    constructor(address buildable) public {
        tvm.accept();
        ref = IBuildable(buildable);
        optional(TvmCell) o;
        code = o;
    }

    function deploy(address subscriber) external responsible initialized returns(address, address) {
        Wallet ctr = new Wallet {
            value:(msg.value / 3),
            code: code.get(),
            varInit:{
                s_manager: msg.sender,
                s_subscriber: subscriber
            }
        }();
        return {value:(msg.value / 3)} (subscriber, address(ctr));
    }

}