// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Vm} from "@forge-std-v1.9.1/Vm.sol";

import {DeployScript} from "@superfuse-deploy/deployer/DeployScript.sol";

import {DefaultDeployerFunction, DeployOptions} from "@superfuse-deploy/deployer/DefaultDeployerFunction.sol";

import {MyERC20Votes} from "@main/ERC20Votes.sol";
string constant Artifact_MyERC20Token = "ERC20Votes.sol:MyERC20Votes";

contract DeployERC20VotesScript is DeployScript {

    MyERC20Votes token;

    string name = "TestToken";
    string symbol = "TT";

    function deploy() external returns (MyERC20Votes) {
        bytes32 _salt = DeployScript.implSalt();

        DeployOptions memory options = DeployOptions({salt:_salt});

        bytes memory args = abi.encode(name, symbol);

        return MyERC20Votes(DefaultDeployerFunction.deploy(deployer, "MyERC20Votes", Artifact_MyERC20Token, args, options));
    }
}
