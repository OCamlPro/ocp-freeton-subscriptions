pragma ton-solidity ^0.44.0;
pragma AbiHeader time;
pragma AbiHeader expire;

import "Builder.sol";
import "Subscription.sol";

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
    ) external responsible initialized returns(address, address) {
        Subscription ctr = new Subscription {
            value:(msg.value / 3),
            code: code.get(),
            varInit:{
                s_manager: manager,
                s_service_provider: service_provider,
                s_subscriber: subscriber
            }
        }(pplan, wallet);
        return {value:msg.value / 3, flag:0} (subscriber, address(ctr));
    }

}