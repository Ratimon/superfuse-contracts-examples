// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Vm} from "@forge-std-v1.9.1/Vm.sol";

import {DeployScript} from "@superfuse-deploy/deployer/DeployScript.sol";
// import {DeployOptions, DeployerFunctions} from "@superfuse-deploy/deployer/DeployerFunctions.sol";

import {DefaultDeployerFunction, DeployOptions} from "@superfuse-deploy/deployer/DefaultDeployerFunction.sol";


import {MyERC20Token} from "@superfuse-core/ERC20Votes.sol";
string constant Artifact_MyERC20Token = "ERC20Votes.sol:MyERC20Token";


contract DeployERC20Script is DeployScript {
    // using DeployerFunctions for IDeployer ;

    MyERC20Token token;
    // string mnemonic = vm.envString("MNEMONIC");
    // uint256 ownerPrivateKey = vm.deriveKey(mnemonic, "m/44'/60'/0'/0/", 1);
    // address owner = vm.envOr("DEPLOYER_ADDRESS", vm.addr(ownerPrivateKey));

    string name = "TestToken";
    string symbol = "TT";

    function deploy() external returns (MyERC20Token) {
        bytes32 _salt = DeployScript.implSalt();

        DeployOptions memory options = DeployOptions({salt:_salt});

        bytes memory args = abi.encode(name, symbol);
        // token = deployer.deploy_MyERC20Token("MyERC20Token",Artifact_MyERC20Token, name, symbol, options);

        return MyERC20Token(DefaultDeployerFunction.deploy(deployer, "MyERC20Token", Artifact_MyERC20Token, args, options));


        return token;
    }
}
