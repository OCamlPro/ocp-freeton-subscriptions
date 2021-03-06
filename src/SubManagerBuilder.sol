pragma ton-solidity >=0.44.0;
pragma AbiHeader time;
pragma AbiHeader expire;

import "Builder.sol";
import "SubscriptionManager.sol";

// The builder of Subscriptions Managers.
contract SubManagerBuilder is Builder {

    address c_sub_builder; // The Subscription Builder address
    address c_wal_builder; // The Wallet Builder address

    constructor(address buildable, address sub_builder, address wal_builder) public {
        tvm.accept();
        ref = IBuildable(buildable);
        optional(TvmCell) o;
        code = o;
        c_sub_builder = sub_builder;
        c_wal_builder = wal_builder;
    }

    // Deploys a Subscription Manager contract
    function deploy(
        address wallet, 
        PaymentPlan pplan, 
        address service_provider, 
        string description ) external responsible 
        returns(address, address, address, string) {
        require (code.hasValue(), E_UNINITIALIZED);

        SubscriptionManager ctr = new SubscriptionManager {
            value:(msg.value / 2),
            code: code.get(),
            varInit:{
                s_id: now,
                s_service_provider: service_provider,
                s_wallet: wallet,
                s_description: description
            }
        }(c_sub_builder, c_wal_builder, pplan);
        return {value:0,flag:128} 
            (wallet, address(ctr), service_provider, description);
    }

}
