// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Vm} from "@forge-std-v1.9.1/Vm.sol";

import {DeployScript} from "@superfuse-deploy/deployer/DeployScript.sol";

import {DefaultDeployerFunction, DeployOptions} from "@superfuse-deploy/deployer/DefaultDeployerFunction.sol";


import {MyERC20Token} from "@superfuse-core/ERC20Votes.sol";
string constant Artifact_MyERC20Token = "ERC20Votes.sol:MyERC20Token";


contract DeployERC20Script is DeployScript {

    MyERC20Token token;

    string name = "TestToken";
    string symbol = "TT";

    function deploy() external returns (MyERC20Token) {
        bytes32 _salt = DeployScript.implSalt();

        DeployOptions memory options = DeployOptions({salt:_salt});

        bytes memory args = abi.encode(name, symbol);

        return MyERC20Token(DefaultDeployerFunction.deploy(deployer, "MyERC20Token", Artifact_MyERC20Token, args, options));
    }
}
