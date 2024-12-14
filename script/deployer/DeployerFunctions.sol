// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {console2 as console} from "@forge-std-v1.9.1/console2.sol";
import { Vm } from "@forge-std-v1.9.1/Vm.sol";

import {IDeployer} from "@superfuse-deploy/deployer/Deployer.sol";
import {DefaultDeployerFunction, DeployOptions} from "@superfuse-deploy/deployer/DefaultDeployerFunction.sol";

import {L2NativeSuperchainERC20} from "@superfuse-core/L2NativeSuperchainERC20.sol";

string constant Artifact_L2NativeSuperchainERC20 = "L2NativeSuperchainERC20.sol:L2NativeSuperchainERC20";

library DeployerFunctions {
        /// @notice Foundry cheatcode VM.
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));


    function deploy_L2NativeSuperchainERC20(IDeployer deployer, string memory name, address owner_, string memory name_, string memory symbol_, uint8 decimals_) internal returns (L2NativeSuperchainERC20) {
        console.log("Deploying L2NativeSuperchainERC20");

        bytes memory args = abi.encode(owner_, name_, symbol_, decimals_);
        return L2NativeSuperchainERC20(DefaultDeployerFunction.deploy(deployer, name, Artifact_L2NativeSuperchainERC20, args));
    }

    function deploy_L2NativeSuperchainERC20(IDeployer deployer, string memory name,address owner_, string memory name_, string memory symbol_, uint8 decimals_, DeployOptions memory options)
        internal
        returns (L2NativeSuperchainERC20)
    {
        console.log("Deploying L2NativeSuperchainERC20");

        bytes memory args = abi.encode(owner_, name_, symbol_, decimals_);
        
        return
            L2NativeSuperchainERC20(DefaultDeployerFunction.deploy(deployer, name, Artifact_L2NativeSuperchainERC20, args, options));
    }

}
