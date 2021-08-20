pragma ton-solidity ^0.44.0;
pragma AbiHeader time;
pragma AbiHeader expire;

interface IConstants{

    enum SubStatus{Ongoing, Paused, Stopped}

    struct PaymentPlan{
        uint128 amount; // The amount for the payment plan
        uint64 period;  // The period of the payment plan
    }

}