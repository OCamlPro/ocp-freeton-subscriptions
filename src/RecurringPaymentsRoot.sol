pragma ton-solidity ^0.44.0;
pragma AbiHeader time;
pragma AbiHeader expire;

import "Constants.sol";
import "SubscriptionBuilder.sol";
import "SubManagerBuilder.sol";
import "SubscriptionManager.sol";
import "WalletBuilder.sol";

contract RecurringPaymentsRoot is Constants {
    
    address static s_owner;

    WalletBuilder c_wal_builder; // The wallet builder
    SubscriptionBuilder c_sub_builder; // The subscription builder
    SubManagerBuilder c_sm_builder; // The subscription manager builder

    event ServiceDeployed(address);

    constructor(address wal_builder, address sub_builder, address sm_builder) public {
        tvm.accept();
        c_wal_builder = WalletBuilder(wal_builder);
        c_sub_builder = SubscriptionBuilder(sub_builder);
        c_sm_builder  = SubManagerBuilder(sm_builder);
        c_wal_builder.init{value:0.1 ton, flag:0}();
        c_sm_builder.init{value:0.1 ton, flag:0}();
        c_sub_builder.init{value:0.1 ton, flag:0}();
        s_owner.transfer(0, false, 128);
    }

    function deployService(address wallet, PaymentPlan pplan) external view {
        c_sm_builder.deploy{
            value:0, 
            flag:128, 
            callback:this.onDeployService
        }(wallet, pplan);
    }

    function onDeployService(address service) external view {
        require(msg.sender == address(c_sm_builder), E_UNAUTHORIZED);
        emit ServiceDeployed(service);
    }

}