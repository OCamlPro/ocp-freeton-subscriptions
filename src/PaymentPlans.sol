pragma ton-solidity ^0.44.0;
pragma AbiHeader time;
pragma AbiHeader expire;

import "interfaces/IPaymentPlans.sol";
import "Constants.sol";

contract PaymentPlans is IPaymentPlans, Constants {
    address static s_manager;
    // The Subscription Manager address

    uint64 s_id;
    // Unique ID

    optional(address) c_wallet;
    // The Crystal Wallet (constant)

    optional(TIP3Wallet) c_tip3_wallet;
    // The TIP3 wallet (constant)

    // Invariant: s_wallet.hasValue() XOR s_tip3_wallet.hasValue == true

    PaymentPlan[] m_payment_plans;
    // The possible payment plans. 
    // Ideally, this array is sorted by the amount of the payment plan
    // Not a mapping because we may want to iter on it
    // TODO: ft-decentralized-bigmap ?

    constructor() public{
        require(false);
    }

    // Returns the Payment Plan kind of this contract
    function paymentPlanKind() override external responsible view returns(PaymentPlanKind){
        require(false);
    }

    // Returns the crystal wallet address; fails if TIP3 Payment plan
    function getCrystalWallet() override external responsible view returns(address){
        require(false);
    }

    // Returns the TIP3 wallet infos; fails if Crystal Payment plan
    function getTIP3Wallet() override external responsible view returns(TIP3Wallet){
        require(false);
    }

    // Returns the different payment plans
    function getPaymentPlans() override external responsible view returns(PaymentPlan[]){
        require(false);
    }

    // Returns the duration associated to a given amount
    function getDuration(uint128) override external responsible view returns(uint64){
        require(false);
    }

    // Returns the amount associated to a given duration
    function getAmount(uint64) override external responsible view returns(uint128){
        require(false);
    }

}