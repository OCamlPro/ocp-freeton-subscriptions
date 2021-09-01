pragma ton-solidity >=0.44.0;
pragma AbiHeader time;
pragma AbiHeader expire;

import "Builder.sol";
import "SubscriptionManager.sol";

// The builder of Subscriptions Managers.
contract SubManagerBuilder is Builder {

    uint64 m_id; // A counter for IDs of subscription manager builders

    address c_sub_builder; // The Subscription Builder address
    address c_wal_builder; // The Wallet Builder address

    constructor(address buildable, address sub_builder, address wal_builder) public {
        tvm.accept();
        ref = IBuildable(buildable);
        optional(TvmCell) o;
        code = o;
        m_id = 0;
        c_sub_builder = sub_builder;
        c_wal_builder = wal_builder;
    }

    // Deploys a Subscription Manager contract
    function deploy(address wallet, PaymentPlan pplan, address service_provider) external responsible returns(address, address, address) {
        require (code.hasValue(), E_UNINITIALIZED);

        SubscriptionManager ctr = new SubscriptionManager {
            value:(msg.value / 2),
            code: code.get(),
            varInit:{
                s_id: m_id,
                s_service_provider: service_provider,
                s_wallet: wallet 
            }
        }(c_sub_builder, c_wal_builder, pplan);
        m_id ++;
        return {value:0,flag:128} (wallet, address(ctr), service_provider);
    }

}
