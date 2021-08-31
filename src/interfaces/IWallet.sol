pragma ton-solidity >=0.44.0;
pragma AbiHeader time;
pragma AbiHeader expire;

interface IWallet {

    // address static s_subscribtion;

    function init(address) external;
    // Initializes a wallet with the address of the subscription.

    function transferTo(address, int128) external;
    // Only callable by s_subscription, transfers `amount` to `receiver`

    function transferToCallback(address, int128) external responsible returns(uint128);
    // Same as transferTo, but returns the remaining balance

    function balance() external responsible returns(uint128);
    // Returns the balance of the wallet

    function transfer() external responsible returns(uint128);
    // Same as balance, but keeps the funds

}
