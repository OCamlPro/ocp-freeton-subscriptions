pragma ton-solidity ^0.44.0;
pragma AbiHeader time;
pragma AbiHeader expire;

import "interfaces/IWallet.sol";
import "Constants.sol";

interface IWallet is Constants {

    address static s_subscribtion;

    constructor() public {
        require(msg.sender == s_subscription, E_UNAUTHORIZED);
        tvm.accept();
    }

    // Only callable by s_subscription, transfers `amount` to `receiver`
    // If amount is negative, returns balance - | amount |
    function transferTo(address receiver, int128 amount) external onlyFrom(s_subscription) {
        if (amount < 0) {
            receiver.transfer(address(this).balance + amount);
        } else {
            receiver.transfer(amount);
        }
    }

    function trasnferToCallback(address receiver, int128 amount) external responsible onlyFrom(s_subscription) returns(uint128){
        if (amount < 0) {
            receiver.transfer(address(this).balance + amount);
        } else {
            receiver.transfer(amount);
        }
        return {value:0, flag: 0} (address(this).balance - amount);
    }

    function balance() external view responsible returns(uint128){
        return {value:0, flag: 0} address(this).balance;
    }

    function transfer() external view responsible returns(uint128){
        return address(this).balance;
    }

}