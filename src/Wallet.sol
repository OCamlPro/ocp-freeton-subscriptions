pragma ton-solidity ^0.44.0;
pragma AbiHeader time;
pragma AbiHeader expire;

import "interfaces/IWallet.sol";
import "Constants.sol";

contract Wallet is Constants {

    address static s_subscriber;
    address static s_manager;

    optional(address) c_subscription;
    // Optional -> initialized once, then never changed

    modifier initialized() {
        require(c_subscription.hasValue(), E_UNINITIALIZED);
        _;
    }

    constructor() public {
        tvm.accept();
    }

    function init(address subscription) external {
        require (msg.sender == s_manager, E_UNAUTHORIZED);
        require (!c_subscription.hasValue(), E_ALREADY_INITIALIZED);
        c_subscription.set(subscription);
    }

    // Only callable by s_subscription, transfers `amount` to `receiver`
    // If amount is negative, returns balance - | amount |
    function transferTo(address receiver, int128 amount) view external {
        require (c_subscription.hasValue(), E_UNINITIALIZED);
        require (msg.sender == c_subscription.get(), E_UNAUTHORIZED);
        int128 to_transfer;
        if (amount < 0) {
            to_transfer = int128(address(this).balance) - amount;
        } else {
            to_transfer = amount;
        }

        require (to_transfer >= 0, E_INVALID_AMOUNT);
        receiver.transfer(uint128(to_transfer), false);
    }

    function transferToCallback(address receiver, int128 amount) view external responsible returns(uint128){
       
        require (c_subscription.hasValue(), E_UNINITIALIZED);
        require (msg.sender == c_subscription.get(), E_UNAUTHORIZED);
        int128 to_transfer;
        if (amount < 0) {
            to_transfer = int128(address(this).balance) - amount;
        } else {
            to_transfer = amount;
        }

        require (to_transfer >= 0, E_INVALID_AMOUNT);

        receiver.transfer(uint128(to_transfer), false);
        return {value:0, flag: 0} (address(this).balance - uint128(to_transfer));
    }

    function balance() external pure responsible returns(uint128){
        return {value:0, flag: 0} address(this).balance;
    }

    function transfer() external pure responsible returns(uint128){
        return address(this).balance;
    }

}