pragma ton-solidity ^0.44.0;
pragma AbiHeader time;
pragma AbiHeader expire;

interface IConstants{

    struct PaymentPlan{
        uint128 amount; // The amount for the payment plan
        uint64 period;  // The period of the payment plan
    }

    struct TIP3Wallet{
        address root_wallet; // The root wallet
        uint256 pubkey;      // The pubkey of the user
    }

    struct Payment {
        uint256 pubkey; // Not sure
        uint128 value;  // The amount
        uint64 period;  // The duration of the subscription
        uint128 start;  // When the subscription started
    }

    enum PaymentPlanKind {TIP3, Crystal}
}