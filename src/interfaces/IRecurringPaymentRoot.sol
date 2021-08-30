pragma ton-solidity ^0.44.0;
pragma AbiHeader time;
pragma AbiHeader expire;

import "IConstants.sol";

// The Root contract, allowing to deploy services
interface RecurringPaymentsRoot is IConstants {
    
    // Deploys a new subscription manager
    function deployService(address wallet, PaymentPlan pplan) external view;

}
