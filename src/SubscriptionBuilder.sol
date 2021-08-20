pragma ton-solidity ^0.44.0;
pragma AbiHeader time;
pragma AbiHeader expire;

import "Builder.sol";
import "Subscription.sol";

contract SubscriptionBuilder is Builder {

    constructor(address a) public {
        ref = IBuildable(a);
        optional(TvmCell) o;
        code = o;
    }

    function deploy(
        address manager, 
        address service_provider, 
        address subscriber
    ) external responsible initialized returns(address) {
        Subscription ctr = new Subscription {
            value:(msg.value / 2),
            code: code.get(),
            varInit:{
                s_manager: manager,
                s_service_provider: service_provider,
                s_subscriber: subscriber
            }
        }();
        return {value:0, flag:0} address(ctr);
    }

}