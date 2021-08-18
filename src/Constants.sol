pragma ton-solidity ^0.44.0;
pragma AbiHeader time;
pragma AbiHeader expire;

import "interfaces/IConstants.sol";

contract Constants is IConstants {
    uint8 constant STATUS_ACTIVE   = 1;
    uint8 constant STATUS_EXECUTED = 2;

    uint8 constant E_UNAUTHORIZED = 100;
    uint8 constant E_INVALID_SUBSCRIPTION = 101;

    modifier onlyOwner {
        require(msg.pubkey() == tvm.pubkey(), E_UNAUTHORIZED);        
        _;
    }
}