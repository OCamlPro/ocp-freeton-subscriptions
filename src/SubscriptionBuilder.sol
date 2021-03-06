pragma ton-solidity >=0.44.0;
pragma AbiHeader time;
pragma AbiHeader expire;

import "Builder.sol";
import "Subscription.sol";

// Subscription Builder
contract SubscriptionBuilder is Builder {

    constructor(address buildable) public {
        tvm.accept();
        ref = IBuildable(buildable);
        optional(TvmCell) o;
        code = o;
    }

    function deploy(
        address wallet,
        address manager, 
        address service_provider, 
        address subscriber,
        PaymentPlan pplan
    ) external responsible returns(address, address, address) {
        require (code.hasValue(), E_UNINITIALIZED);

        Subscription ctr = new Subscription {
            value:(msg.value / 2),
            code: code.get(),
            varInit:{
                s_manager: manager,
                s_service_provider: service_provider,
                s_subscriber: subscriber,
                s_id:now
            }
        }(pplan, wallet);
        return {value:0, flag:128} (subscriber, address(ctr), wallet);
    }

}
