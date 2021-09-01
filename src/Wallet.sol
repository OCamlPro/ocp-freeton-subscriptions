pragma ton-solidity >=0.44.0;
pragma AbiHeader time;
pragma AbiHeader expire;

import "interfaces/IWallet.sol";
import "interfaces/ISubscription.sol";
import "Constants.sol";
import "Buildable.sol";

// Simple Crystal Wallet
contract Wallet is Constants, Buildable {

    address static s_subscriber;
    address static s_manager;

    optional(address) c_subscription;
    // Optional -> initialized once, then never changed

    constructor() public {
        tvm.accept();
    }

    function init(address subscription) external {
        require (msg.sender == s_manager, E_UNAUTHORIZED);
        require (!c_subscription.hasValue(), E_ALREADY_INITIALIZED);
        c_subscription.set(subscription);
        s_subscriber.transfer(0, false, 128);
    }

    // Only callable by s_subscription, transfers `amount` to `receiver`
    // If amount is negative, returns balance - | amount |
    function transferTo(address receiver, int128 amount) view external {
        require (c_subscription.hasValue(), E_UNINITIALIZED);
        require (msg.sender == c_subscription.get(), E_UNAUTHORIZED);
        if (amount < 0) {
            tvm.rawReserve(uint128(-1 * amount), 2);
            // Reserves the min between amount and the balance
        } else {
            if (address(this).balance > uint128(amount) + msg.value) {
                tvm.rawReserve(uint128(amount) + msg.value, 3);
                // Reserves balance - amount, or nothing if amount > balance
            }
        }
        receiver.transfer(0,false,128);
    }

    // Returns the balance of the contract without the value of the message
    function balance() external pure responsible returns(uint128){
        return {value: 0, flag: 64} address(this).balance - msg.value;
    }

    // Accepts funds & returns the balance of the contract
    function transfer() external pure responsible returns(uint128){
        return {value: 0.01 ton} address(this).balance - 0.01 ton;
    }

}
