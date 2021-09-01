pragma ton-solidity >=0.44.0;
pragma AbiHeader time;
pragma AbiHeader expire;

interface IConstants{

    // A payment plan.
    // It specifies the amount for subscribing to a service, the period
    // of the subscription & the optional root token addres for TIP3 subscriptions
    struct PaymentPlan{
        uint128 amount; // The amount for the payment plan
        uint64 period;  // The period of the payment plan
        address root_token; // Only for TIP3, =0 otherwise
    }

    // Information about a service
    // Its address & its description
    struct ServiceInfo {
        address addr;
        string descr;
    }

}
