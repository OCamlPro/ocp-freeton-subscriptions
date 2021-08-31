pragma ton-solidity >=0.44.0;
pragma AbiHeader time;
pragma AbiHeader expire;
pragma AbiHeader pubkey;

import "interfaces/IRecurringPaymentsRoot.sol";

import "Constants.sol";
import "SubscriptionBuilder.sol";
import "SubManagerBuilder.sol";
import "SubscriptionManager.sol";
import "WalletBuilder.sol";

// The Root contract, allowing to deploy services
contract RecurringPaymentsRoot is Constants, IRecurringPaymentsRoot {
    
    address static s_owner; // The contract owner

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

    // Deploys a new subscription manager
    function deployService(address wallet, PaymentPlan pplan) external view override {
        tvm.accept(); 
        // Not necessary because the function does not cost enough
        // gas to fail without tvm.accept();

        c_sm_builder.deploy{
            value:0, 
            flag:128, 
            callback:this.onDeployService
        }(wallet, pplan);
    }

    // Continuation of `deployService` : emits the deployed service and refunds the
    // wallet owner
    function onDeployService(address wallet, address service) external view {
        require(msg.sender == address(c_sm_builder), E_UNAUTHORIZED);
        emit ServiceDeployed(service);
        wallet.transfer(0,false,128);
    }

}
