#!/bin/bash

KEY="mstchain-testnet-key"
CHAINID="mstchain-testnet"
MONIKER="mstchain-testnet-1"

# remove existing daemon and client
rm -rf ~/.msgrc*

export GOPROXY=http://goproxy.cn

if [[ "$(uname)" == "Darwin" ]]; then
    # Do something under Mac OS X platform
    # macOS 10.15
    LDFLAGS="" make install
else
    make install
fi

msgrcd config keyring-backend test

# Set up config for CLI
msgrcd config chain-id $CHAINID
msgrcd config output json
msgrcd config indent true
msgrcd config trust-node true

# if $KEY exists it should be deleted
msgrcd keys add $KEY

# Set moniker and chain-id for Lsbchain (Moniker can be anything, chain-id must be an integer)
msgrcd init $MONIKER --chain-id $CHAINID

# Change parameter token denominations to lsb
cat $HOME/.msgrc/config/genesis.json | jq '.app_state["staking"]["params"]["bond_denom"]="lsb"' > $HOME/.msgrc/config/tmp_genesis.json && mv $HOME/.msgrc/config/tmp_genesis.json $HOME/.msgrc/config/genesis.json
cat $HOME/.msgrc/config/genesis.json | jq '.app_state["crisis"]["constant_fee"]["denom"]="lsb"' > $HOME/.msgrc/config/tmp_genesis.json && mv $HOME/.msgrc/config/tmp_genesis.json $HOME/.msgrc/config/genesis.json
cat $HOME/.msgrc/config/genesis.json | jq '.app_state["gov"]["deposit_params"]["min_deposit"][0]["denom"]="lsb"' > $HOME/.msgrc/config/tmp_genesis.json && mv $HOME/.msgrc/config/tmp_genesis.json $HOME/.msgrc/config/genesis.json
cat $HOME/.msgrc/config/genesis.json | jq '.app_state["mint"]["params"]["mint_denom"]="lsb"' > $HOME/.msgrc/config/tmp_genesis.json && mv $HOME/.msgrc/config/tmp_genesis.json $HOME/.msgrc/config/genesis.json

# increase block time (?)
cat $HOME/.msgrc/config/genesis.json | jq '.consensus_params["block"]["time_iota_ms"]="30000"' > $HOME/.msgrc/config/tmp_genesis.json && mv $HOME/.msgrc/config/tmp_genesis.json $HOME/.msgrc/config/genesis.json

if [[ $1 == "pending" ]]; then
    echo "pending mode on; block times will be set to 30s."
    sed -i 's/timeout_propose = "3s"/timeout_propose = "30s"/g' $HOME/.msgrc/config/config.toml
    sed -i 's/timeout_propose_delta = "500ms"/timeout_propose_delta = "5s"/g' $HOME/.msgrc/config/config.toml
    sed -i 's/timeout_prevote = "1s"/timeout_prevote = "10s"/g' $HOME/.msgrc/config/config.toml
    sed -i 's/timeout_prevote_delta = "500ms"/timeout_prevote_delta = "5s"/g' $HOME/.msgrc/config/config.toml
    sed -i 's/timeout_precommit = "1s"/timeout_precommit = "10s"/g' $HOME/.msgrc/config/config.toml
    sed -i 's/timeout_precommit_delta = "500ms"/timeout_precommit_delta = "5s"/g' $HOME/.msgrc/config/config.toml
    sed -i 's/timeout_commit = "5s"/timeout_commit = "150s"/g' $HOME/.msgrc/config/config.toml
fi

# Allocate genesis accounts (cosmos formatted addresses)
msgrcd add-genesis-account $(lsbchaincli keys show $KEY -a) 100000000000mst

# Sign genesis transaction
msgrcd gentx --name $KEY --amount=1000000000mst --keyring-backend test

# Collect genesis tx
msgrcd collect-gentxs

# Run this to ensure everything worked and that the genesis file is setup correctly
msgrcd validate-genesis

# Start the node (remove the --pruning=nothing flag if historical queries are not needed)
msgrcd start --pruning=nothing --rpc.unsafe --log_level "main:info,state:info,mempool:info" --trace
