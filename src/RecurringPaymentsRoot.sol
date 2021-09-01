pragma ton-solidity >=0.44.0;
pragma AbiHeader time;
pragma AbiHeader expire;

import "interfaces/IRecurringPaymentsRoot.sol";

import "Constants.sol";
import "SubscriptionBuilder.sol";
import "SubManagerBuilder.sol";
import "SubscriptionManager.sol";
import "WalletBuilder.sol";
import "ServiceListBuilder.sol";

// The Root contract, allowing to deploy services
contract RecurringPaymentsRoot is Constants, IRecurringPaymentsRoot {
    
    address static s_owner; // The contract owner

    WalletBuilder c_wal_builder; // The wallet builder
    SubscriptionBuilder c_sub_builder; // The subscription builder
    SubManagerBuilder c_sm_builder; // The subscription manager builder
    ServiceListBuilder c_sl_builder; // Service lsit builder

    event ServiceDeployed(address);

    constructor(
        address wal_builder, 
        address sub_builder, 
        address sm_builder, 
        address sl_builder) public {
            tvm.accept();
            c_wal_builder = WalletBuilder(wal_builder);
            c_sub_builder = SubscriptionBuilder(sub_builder);
            c_sm_builder  = SubManagerBuilder(sm_builder);
            c_sl_builder  = ServiceListBuilder(sl_builder);
            c_wal_builder.init{value:0.1 ton, flag:0}();
            c_sm_builder.init{value:0.1 ton, flag:0}();
            c_sub_builder.init{value:0.1 ton, flag:0}();
            c_sl_builder.init{value:0.1 ton, flag:0}();
            s_owner.transfer(0, false, 128);
    }

    // Deploys a new subscription manager
    function deployService(address wallet, PaymentPlan pplan) external view override {
        tvm.accept(); 
        // Not necessary because the function does not cost enough
        // gas to fail without tvm.accept();

        c_sm_builder.deploy{
            value:0, 
            flag:128, 
            callback:this.onDeployService
        }(wallet, pplan, msg.sender);
    }

    // Continuation of `deployService` : emits the deployed service and refunds the
    // wallet owner
    function onDeployService(address /* wallet */, address service, address provider) external view {
        require(msg.sender == address(c_sm_builder), E_UNAUTHORIZED);
        emit ServiceDeployed(service);

        // Adding the subscription to the service list
        // A service list is defined by the provider address & the root contract
        // If it already exists, it will add one.

        c_sl_builder.deploy{value:0,flag:128}(provider,service);
    }

    event ServiceAdded(address service_provider, address service);

    function onAddService(address service_provider, address service) external view override{
        emit ServiceAdded(service_provider, service);
    }

}
