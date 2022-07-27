// Copyright (c) Aptos
// SPDX-License-Identifier: Apache-2.0

//! This module defines physical storage schema for nodes in the state Binary Merkle Tree.
//! Node is identified by [NodeKey](bsmt::node_type::NodeKey).
//! ```text
//! |<----key--->|<-----value----->|
//! |  node_key  | serialized_node |
//! ```

use crate::schema::BINARY_MERKLE_NODE_CF_NAME;
use anyhow::Result;
use aptos_types::{state_store::state_key::StateKey, transaction::Version};
use bsmt::node_type::NodeKey;
use byteorder::BigEndian;
use schemadb::{
    define_schema,
    schema::{KeyCodec, SeekKeyCodec, ValueCodec},
};
use std::mem::size_of;

type Node = bsmt::node_type::Node<StateKey>;

define_schema!(
    BinaryMerkleNodeSchema,
    NodeKey,
    Node,
    BINARY_MERKLE_NODE_CF_NAME
);

impl KeyCodec<BinaryMerkleNodeSchema> for NodeKey {
    fn encode_key(&self) -> Result<Vec<u8>> {
        self.encode()
    }

    fn decode_key(data: &[u8]) -> Result<Self> {
        Self::decode(data)
    }
}

impl ValueCodec<BinaryMerkleNodeSchema> for Node {
    fn encode_value(&self) -> Result<Vec<u8>> {
        self.encode()
    }

    fn decode_value(data: &[u8]) -> Result<Self> {
        Self::decode(data)
    }
}

impl SeekKeyCodec<BinaryMerkleNodeSchema> for (Version, u8) {
    fn encode_seek_key(&self) -> Result<Vec<u8>> {
        let mut out = Vec::with_capacity(size_of::<Version>() + size_of::<u8>());
        out.write_u64::<BigEndian>(self.0)?;
        out.write_u8(self.1)?;
        Ok(out)
    }
}

#[cfg(test)]
mod test;
