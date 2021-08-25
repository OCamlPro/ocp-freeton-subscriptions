pragma ton-solidity ^0.44.0;
pragma AbiHeader time;
pragma AbiHeader expire;

import "Builder.sol";
import "SubscriptionManager.sol";

contract SubManagerBuilder is Builder {

    uint64 m_id;

    address c_sub_builder;
    address c_wal_builder;

    constructor(address buildable, address sub_builder, address wal_builder) public {
        tvm.accept();
        ref = IBuildable(buildable);
        optional(TvmCell) o;
        code = o;
        m_id = 0;
        c_sub_builder = sub_builder;
        c_wal_builder = wal_builder;
    }

    function deploy(address wallet, PaymentPlan pplan) external responsible initialized returns(address) {
        SubscriptionManager ctr = new SubscriptionManager {
            value:(msg.value / 2),
            code: code.get(),
            varInit:{
                s_id: m_id,
                s_service_provider: msg.sender,
                s_wallet: wallet 
            }
        }(c_sub_builder, c_wal_builder, pplan);
        m_id ++;
        return {value:0,flag:128} (address(ctr));
    }

}