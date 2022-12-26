#!/bin/bash

KEY="messengerchain-local-key"
CHAINID="messengerchain-local"
MONIKER="messengerchain-local-1"

# remove existing daemon and client
rm -rf ~/.messenger*

export GOPROXY=http://goproxy.cn

if [[ "$(uname)" == "Darwin" ]]; then
    # Do something under Mac OS X platform
    # macOS 10.15+
    LDFLAGS="" make install
else
    make install
fi

# if $KEY exists it should be deleted
msgrcd keys add $KEY

# Set moniker and chain-id for msctchain (Moniker can be anything, chain-id must be an integer)
msgrcd init $MONIKER --chain-id $CHAINID

# Change parameter token denominations to mst
cat $HOME/.messenger/config/genesis.json | jq '.app_state["staking"]["params"]["bond_denom"]="umsgt"' > $HOME/.messenger/config/tmp_genesis.json && mv $HOME/.messenger/config/tmp_genesis.json $HOME/.messenger/config/genesis.json
cat $HOME/.messenger/config/genesis.json | jq '.app_state["crisis"]["constant_fee"]["denom"]="umsgt"' > $HOME/.messenger/config/tmp_genesis.json && mv $HOME/.messenger/config/tmp_genesis.json $HOME/.messenger/config/genesis.json
cat $HOME/.messenger/config/genesis.json | jq '.app_state["gov"]["deposit_params"]["min_deposit"][0]["denom"]="umsgt"' > $HOME/.messenger/config/tmp_genesis.json && mv $HOME/.messenger/config/tmp_genesis.json $HOME/.messenger/config/genesis.json
cat $HOME/.messenger/config/genesis.json | jq '.app_state["mint"]["params"]["mint_denom"]="umsgt"' > $HOME/.messenger/config/tmp_genesis.json && mv $HOME/.messenger/config/tmp_genesis.json $HOME/.messenger/config/genesis.json

# increase block time (?)
cat $HOME/.messenger/config/genesis.json | jq '.consensus_params["block"]["time_iota_ms"]="30000"' > $HOME/.messenger/config/tmp_genesis.json && mv $HOME/.messenger/config/tmp_genesis.json $HOME/.messenger/config/genesis.json

if [[ $1 == "pending" ]]; then
    echo "pending mode on; block times will be set to 30s."
    sed -i 's/timeout_propose = "3s"/timeout_propose = "30s"/g' $HOME/.messenger/config/config.toml
    sed -i 's/timeout_propose_delta = "500ms"/timeout_propose_delta = "5s"/g' $HOME/.messenger/config/config.toml
    sed -i 's/timeout_prevote = "1s"/timeout_prevote = "10s"/g' $HOME/.messenger/config/config.toml
    sed -i 's/timeout_prevote_delta = "500ms"/timeout_prevote_delta = "5s"/g' $HOME/.messenger/config/config.toml
    sed -i 's/timeout_precommit = "1s"/timeout_precommit = "10s"/g' $HOME/.messenger/config/config.toml
    sed -i 's/timeout_precommit_delta = "500ms"/timeout_precommit_delta = "5s"/g' $HOME/.messenger/config/config.toml
    sed -i 's/timeout_commit = "5s"/timeout_commit = "150s"/g' $HOME/.messenger/config/config.toml
fi

if [[ "$(uname)" == "Darwin" ]]; then
    # Do something under Mac OS X platform
    # macOS 10.15+
    sed -i "" 's/external_address = ""/external_address = "'$(curl httpbin.org/ip | jq -r .origin)':26656"/g' $HOME/.messenger/config/config.toml
    sed -i "" 's/minimum-gas-prices = "0umsgt"/minimum-gas-prices = "0.15umsgt"/g' $HOME/.messenger/config/app.toml
else
    sed -i 's/external_address = ""/external_address = "'$(curl httpbin.org/ip | jq -r .origin)':26656"/g' $HOME/.messenger/config/config.toml
    sed -i 's/minimum-gas-prices = "0umsgt"/minimum-gas-prices = "0.15umsgt"/g' $HOME/.messenger/config/app.toml
fi


# Allocate genesis accounts (cosmos formatted addresses)
msgrcd add-genesis-account $(msgrcd keys show $KEY -a) 100000000000umsgt

# Sign genesis transaction
msgrcd gentx $KEY 1000000000umsgt --chain-id $CHAINID --keyring-backend os

# Collect genesis tx
msgrcd collect-gentxs

# Run this to ensure everything worked and that the genesis file is setup correctly
msgrcd validate-genesis

# Start the node (remove the --pruning=nothing flag if historical queries are not needed)
msgrcd start --pruning=nothing --rpc.unsafe --trace
