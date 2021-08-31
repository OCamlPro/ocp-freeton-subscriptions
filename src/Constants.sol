pragma ton-solidity >=0.44.0;
pragma AbiHeader time;
pragma AbiHeader expire;

import "interfaces/IConstants.sol";

// Constants used in the project
contract Constants is IConstants {

    uint8 constant E_UNAUTHORIZED = 100;
    uint8 constant E_INVALID_SUBSCRIPTION = 101;
    uint8 constant E_ALREADY_INITIALIZED = 102;
    uint8 constant E_UNINITIALIZED = 103;
    uint8 constant E_INVALID_AMOUNT = 104;
    uint8 constant E_NOT_CALLABLE_IF_TIP3 = 105;

    uint8 constant E_INVARIANT_BROKEN = 201;

    uint128 constant MAX_INT64 = uint128(2**64 - 1);
    uint128 constant MAX_INT128 = uint128(2**128 - 1);

}
