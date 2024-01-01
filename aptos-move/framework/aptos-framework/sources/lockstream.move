module aptos_framework::lockstream {

    use aptos_framework::account;
    use aptos_framework::event::{Self, EventHandle};
    use aptos_framework::object::{Self, ObjectGroup};
    use aptos_framework::table_with_length::{Self, TableWithLength};
    use aptos_std::math64;
    use std::option::{Self, Option};
    use aptos_framework::timestamp;

    struct Lockstreams has key {
        map: TableWithLength<u64, Lockstream>,
        creation_events: EventHandle<CreationEvent>
    }

    struct LockstreamID has copy, drop, store {
        creator: address,
        sequence_number: u64,
        base_metadata: TypeInfo, // Of corresponding Object<TokenType>
        quote_metadata: TypeInfo // Of corresponding Object<TokenType>
    }

    struct CreationEvent has copy, drop, store {
        lockstream_id: LockstreamID,
        initial_base_locked: u64,
        creation_time: u64,
        stream_start_time: u64,
        stream_end_time: u64,
        claim_last_call_time: u64,
        premier_sweep_last_call_time: u64,
    }

}