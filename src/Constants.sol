pragma ton-solidity ^0.44.0;
pragma AbiHeader time;
pragma AbiHeader expire;

import "interfaces/IConstants.sol";

contract Constants is IConstants {

    uint8 constant E_UNAUTHORIZED = 100;
    uint8 constant E_INVALID_SUBSCRIPTION = 101;
    uint8 constant E_ALREADY_INITIALIZED = 102;
    uint8 constant E_UNINITIALIZED = 103;

    uint8 constant E_INVARIANT_BROKEN = 201;

    modifier onlyOwner {
        require(msg.pubkey() == tvm.pubkey(), E_UNAUTHORIZED);        
        _;
    }

    modifier onlyFrom(address a){
        require(msg.sender == a, E_UNAUTHORIZED);
        _;
    }

}