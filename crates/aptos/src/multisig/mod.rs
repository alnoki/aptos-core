// Copyright © Aptos Foundation
// SPDX-License-Identifier: Apache-2.0

use crate::{
    common::{
        types::{CliError, TransactionOptions, TransactionSummary},
        utils::{profile_or_submit, read_from_file},
    },
    CliCommand, CliResult, CliTypedResult,
};
use aptos_rest_client::aptos_api_types::{Address, EntryFunctionPayload};
use aptos_types::account_address::AccountAddress;
use async_trait::async_trait;
use clap::{Parser, Subcommand};
use serde::Deserialize;
use serde_json::Value;
use std::{collections::HashMap, path::PathBuf};

/// Tool for multisig account operations
#[derive(Debug, Subcommand)]
pub enum MultisigTool {
    Create(CreateMultisig),
    Entry(SerializeEntryFunctionProposal),
}

impl MultisigTool {
    pub async fn execute(self) -> CliResult {
        match self {
            MultisigTool::Create(tool) => tool.execute_serialized().await,
            MultisigTool::Entry(tool) => tool.execute_serialized().await,
        }
    }
}

/// Create a multisig account
#[derive(Debug, Parser)]
pub struct CreateMultisig {
    /// Hex account address(es) to add as owners, each prefixed with "0x" and separated by spaces
    #[clap(long, multiple(true), parse(try_from_str=crate::common::types::load_account_arg))]
    pub additional_owners: Vec<AccountAddress>,
    /// Number of signatures required to approve a transaction
    #[clap(long)]
    pub num_signatures_required: u64,
    #[clap(flatten)]
    pub txn_options: TransactionOptions,
}

#[async_trait]
impl CliCommand<TransactionSummary> for CreateMultisig {
    fn command_name(&self) -> &'static str {
        "CreateMultisig"
    }

    async fn execute(self) -> CliTypedResult<TransactionSummary> {
        profile_or_submit(
            aptos_cached_packages::aptos_stdlib::multisig_account_create_with_owners(
                self.additional_owners,
                self.num_signatures_required,
                vec![], // Metadata keys not supported for ease of CLI parsing.
                vec![], // Metadata values not supported for ease of CLI parsing.
            ),
            &self.txn_options,
        )
        .await
    }
}

/// Serialize a JSON transaction proposal
#[derive(Debug, Parser)]
pub struct SerializeEntryFunctionProposal {
    /// Transaction proposal path
    #[clap(parse(from_os_str))]
    proposal_file: PathBuf,
}

#[async_trait]
impl CliCommand<HashMap<&'static str, String>> for SerializeEntryFunctionProposal {
    fn command_name(&self) -> &'static str {
        "SerializeEntryFunctionProposal"
    }

    async fn execute(self) -> CliTypedResult<HashMap<&'static str, String>> {
        let proposal_json = read_from_file(&self.proposal_file)?;
        let transaction_proposal: EntryFunctionProposal = serde_json::from_slice(&proposal_json)
            .map_err(|error| {
                CliError::UnableToReadFile(
                    self.proposal_file.display().to_string(),
                    error.to_string(),
                )
            })?;
        let payload_bytes = serde_json::to_vec(&transaction_proposal.entry_function_payload);
        println!("{:?}", transaction_proposal);

        Ok(HashMap::new())
    }
}

#[derive(Deserialize, Debug)]
struct EntryFunctionProposal {
    multisig_account_address: Address,
    // Must be specified with all strings.
    entry_function_payload: EntryFunctionPayload,
}

#[derive(Deserialize, Debug)]
struct EntryFunctionProposalSerialized {
    entry_function_proposal: EntryFunctionProposal,
    payload_bytes: String,
    payload_hash: String,
}
