<h1>📚Crosschain Smart Contracts Example generated by Superfuse Toolkit 📚</h1>


This repo shows how `Superfuse` works. it includes some examples featuriing **OPStack** interoperability at smart contract level.

These are illustrated by modifying their smart contracts components using our [`Superfuse Wizard`](https://github.com/Ratimon/superfuse-wizard). Then, [`superfuse-forge`](https://github.com/Ratimon/superfuse-forge) could be used to deploy such customized contracts in production.

- [What is it for](#what-is-it-for)
- [How It Works](#how-it-works)
- [Installation](#installation)
- [Quickstart](#quickstart)
- [Contributing](#contributing)
- [Acknowledgement](#acknowledgement)


## What is it for ?

This **cross-chaibn** building block is intended to better introduce and onboard web3 developer into `superchain` 's [interoperability](https://docs.optimism.io/stack/interop/explainer).


While developer experience and security are our top priorities, we aim to provide the developer-focused educational tool, such that the new experimental **dApp** can be quicky bootstapped in **superchain** ecosystem. This greatly align with **Optimism** 's Interoperability roadmap.


## How It Works

`Superfuse` consists of:

1. `Superfuse Wizard` (**Web UI**)

We are building `Superfuse Wizard`, a code generator/ interactive educational playground to customize, mix & match, deploy **Interoperable** dApp .

2. `superfuse-forge` (**Framework/Library**)

We are also developing `redprint-forge`, a modular solidity-based framework to deploy sets of interoperable smart contracts. It works as an engine to:

- Provide type-safe deployment functions. This ensures correct type and order of arguments, enhancing security in smart contract development
- Allow create-2 based deployer  to guarantee the same address across the Superchain
- Save deployment schemas in **json** file
- Separate into each of modular and customizable components
- Provide reusable test suites with All-Solidity-based so no context switching, no new syntax


## Installation

1. Clone the repository:

```bash
git clone git@github.com:Ratimon/superfuse-contracts-examples.git
```

2. Enter to the project directory:

```bash
cd superfuse-contracts-examples
```

3. Select the correct node verison:

```bash
nvm use v20.13.1
```

4. Install the dependencies:

```bash
pnpm i
```

## Quickstart

1. Initialize the environment variables:

```bash
pnpm init:env
```

2. Start the development environment:

```sh
pnpm dev
```

This command will:

- Start the `supersim` local development environment
- Deploy the smart contracts to the two test networks


## Contributing

Adding `remappings.txt` with following line:

```txt
@superfuse-core/=src/
@superfuse-test/=test/
@superfuse-deploy/=script/

@solady-v0.0.158/=lib/solady-v0.0.158/src/
@solady-v0.0.245/=lib/solady-v0.0.245/src/

@openzeppelin-v0.4.7.3/=lib/openzeppelin-v0.4.7.3/contracts/
@openzeppelin-v0.5.0.2/=lib/openzeppelin-v0.5.0.2/contracts/
```


## Acknowledgement

This repository would not have been possible to build without the advanced iniatiative from opensource software including

- [superchainerc20-starter](https://github.com/ethereum-optimism/superchainerc20-starter)
- [supersim](https://github.com/ethereum-optimism/supersim)

So, we are deeply thankful for their contributions in our web3 ecosystem.

If we’ve overlooked anyone, please open an issue so we can correct it. While we always aim to acknowledge the inspirations and code we utilize, mistakes can happen in a team setting, and a reference might unintentionally be missed.