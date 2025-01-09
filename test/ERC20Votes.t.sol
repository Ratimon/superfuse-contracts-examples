// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {DeployMyERC20VotesScript} from "@script/001_DeployMyERC20VotesScript.s.sol";
import {IDeployer, getDeployer} from "@superfuse-deploy/deployer/DeployScript.sol";
import {IERC20} from "@openzeppelin-v0.5.0.2/token/ERC20/IERC20.sol";
import {IERC7802} from "@superfuse-core/interfaces/L2/IERC7802.sol";
import {ISuperchainERC20} from "@superfuse-core/interfaces/L2/ISuperchainERC20.sol";
import {MyERC20Votes} from "@main/MyERC20Votes.sol";
import {Predeploys} from "@superfuse-core/libraries/Predeploys.sol";
import {SuperchainERC20} from "@superfuse-core/L2/SuperchainERC20.sol";
import {Test} from "@forge-std-v1.9.1/Test.sol";
import {console} from "@forge-std-v1.9.1/console.sol";

contract ERC20VotesTest is Test {
    address alice;
    address bob;
    IDeployer deployerProcedue;
    address internal constant ZERO_ADDRESS = address(0);
    address internal constant SUPERCHAIN_TOKEN_BRIDGE = Predeploys.SUPERCHAIN_TOKEN_BRIDGE;
    address internal constant MESSENGER = Predeploys.L2_TO_L2_CROSS_DOMAIN_MESSENGER;
    MyERC20Votes public superchainERC20;
    string mnemonic = vm.envString("MNEMONIC");
    uint256 ownerPrivateKey = vm.deriveKey(mnemonic, "m/44'/60'/0'/0/", 1);
    address owner = vm.envOr("DEPLOYER_ADDRESS", vm.addr(ownerPrivateKey));

    function setUp() public {
        alice = makeAddr("alice");
        bob = makeAddr("bob");

        deployerProcedue = getDeployer();
        deployerProcedue.setAutoBroadcast(false);

        console.log("Setup MyERC20Votes ... ");

        DeployMyERC20VotesScript superchainERC20Deployments = new DeployMyERC20VotesScript();
        superchainERC20 = superchainERC20Deployments.deploy();

        deployerProcedue.deactivatePrank();
    }

    function test_constructor() public view {
        assertEq(superchainERC20.name(), "TestToken");
        assertEq(superchainERC20.symbol(), "TT");
    }

    function _mockAndExpect(address _receiver, bytes memory _calldata, bytes memory _returned)
        internal
    {
        vm.mockCall(_receiver, _calldata, _returned);
        vm.expectCall(_receiver, _calldata);
    }

    function testFuzz_crosschainMint_callerNotBridge_reverts(address _caller, address _to, uint256 _amount)
        public
    {
        // Ensure the caller is not the bridge
        vm.assume(_caller != SUPERCHAIN_TOKEN_BRIDGE);

        // Expect the revert with 'Unauthorized' selector
        vm.expectRevert(ISuperchainERC20.Unauthorized.selector);

        // Call the 'mint' function with the non-bridge caller
        vm.prank(_caller);
        superchainERC20.crosschainMint(_to, _amount);
    }

    function testFuzz_crosschainMint_succeeds(address _to, uint256 _amount)
        public
    {
        // Ensure '_to' is not the zero address
        vm.assume(_to != ZERO_ADDRESS);

        _amount = bound(_amount, 0, type(uint208).max);

        // Get the total supply and balance of '_to' before the mint to compare later on the assertions
        uint256 _totalSupplyBefore = superchainERC20.totalSupply();
        uint256 _toBalanceBefore = superchainERC20.balanceOf(_to);

        // Look for the emit of the 'Transfer' event
        vm.expectEmit(address(superchainERC20));
        emit IERC20.Transfer(ZERO_ADDRESS, _to, _amount);

        // Look for the emit of the 'CrosschainMint' event
        vm.expectEmit(address(superchainERC20));
        emit IERC7802.CrosschainMint(_to, _amount, SUPERCHAIN_TOKEN_BRIDGE);

        // Call the 'mint' function with the bridge caller
        vm.prank(SUPERCHAIN_TOKEN_BRIDGE);
        superchainERC20.crosschainMint(_to, _amount);

        // Check the total supply and balance of '_to' after the mint were updated correctly
        assertEq(superchainERC20.totalSupply(), _totalSupplyBefore + _amount);
        assertEq(superchainERC20.balanceOf(_to), _toBalanceBefore + _amount);
    }

    function testFuzz_crosschainBurn_callerNotBridge_reverts(address _caller, address _from, uint256 _amount)
        public
    {
        /// Ensure the caller is not the bridge
        vm.assume(_caller != SUPERCHAIN_TOKEN_BRIDGE);

        // Expect the revert with 'Unauthorized' selector
        vm.expectRevert(ISuperchainERC20.Unauthorized.selector);

        // Call the 'burn' function with the non-bridge caller
        vm.prank(_caller);
        superchainERC20.crosschainBurn(_from, _amount);
    }

    function testFuzz_crosschainBurn_succeeds(address _from, uint256 _amount)
        public
    {
        // Ensure '_from' is not the zero address
        vm.assume(_from != ZERO_ADDRESS);

        _amount = bound(_amount, 0, type(uint208).max);

        // Mint some tokens to '_from' so then they can be burned
        vm.prank(SUPERCHAIN_TOKEN_BRIDGE);
        superchainERC20.crosschainMint(_from, _amount);

        // Get the total supply and balance of '_from' before the burn to compare later on the assertions
        uint256 _totalSupplyBefore = superchainERC20.totalSupply();
        uint256 _fromBalanceBefore = superchainERC20.balanceOf(_from);

        // Look for the emit of the 'Transfer' event
        vm.expectEmit(address(superchainERC20));
        emit IERC20.Transfer(_from, ZERO_ADDRESS, _amount);

        // Look for the emit of the 'CrosschainBurn' event
        vm.expectEmit(address(superchainERC20));
        emit IERC7802.CrosschainBurn(_from, _amount, SUPERCHAIN_TOKEN_BRIDGE);

        // Call the 'burn' function with the bridge caller
        vm.prank(SUPERCHAIN_TOKEN_BRIDGE);
        superchainERC20.crosschainBurn(_from, _amount);

        // Check the total supply and balance of '_from' after the burn were updated correctly
        assertEq(superchainERC20.totalSupply(), _totalSupplyBefore - _amount);
        assertEq(superchainERC20.balanceOf(_from), _fromBalanceBefore - _amount);
    }
}
