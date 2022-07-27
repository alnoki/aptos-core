// Copyright (c) Aptos
// SPDX-License-Identifier: Apache-2.0

//! Node types of [`JellyfishMerkleTree`](crate::JellyfishMerkleTree)
//!
//! This module defines two types of Jellyfish Merkle tree nodes: [`InternalNode`]
//! and [`LeafNode`] as building blocks of a 256-bit
//! [`JellyfishMerkleTree`](crate::JellyfishMerkleTree). [`InternalNode`] represents a 4-level
//! binary tree to optimize for IOPS: it compresses a tree with 31 nodes into one node with 16
//! chidren at the lowest level. [`LeafNode`] stores the full key and the value associated.

#[cfg(test)]
mod node_type_test;

use crate::metrics::{APTOS_BSMT_INTERNAL_ENCODED_BYTES, APTOS_BSMT_LEAF_ENCODED_BYTES};
use anyhow::{ensure, Context, Result};
use aptos_crypto::{
    hash::{CryptoHash, SPARSE_MERKLE_PLACEHOLDER_HASH},
    HashValue,
};
use aptos_types::{
    nibble::{Nibble},
    proof::{SparseMerkleInternalNode, SparseMerkleLeafNode},
    transaction::Version,
};
use byteorder::{BigEndian, LittleEndian, ReadBytesExt, WriteBytesExt};
use itertools::Itertools;
use num_derive::{FromPrimitive, ToPrimitive};
use num_traits::cast::FromPrimitive;

use serde::{Deserialize, Serialize};
use std::{
    collections::hash_map::HashMap,
    io::{prelude::*, Cursor, Read, SeekFrom, Write},
    mem::size_of,
};
use thiserror::Error;
use std::fmt;


#[derive(Clone, Hash, Eq, PartialEq, Ord, PartialOrd, Serialize, Deserialize)]
pub struct NodePath {
    num_bits: usize,
    bits: Vec<u8>,
}

impl NodePath {
    pub fn new(num_bits: usize, bits: Vec<u8>) -> Self {
        Self {
            num_bits,
            bits,
        }
    }

    pub fn get_bit(&self, i: usize) -> bool {
        let pos = i / 8;
        let bit = 7 - i % 8;
        ((self.bytes[pos] >> bit) & 1) != 0
    }

    pub fn bits(&self) -> BitIterator {
        BitIterator::new(self, 0, self.num_bits)
    }

    pub fn num_bits(&self) -> usize {
        self.num_bits
    }

    pub fn bytes(&self) -> &[u8] {
        &self.bytes
    }
}

impl fmt::Debug for NodePath {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
    }
}

pub struct BitIterator<'a> {
    path: &'a NodePath,
    pos: std::ops::Range<usize>,
}

impl<'a> Iterator for BitIterator<'a> {
    type Item = bool;
    fn next(&mut self) -> Option<Self::Item> {
        self.pos.next().map(|i| self.path.get_bit(i))
    }
}

type ChildIndex = u8;

/// The unique key of each node.
#[derive(Clone, Debug, Hash, Eq, PartialEq, Ord, PartialOrd)]
pub struct NodeKey {
    // The version at which the node is created.
    version: Version,
    // The position this node represents in the tree.
    position: NodePath,
}

impl NodeKey {
    /// Creates a new `NodeKey`.
    pub fn new(version: Version, position: NodePath) -> Self {
        Self { version, position }
    }

    /// A shortcut to generate a node key consisting of a version and an empty nibble path.
    pub fn new_empty_path(version: Version) -> Self {
        Self::new(version, NodePath::new(0, vec![]))
    }

    /// Gets the version.
    pub fn version(&self) -> Version {
        self.version
    }

    /// Gets the position.
    pub fn position(&self) -> &NodePath {
        &self.position
    }

    /// Generates a child node key based on this node key, false -> left, true -> right.
    pub fn gen_child_node_key(&self, version: Version, child_index: ChildIndex) -> Self {
        assert!(child_index < 2);
        let mut node_position = self.position().clone();
        node_position.push(child_index);
        Self::new(version, node_position)
    }

    /// Generates parent node key at the same version based on this node key.
    pub fn gen_parent_node_key(&self) -> Self {
        let mut node_position = self.position().clone();
        assert!(node_position.pop().is_some(), "Current node key is root.",);
        Self::new(self.version, node_position)
    }

    /// Sets the version to the given version.
    pub fn set_version(&mut self, version: Version) {
        self.version = version;
    }

    /// Serializes to bytes for physical storage enforcing the same order as that in memory.
    pub fn encode(&self) -> Result<Vec<u8>> {
        let mut out = vec![];
        out.write_u64::<BigEndian>(self.version())?;
        out.write_u8(self.position().len());
        out.write_all(self.position().bytes())?;
        Ok(out)
    }

    /// Recovers from serialized bytes in physical storage.
    pub fn decode(val: &[u8]) -> Result<NodeKey> {
        let mut reader = Cursor::new(val);
        let version = reader.read_u64::<BigEndian>()?;
        let position_len = reader.read_u8()? as usize;
        ensure!(
            position_len <= 256,
            "Invalid length of position: {}",
            position_len,
        );
        let mut position = NodePath::
        let mut nibble_bytes = Vec::with_capacity((num_nibbles + 1) / 2);
        reader.read_to_end(&mut nibble_bytes)?;
        ensure!(
            (num_nibbles + 1) / 2 == nibble_bytes.len(),
            "encoded num_nibbles {} mismatches nibble path bytes {:?}",
            num_nibbles,
            nibble_bytes
        );
        let nibble_path = if num_nibbles % 2 == 0 {
            NibblePath::new_even(nibble_bytes)
        } else {
            let padding = nibble_bytes.last().unwrap() & 0x0f;
            ensure!(
                padding == 0,
                "Padding nibble expected to be 0, got: {}",
                padding,
            );
            NibblePath::new_odd(nibble_bytes)
        };
        Ok(NodeKey::new(version, nibble_path))
    }
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub enum NodeType {
    Leaf,
    /// A internal node that haven't been finished the leaf count migration, i.e. None or not all
    /// of the children leaf counts are known.
    Internal {
        leaf_count: usize,
    },
}

#[cfg(any(test, feature = "fuzzing"))]
impl Arbitrary for NodeType {
    type Parameters = ();
    type Strategy = BoxedStrategy<Self>;

    fn arbitrary_with(_args: ()) -> Self::Strategy {
        prop_oneof![
            Just(NodeType::Leaf),
            (2..100usize).prop_map(|leaf_count| NodeType::Internal { leaf_count })
        ]
        .boxed()
    }
}

/// Each child of [`InternalNode`] encapsulates a nibble forking at this node.
#[derive(Clone, Debug, Eq, PartialEq)]
pub struct Child {
    /// The hash value of this child node.
    pub hash: HashValue,
    /// `version`, the `nibble_path` of the ['NodeKey`] of this [`InternalNode`] the child belongs
    /// to and the child's index constitute the [`NodeKey`] to uniquely identify this child node
    /// from the storage. Used by `[`NodeKey::gen_child_node_key`].
    pub version: Version,
    /// Indicates if the child is a leaf, or if it's an internal node, the total number of leaves
    /// under it (though it can be unknown during migration).
    pub node_type: NodeType,
}

impl Child {
    pub fn new(hash: HashValue, version: Version, node_type: NodeType) -> Self {
        Self {
            hash,
            version,
            node_type,
        }
    }

    pub fn is_leaf(&self) -> bool {
        matches!(self.node_type, NodeType::Leaf)
    }

    pub fn leaf_count(&self) -> usize {
        match self.node_type {
            NodeType::Leaf => 1,
            NodeType::Internal { leaf_count } => leaf_count,
        }
    }
}

/// [`Children`] is just a collection of children belonging to a [`InternalNode`], indexed from 0 to
/// 15, inclusive.
pub(crate) type Children = HashMap<ChildIndex, Child>;

#[derive(Clone, Debug, Eq, PartialEq)]
pub struct InternalNode {
    /// Up to 2 children.
    children: Children,
    /// Total number of leaves under this internal node
    leaf_count: usize,
}

impl InternalNode {
    /// Creates a new Internal node.
    pub fn new(children: Children) -> Self {
        Self::new_impl(children).expect("Input children are logical.")
    }

    pub fn new_impl(children: Children) -> Result<Self> {
        // Assert the internal node must have >= 1 children. If it only has one child, it cannot be
        // a leaf node. Otherwise, the leaf node should be a child of this internal node's parent.
        ensure!(!children.is_empty(), "Children must not be empty");
        if children.len() == 1 {
            ensure!(
                !children
                    .values()
                    .next()
                    .expect("Must have 1 element")
                    .is_leaf(),
                "If there's only one child, it must not be a leaf."
            );
        }

        let leaf_count = children.values().map(Child::leaf_count).sum();
        Ok(Self {
            children,
            leaf_count,
        })
    }

    pub fn leaf_count(&self) -> usize {
        self.leaf_count
    }

    pub fn node_type(&self) -> NodeType {
        NodeType::Internal {
            leaf_count: self.leaf_count,
        }
    }

    pub fn hash(&self) -> HashValue {
        self.merkle_hash(
            0,  /* start index */
            16, /* the number of leaves in the subtree of which we want the hash of root */
            self.generate_bitmaps(),
        )
    }

    pub fn children_sorted(&self) -> impl Iterator<Item = (&ChildIndex, &Child)> {
        self.children.iter().sorted_by_key(|(child_index, _)| **child_index)
    }

    pub fn serialize(&self, binary: &mut Vec<u8>) -> Result<()> {
        let (mut existence_bitmap, leaf_bitmap) = self.generate_bitmaps();
        binary.write_u16::<LittleEndian>(existence_bitmap)?;
        binary.write_u16::<LittleEndian>(leaf_bitmap)?;
        for _ in 0..existence_bitmap.count_ones() {
            let next_child = existence_bitmap.trailing_zeros() as u8;
            let child = &self.children[&next_child];
            serialize_u64_varint(child.version, binary);
            binary.extend(child.hash.to_vec());
            match child.node_type {
                NodeType::Leaf => (),
                NodeType::Internal { leaf_count } => {
                    serialize_u64_varint(leaf_count as u64, binary);
                }
            };
            existence_bitmap &= !(1 << next_child);
        }
        Ok(())
    }

    pub fn deserialize(data: &[u8]) -> Result<Self> {
        let mut reader = Cursor::new(data);
        let len = data.len();

        // Read and validate existence and leaf bitmaps
        let mut existence_bitmap = reader.read_u16::<LittleEndian>()?;
        let leaf_bitmap = reader.read_u16::<LittleEndian>()?;
        match existence_bitmap {
            0 => return Err(NodeDecodeError::NoChildren.into()),
            _ if (existence_bitmap & leaf_bitmap) != leaf_bitmap => {
                return Err(NodeDecodeError::ExtraLeaves {
                    existing: existence_bitmap,
                    leaves: leaf_bitmap,
                }
                .into())
            }
            _ => (),
        }

        // Reconstruct children
        let mut children = HashMap::new();
        for _ in 0..existence_bitmap.count_ones() {
            let next_child = existence_bitmap.trailing_zeros() as u8;
            let version = deserialize_u64_varint(&mut reader)?;
            let pos = reader.position() as usize;
            let remaining = len - pos;

            ensure!(
                remaining >= size_of::<HashValue>(),
                "not enough bytes left, children: {}, bytes: {}",
                existence_bitmap.count_ones(),
                remaining
            );
            let hash = HashValue::from_slice(&reader.get_ref()[pos..pos + size_of::<HashValue>()])?;
            reader.seek(SeekFrom::Current(size_of::<HashValue>() as i64))?;

            let child_bit = 1 << next_child;
            let node_type = if (leaf_bitmap & child_bit) != 0 {
                NodeType::Leaf
            } else {
                let leaf_count = deserialize_u64_varint(&mut reader)? as usize;
                NodeType::Internal { leaf_count }
            };

            children.insert(
                next_child,
                Child::new(hash, version, node_type),
            );
            existence_bitmap &= !child_bit;
        }
        assert_eq!(existence_bitmap, 0);

        Self::new_impl(children)
    }

    /// Gets the `n`-th child.
    pub fn child(&self, n: ChildIndex) -> Option<&Child> {
        self.children.get(&n)
    }

    /// Generates `existence_bitmap` and `leaf_bitmap` as a pair of `u16`s: child at index `i`
    /// exists if `existence_bitmap[i]` is set; child at index `i` is leaf node if
    /// `leaf_bitmap[i]` is set.
    pub fn generate_bitmaps(&self) -> (u16, u16) {
        let mut existence_bitmap = 0;
        let mut leaf_bitmap = 0;
        for (child_index, child) in self.children.iter() {
            existence_bitmap |= 1u16 << child_index;
            if child.is_leaf() {
                leaf_bitmap |= 1u16 << child_index;
            }
        }
        // `leaf_bitmap` must be a subset of `existence_bitmap`.
        assert_eq!(existence_bitmap | leaf_bitmap, existence_bitmap);
        (existence_bitmap, leaf_bitmap)
    }

    /// Given a range [start, start + width), returns the sub-bitmap of that range.
    fn range_bitmaps(start: u8, width: u8, bitmaps: (u16, u16)) -> (u16, u16) {
        assert!(start < 16 && width.count_ones() == 1 && start % width == 0);
        assert!(width <= 16 && (start + width) <= 16);
        // A range with `start == 8` and `width == 4` will generate a mask 0b0000111100000000.
        // use as converting to smaller integer types when 'width == 16'
        let mask = (((1u32 << width) - 1) << start) as u16;
        (bitmaps.0 & mask, bitmaps.1 & mask)
    }

    fn merkle_hash(
        &self,
        start: u8,
        width: u8,
        (existence_bitmap, leaf_bitmap): (u16, u16),
    ) -> HashValue {
        // Given a bit [start, 1 << nibble_height], return the value of that range.
        let (range_existence_bitmap, range_leaf_bitmap) =
            Self::range_bitmaps(start, width, (existence_bitmap, leaf_bitmap));
        if range_existence_bitmap == 0 {
            // No child under this subtree
            *SPARSE_MERKLE_PLACEHOLDER_HASH
        } else if width == 1 || (range_existence_bitmap.count_ones() == 1 && range_leaf_bitmap != 0)
        {
            // Only 1 leaf child under this subtree or reach the lowest level
            let only_child_index = range_existence_bitmap.trailing_zeros() as u8;
            self.child(only_child_index)
                .with_context(|| {
                    format!(
                        "Corrupted internal node: existence_bitmap indicates \
                         the existence of a non-exist child at index {:x}",
                        only_child_index
                    )
                })
                .unwrap()
                .hash
        } else {
            let left_child = self.merkle_hash(
                start,
                width / 2,
                (range_existence_bitmap, range_leaf_bitmap),
            );
            let right_child = self.merkle_hash(
                start + width / 2,
                width / 2,
                (range_existence_bitmap, range_leaf_bitmap),
            );
            SparseMerkleInternalNode::new(left_child, right_child).hash()
        }
    }

    /// Gets the child and its corresponding siblings that are necessary to generate the proof for
    /// the `n`-th child. If it is an existence proof, the returned child must be the `n`-th
    /// child; otherwise, the returned child may be another child. See inline explanation for
    /// details. When calling this function with n = 11 (node `b` in the following graph), the
    /// range at each level is illustrated as a pair of square brackets:
    ///
    /// ```text
    ///     4      [f   e   d   c   b   a   9   8   7   6   5   4   3   2   1   0] -> root level
    ///            ---------------------------------------------------------------
    ///     3      [f   e   d   c   b   a   9   8] [7   6   5   4   3   2   1   0] width = 8
    ///                                  chs <--┘                        shs <--┘
    ///     2      [f   e   d   c] [b   a   9   8] [7   6   5   4] [3   2   1   0] width = 4
    ///                  shs <--┘               └--> chs
    ///     1      [f   e] [d   c] [b   a] [9   8] [7   6] [5   4] [3   2] [1   0] width = 2
    ///                          chs <--┘       └--> shs
    ///     0      [f] [e] [d] [c] [b] [a] [9] [8] [7] [6] [5] [4] [3] [2] [1] [0] width = 1
    ///     ^                chs <--┘   └--> shs
    ///     |   MSB|<---------------------- uint 16 ---------------------------->|LSB
    ///  height    chs: `child_half_start`         shs: `sibling_half_start`
    /// ```
    pub fn get_child_with_siblings(
        &self,
        node_key: &NodeKey,
        child_index: ChildIndex,
    ) -> (Option<NodeKey>, Vec<HashValue>) {
        let mut siblings = vec![];
        let (existence_bitmap, leaf_bitmap) = self.generate_bitmaps();

        // Nibble height from 3 to 0.
        for h in (0..4).rev() {
            // Get the number of children of the internal node that each subtree at this height
            // covers.
            let width = 1 << h;
            let (child_half_start, sibling_half_start) = get_child_and_sibling_half_start(child_index, h);
            // Compute the root hash of the subtree rooted at the sibling of `r`.
            siblings.push(self.merkle_hash(
                sibling_half_start,
                width,
                (existence_bitmap, leaf_bitmap),
            ));

            let (range_existence_bitmap, range_leaf_bitmap) =
                Self::range_bitmaps(child_half_start, width, (existence_bitmap, leaf_bitmap));

            if range_existence_bitmap == 0 {
                // No child in this range.
                return (None, siblings);
            } else if width == 1
                || (range_existence_bitmap.count_ones() == 1 && range_leaf_bitmap != 0)
            {
                // Return the only 1 leaf child under this subtree or reach the lowest level
                // Even this leaf child is not the n-th child, it should be returned instead of
                // `None` because it's existence indirectly proves the n-th child doesn't exist.
                // Please read proof format for details.
                let only_child_index = range_existence_bitmap.trailing_zeros() as u8;
                return (
                    {
                        let only_child_version = self
                            .child(only_child_index)
                            // Should be guaranteed by the self invariants, but these are not easy to express at the moment
                            .with_context(|| {
                                format!(
                                    "Corrupted internal node: child_bitmap indicates \
                                     the existence of a non-exist child at index {:x}",
                                    only_child_index
                                )
                            })
                            .unwrap()
                            .version;
                        Some(node_key.gen_child_node_key(only_child_version, only_child_index))
                    },
                    siblings,
                );
            }
        }
        unreachable!("Impossible to get here without returning even at the lowest level.")
    }
}

/// Given a nibble, computes the start position of its `child_half_start` and `sibling_half_start`
/// at `height` level.
pub(crate) fn get_child_and_sibling_half_start(n: ChildIndex, height: u8) -> (u8, u8) {
    // Get the index of the first child belonging to the same subtree whose root, let's say `r` is
    // at `height` that the n-th child belongs to.
    // Note: `child_half_start` will be always equal to `n` at height 0.
    let child_half_start = (0xff << height) & u8::from(n);

    // Get the index of the first child belonging to the subtree whose root is the sibling of `r`
    // at `height`.
    let sibling_half_start = child_half_start ^ (1 << height);

    (child_half_start, sibling_half_start)
}

/// Represents an account.
#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
pub struct LeafNode<K> {
    // The hashed key associated with this leaf node.
    account_key: HashValue,
    // The hash of the value.
    value_hash: HashValue,
    // The key and version thats points to the value
    value_index: (K, Version),
}

impl<K> LeafNode<K>
where
    K: crate::Key,
{
    /// Creates a new leaf node.
    pub fn new(account_key: HashValue, value_hash: HashValue, value_index: (K, Version)) -> Self {
        Self {
            account_key,
            value_hash,
            value_index,
        }
    }

    /// Gets the account key, the hashed account address.
    pub fn account_key(&self) -> HashValue {
        self.account_key
    }

    /// Gets the associated value hash.
    pub fn value_hash(&self) -> HashValue {
        self.value_hash
    }

    /// Get the index key to locate the value.
    pub fn value_index(&self) -> &(K, Version) {
        &self.value_index
    }

    pub fn hash(&self) -> HashValue {
        SparseMerkleLeafNode::new(self.account_key, self.value_hash).hash()
    }
}

impl<K> From<LeafNode<K>> for SparseMerkleLeafNode {
    fn from(leaf_node: LeafNode<K>) -> Self {
        Self::new(leaf_node.account_key, leaf_node.value_hash)
    }
}

#[repr(u8)]
#[derive(FromPrimitive, ToPrimitive)]
enum NodeTag {
    Leaf = 1,
    Internal = 2,
}

#[derive(Clone, Debug, Eq, PartialEq)]
pub enum Node<K> {
    /// A wrapper of [`InternalNode`].
    Internal(InternalNode),
    /// A wrapper of [`LeafNode`].
    Leaf(LeafNode<K>),
}

impl<K> From<InternalNode> for Node<K> {
    fn from(node: InternalNode) -> Self {
        Node::Internal(node)
    }
}

impl From<InternalNode> for Children {
    fn from(node: InternalNode) -> Self {
        node.children
    }
}

impl<K> From<LeafNode<K>> for Node<K> {
    fn from(node: LeafNode<K>) -> Self {
        Node::Leaf(node)
    }
}

impl<K> Node<K>
where
    K: crate::Key,
{
    /// Creates the [`Leaf`](Node::Leaf) variant.
    pub fn new_leaf(
        account_key: HashValue,
        value_hash: HashValue,
        value_index: (K, Version),
    ) -> Self {
        Node::Leaf(LeafNode::new(account_key, value_hash, value_index))
    }

    /// Returns `true` if the node is a leaf node.
    pub fn is_leaf(&self) -> bool {
        matches!(self, Node::Leaf(_))
    }

    /// Returns `NodeType`
    pub fn node_type(&self) -> NodeType {
        match self {
            // The returning value will be used to construct a `Child` of a internal node, while an
            // internal node will never have a child of Node::Null.
            Self::Leaf(_) => NodeType::Leaf,
            Self::Internal(n) => n.node_type(),
        }
    }

    /// Returns leaf count if known
    pub fn leaf_count(&self) -> usize {
        match self {
            Node::Leaf(_) => 1,
            Node::Internal(internal_node) => internal_node.leaf_count,
        }
    }

    /// Serializes to bytes for physical storage.
    pub fn encode(&self) -> Result<Vec<u8>> {
        let mut out = vec![];

        match self {
            Node::Internal(internal_node) => {
                out.push(NodeTag::Internal as u8);
                internal_node.serialize(&mut out)?;
                APTOS_BSMT_INTERNAL_ENCODED_BYTES.inc_by(out.len() as u64);
            }
            Node::Leaf(leaf_node) => {
                out.push(NodeTag::Leaf as u8);
                out.extend(bcs::to_bytes(&leaf_node)?);
                APTOS_BSMT_LEAF_ENCODED_BYTES.inc_by(out.len() as u64);
            }
        }
        Ok(out)
    }

    /// Computes the hash of nodes.
    pub fn hash(&self) -> HashValue {
        match self {
            Node::Internal(internal_node) => internal_node.hash(),
            Node::Leaf(leaf_node) => leaf_node.hash(),
        }
    }

    /// Recovers from serialized bytes in physical storage.
    pub fn decode(val: &[u8]) -> Result<Node<K>> {
        if val.is_empty() {
            return Err(NodeDecodeError::EmptyInput.into());
        }
        let tag = val[0];
        let node_tag = NodeTag::from_u8(tag);
        match node_tag {
            Some(NodeTag::Internal) => Ok(Node::Internal(InternalNode::deserialize(&val[1..])?)),
            Some(NodeTag::Leaf) => Ok(Node::Leaf(bcs::from_bytes(&val[1..])?)),
            None => Err(NodeDecodeError::UnknownTag { unknown_tag: tag }.into()),
        }
    }
}

/// Error thrown when a [`Node`] fails to be deserialized out of a byte sequence stored in physical
/// storage, via [`Node::decode`].
#[derive(Debug, Error, Eq, PartialEq)]
pub enum NodeDecodeError {
    /// Input is empty.
    #[error("Missing tag due to empty input")]
    EmptyInput,

    /// The first byte of the input is not a known tag representing one of the variants.
    #[error("lead tag byte is unknown: {}", unknown_tag)]
    UnknownTag { unknown_tag: u8 },

    /// No children found in internal node
    #[error("No children found in internal node")]
    NoChildren,

    /// Extra leaf bits set
    #[error(
        "Non-existent leaf bits set, existing: {}, leaves: {}",
        existing,
        leaves
    )]
    ExtraLeaves { existing: u16, leaves: u16 },
}

/// Helper function to serialize version in a more efficient encoding.
/// We use a super simple encoding - the high bit is set if more bytes follow.
fn serialize_u64_varint(mut num: u64, binary: &mut Vec<u8>) {
    for _ in 0..8 {
        let low_bits = num as u8 & 0x7f;
        num >>= 7;
        let more = match num {
            0 => 0u8,
            _ => 0x80,
        };
        binary.push(low_bits | more);
        if more == 0 {
            return;
        }
    }
    // Last byte is encoded raw; this means there are no bad encodings.
    assert_ne!(num, 0);
    assert!(num <= 0xff);
    binary.push(num as u8);
}

/// Helper function to deserialize versions from above encoding.
fn deserialize_u64_varint<T>(reader: &mut T) -> Result<u64>
where
    T: Read,
{
    let mut num = 0u64;
    for i in 0..8 {
        let byte = reader.read_u8()?;
        num |= u64::from(byte & 0x7f) << (i * 7);
        if (byte & 0x80) == 0 {
            return Ok(num);
        }
    }
    // Last byte is encoded as is.
    let byte = reader.read_u8()?;
    num |= u64::from(byte) << 56;
    Ok(num)
}
