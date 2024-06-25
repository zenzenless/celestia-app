#!/bin/bash

# This script starts core0

if [[ ! -f /opt/data/priv_validator_state.json ]]
then
    mkdir /opt/data
    cat <<EOF > /opt/data/priv_validator_state.json
{
  "height": "0",
  "round": 0,
  "step": 0
}
EOF
fi

#Initialize a working directory
VALIDATOR_NAME=core0
CHAIN_ID=private
/bin/celestia-appd init $VALIDATOR_NAME --chain-id $CHAIN_ID


#Create a new key
KEY_NAME=core0
celestia-appd keys add $KEY_NAME --keyring-backend test
celestia-appd keys add core1 --keyring-backend test
celestia-appd keys add core2 --keyring-backend test
celestia-appd keys add core3 --keyring-backend test

#Add genesis account KeyName

TIA_AMOUNT="6000000000utia"
celestia-appd add-genesis-account $KEY_NAME $TIA_AMOUNT --keyring-backend test
celestia-appd add-genesis-account core1 $TIA_AMOUNT --keyring-backend test
celestia-appd add-genesis-account core2 $TIA_AMOUNT --keyring-backend test
celestia-appd add-genesis-account core3 $TIA_AMOUNT --keyring-backend test

#Create the genesis transaction for new chain
STAKING_AMOUNT=5000000000utia
celestia-appd gentx $KEY_NAME $STAKING_AMOUNT --chain-id $CHAIN_ID \
  --keyring-backend test --gas-prices 0.0001utia

#Creating the genesis JSON file
celestia-appd collect-gentxs

celestia-appd tendermint show-node-id > /home/celestia/.celestia-app/node-id
cp -r /home/celestia/.celestia-app/* /core0_dir


/bin/celestia-appd start \
  --moniker core0 \
  --rpc.laddr tcp://0.0.0.0:26657 \
  --grpc.enable true
