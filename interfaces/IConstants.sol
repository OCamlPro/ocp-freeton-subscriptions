interface IConstants{
    struct Payment {
        uint256 pubkey; // Not sure
        uint64 value;   // The amount
        uint32 period;  // The duration of the subscription
        uint32 start;   // When the subscription started
    }
}