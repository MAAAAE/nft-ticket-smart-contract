# nft-ticket-smart-contract

## install aptos
```sh
brew update
brew install aptos
```

## Set Local Net profile
```sh
aptos init --profile local

Choose network from [devnet, testnet, mainnet, local, custom | defaults to devnet]
local
```
- Save address that is returned from the aptos

## Up Local Net
```sh
aptos node run-local-testnet --with-indexer-api
```

## Deploy Smart Contract to Local Net
Change to your address in Move.toml
```toml 
[addresses]
ticket = "<YOUR_ADDRESS>"
```

Deploy smart contract to local net
```sh
aptos move publish --profile local
```

## Test
TBD