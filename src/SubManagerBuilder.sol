pragma ton-solidity ^0.44.0;
pragma AbiHeader time;
pragma AbiHeader expire;

import "Builder.sol";
import "SubscriptionManager.sol";

contract SubManagerBuilder is Builder {

    uint64 m_id;

    address static s_sub_builder;
    address static s_wal_builder;

    constructor(address buildable) public {
        tvm.accept();
        ref = IBuildable(buildable);
        optional(TvmCell) o;
        code = o;
        m_id = 0;
    }

    function deploy(address wallet) external responsible initialized returns(address) {
        SubscriptionManager ctr = new SubscriptionManager {
            value:(msg.value / 3),
            code: code.get(),
            varInit:{
                s_id: m_id,
                s_service_provider: msg.sender,
                s_wallet: wallet 
            }
        }(s_sub_builder, s_wal_builder);
        return {value:(msg.value / 3)} (address(ctr));
    }

}