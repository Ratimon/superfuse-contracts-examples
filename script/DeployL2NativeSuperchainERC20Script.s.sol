// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Vm} from "@forge-std-v1.9.1/Vm.sol";

import {DeployScript, IDeployer} from "@superfuse-deploy/deployer/DeployScript.sol";
import {DeployOptions, DeployerFunctions} from "@superfuse-deploy/deployer/DeployerFunctions.sol";

import {L2NativeSuperchainERC20} from "@superfuse-core/L2NativeSuperchainERC20.sol";
// import {Types} from "from@superfuse-deploy/optimism/Types.sol";


contract DeployL2NativeSuperchainERC20Script is DeployScript {
    using DeployerFunctions for IDeployer ;

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

        token = deployer.deploy_L2NativeSuperchainERC20("L2NativeSuperchainERC20",owner, name, symbol, decimals, options);

        return token;
    }
}
