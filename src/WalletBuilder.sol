pragma ton-solidity ^0.44.0;
pragma AbiHeader time;
pragma AbiHeader expire;

import "Builder.sol";
import "Wallet.sol";

contract WalletBuilder is Builder {

    constructor(address a) public {
        ref = IBuildable(a);
        optional(TvmCell) o;
        code = o;
    }

    function deploy(address subscriber) external responsible initialized returns(address) {
        Wallet ctr = new Wallet {
            value:(msg.value / 2),
            code: code.get(),
            varInit:{
                s_manager: msg.sender,
                s_subscriber: subscriber
            }
        }();
        return {value:0, flag:0} (address(ctr));
    }

}