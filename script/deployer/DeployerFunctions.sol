// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {console2 as console} from "@forge-std-v1.9.1/console2.sol";
import { Vm } from "@forge-std-v1.9.1/Vm.sol";

import {IDeployer} from "@superfuse-deploy/deployer/Deployer.sol";
import {DefaultDeployerFunction, DeployOptions} from "@superfuse-deploy/deployer/DefaultDeployerFunction.sol";

string constant Artifact_L2NativeSuperchainERC20 = "L2NativeSuperchainERC20.sol:L2NativeSuperchainERC20";
