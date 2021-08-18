pragma ton-solidity ^0.44.0;
pragma AbiHeader time;
pragma AbiHeader expire;

import "IConstants.sol";

interface IPaymentPlans is IConstants {
    // address static s_manager;
    // The Subscription Manager address

    // optional(address) static s_wallet;
    // The Crystal Wallet

    // optional(TIP3Wallet) static s_tip3_wallet;
    // The TIP3 wallet

    // Invariant: s_wallet.hasValue() XOR s_tip3_wallet.hasValue == true

    // PaymentPlan[] payment_plans;
    // The possible payment plans. 
    // Ideally, this array is sorted by the amount of the payment plan
    // Not a mapping because we may want to iter on it
    // TODO: ft-decentralized-bigmap ?

    function paymentPlanKind() external responsible view returns(PaymentPlanKind);
    // Returns the Payment Plan kind of this contract

    function getCrystalWallet() external responsible view returns(address);
    // Returns the crystal wallet address; fails if TIP3 Payment plan

    function getTIP3Wallet() external responsible view returns(TIP3Wallet);
    // Returns the TIP3 wallet infos; fails if Crystal Payment plan

    function getPaymentPlans() external responsible view returns(PaymentPlan[]);
    // Returns the different payment plans

    function getDuration(uint128) external responsible view returns(uint64);
    // Returns the duration associated to a given amount

    function getAmount(uint64) external responsible view returns(uint128);
    // Returns the amount associated to a given duration

}