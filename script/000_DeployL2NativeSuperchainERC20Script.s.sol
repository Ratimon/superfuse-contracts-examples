// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Vm} from "@forge-std-v1.9.1/Vm.sol";

import {DeployScript} from "@superfuse-deploy/deployer/DeployScript.sol";

import {DefaultDeployerFunction, DeployOptions} from "@superfuse-deploy/deployer/DefaultDeployerFunction.sol";


import {L2NativeSuperchainERC20} from "@superfuse-core/L2NativeSuperchainERC20.sol";
string constant Artifact_L2NativeSuperchainERC20 = "L2NativeSuperchainERC20.sol:L2NativeSuperchainERC20";


contract DeployL2NativeSuperchainERC20Script is DeployScript {

    L2NativeSuperchainERC20 token;

    string mnemonic = vm.envString("MNEMONIC");
    uint256 ownerPrivateKey = vm.deriveKey(mnemonic, "m/44'/60'/0'/0/", 1);
    address owner = vm.envOr("DEPLOYER_ADDRESS", vm.addr(ownerPrivateKey));

    string name = "TestToken";
    string symbol = "TT";
    uint8 decimals = 18;

    function deploy() external returns (L2NativeSuperchainERC20) {
        bytes32 _salt = DeployScript.implSalt();

        DeployOptions memory options = DeployOptions({salt:_salt});

        bytes memory args = abi.encode(owner, name, symbol, decimals);

        return L2NativeSuperchainERC20(DefaultDeployerFunction.deploy(deployer, "L2NativeSuperchainERC20", Artifact_L2NativeSuperchainERC20, args, options));
    }
}
