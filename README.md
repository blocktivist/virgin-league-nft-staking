# Virgin League NFT Staking

This repository contains the smart contracts used for the [Virgin League](https://www.virginleague.com/) NFT staking.

## Requirements

- [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git): run `git --version` to check the existing installation
- [Foundry](https://getfoundry.sh/): run `forge --version` to check the existing installation

## Setup

To clone the repository and install the dependencies, run:

```
git clone https://github.com/blocktivist/virgin-league-nft-staking
cd virgin-league-nft-staking
forge install
forge build
```

## Tests

To test `VirginLeagueStaking.sol`, run:

```
forge test
```

To test a single test function, run:

```
forge test --mt <testFunction> -vvvvv
```

- `testFunction`: the name of the test function without parentheses

To display the test coverage, run:

```
forge coverage
```

To display a gas snapshot, run:

```
forge snapshot
```

## Deployment

To add a `.env` file, run:

```
cp .env.example .env
# add BASE_SEPOLIA_RPC_URL or BASE_RPC_URL
# add BASESCAN_API_KEY
source .env
```

To add a private key, run:

```
cast wallet import baseSepoliaKey --interactive
# or
cast wallet import baseKey --interactive
```

To deploy `VirginLeagueStaking`, set the `run()` function and the local variables in `DeployVirginLeagueStaking.s.sol`, and run:

```
forge script script/DeployVirginLeagueStaking.s.sol --rpc-url $BASE_SEPOLIA_RPC_URL --account baseSepoliaKey --broadcast
# or
forge script script/DeployVirginLeagueStaking.s.sol --rpc-url $BASE_RPC_URL --account baseKey --broadcast
```

To verify a deployed `VirginLeagueStaking` instance, run:

```
forge verify-contract \
--chain-id <chainId> \
--num-of-optimizations 200 \
--watch \
--constructor-args $(cast abi-encode "constructor(address,uint256,string)" <constructorArgs>) \
--etherscan-api-key $BASESCAN_API_KEY \
--compiler-version v0.8.25+commit.b61c2a91 \
<instanceAddress> \
src/VirginLeagueStaking.sol:VirginLeagueStaking
```

- `chainId`: `84532` for Base Sepolia and `8453` for Base Mainnet
- `constructorArgs`: the constructor arguments given the used settings in `DeployVirginLeagueStaking.s.sol` and separated by a single whitespace
- `instanceAddress`: the address of the `VirginLeagueStaking` instance to verify
