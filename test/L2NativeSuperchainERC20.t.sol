// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {console} from "@forge-std-v1.9.1/console.sol";

// Testing utilities
import {Test} from "@forge-std-v1.9.1/Test.sol";

// Libraries
import {Predeploys} from "@superfuse-core/libraries/Predeploys.sol";
import {IERC20} from "@openzeppelin-v0.5.0.2/token/ERC20/IERC20.sol";

// Target contract
import {SuperchainERC20} from "@superfuse-core/L2/SuperchainERC20.sol";
import {IERC7802} from "@superfuse-core/interfaces/L2/IERC7802.sol";
import {ISuperchainERC20} from "@superfuse-core/interfaces/L2/ISuperchainERC20.sol";
import {L2NativeSuperchainERC20} from "@superfuse-core/L2NativeSuperchainERC20.sol";

import {IDeployer, getDeployer} from "@superfuse-deploy/deployer/DeployScript.sol";
import {DeployL2NativeSuperchainERC20Script} from "@script/DeployL2NativeSuperchainERC20Script.s.sol";


// lib for native cross chain 
import {IOwnable} from "@contracts-bedrock/universal/interfaces/IOwnable.sol";

import {ERC20} from "@solady-v0.0.245/tokens/ERC20.sol";
import {Ownable} from "@solady-v0.0.245/auth/Ownable.sol";

/// @title SuperchainERC20Test
/// @notice Contract for testing the SuperchainERC20 contract.
contract L2NativeSuperchainERC20Test is Test {

    string mnemonic = vm.envString("MNEMONIC");
    uint256 ownerPrivateKey = vm.deriveKey(mnemonic, "m/44'/60'/0'/0/", 1); //  address = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8
    address owner = vm.envOr("DEPLOYER", vm.addr(ownerPrivateKey));
    address alice;
    address bob;


    IDeployer deployerProcedue;

    address internal constant ZERO_ADDRESS = address(0);
    address internal constant SUPERCHAIN_TOKEN_BRIDGE = Predeploys.SUPERCHAIN_TOKEN_BRIDGE;
    address internal constant MESSENGER = Predeploys.L2_TO_L2_CROSS_DOMAIN_MESSENGER;

    // SuperchainERC20 public superchainERC20;
    L2NativeSuperchainERC20 public superchainERC20;

    /// @notice Sets up the test suite.
    function setUp() public {

        alice = makeAddr("alice");
        bob = makeAddr("bob");

        deployerProcedue = getDeployer();
        deployerProcedue.setAutoBroadcast(false);

        console.log("Setup Superchain ERC20 ... ");

        DeployL2NativeSuperchainERC20Script superchainERC20Deployments = new DeployL2NativeSuperchainERC20Script();
        superchainERC20 = superchainERC20Deployments.deploy();

        deployerProcedue.deactivatePrank();

    }

    /// @notice Helper function to setup a mock and expect a call to it.
    function _mockAndExpect(address _receiver, bytes memory _calldata, bytes memory _returned) internal {
        vm.mockCall(_receiver, _calldata, _returned);
        vm.expectCall(_receiver, _calldata);
    }

    // cross chain logic

    /// @notice Tests the `mint` function reverts when the caller is not the bridge.
    function testFuzz_crosschainMint_callerNotBridge_reverts(address _caller, address _to, uint256 _amount) public {
        // Ensure the caller is not the bridge
        vm.assume(_caller != SUPERCHAIN_TOKEN_BRIDGE);

        // Expect the revert with `Unauthorized` selector
        vm.expectRevert(ISuperchainERC20.Unauthorized.selector);

        // Call the `mint` function with the non-bridge caller
        vm.prank(_caller);
        superchainERC20.crosschainMint(_to, _amount);
    }

    /// @notice Tests the `mint` succeeds and emits the `Mint` event.
    function testFuzz_crosschainMint_succeeds(address _to, uint256 _amount) public {
        // Ensure `_to` is not the zero address
        vm.assume(_to != ZERO_ADDRESS);

        // Get the total supply and balance of `_to` before the mint to compare later on the assertions
        uint256 _totalSupplyBefore = superchainERC20.totalSupply();
        uint256 _toBalanceBefore = superchainERC20.balanceOf(_to);

        // Look for the emit of the `Transfer` event
        vm.expectEmit(address(superchainERC20));
        emit IERC20.Transfer(ZERO_ADDRESS, _to, _amount);

        // Look for the emit of the `CrosschainMint` event
        vm.expectEmit(address(superchainERC20));
        emit IERC7802.CrosschainMint(_to, _amount, SUPERCHAIN_TOKEN_BRIDGE);

        // Call the `mint` function with the bridge caller
        vm.prank(SUPERCHAIN_TOKEN_BRIDGE);
        superchainERC20.crosschainMint(_to, _amount);

        // Check the total supply and balance of `_to` after the mint were updated correctly
        assertEq(superchainERC20.totalSupply(), _totalSupplyBefore + _amount);
        assertEq(superchainERC20.balanceOf(_to), _toBalanceBefore + _amount);
    }

    /// @notice Tests the `burn` function reverts when the caller is not the bridge.
    function testFuzz_crosschainBurn_callerNotBridge_reverts(address _caller, address _from, uint256 _amount) public {
        // Ensure the caller is not the bridge
        vm.assume(_caller != SUPERCHAIN_TOKEN_BRIDGE);

        // Expect the revert with `Unauthorized` selector
        vm.expectRevert(ISuperchainERC20.Unauthorized.selector);

        // Call the `burn` function with the non-bridge caller
        vm.prank(_caller);
        superchainERC20.crosschainBurn(_from, _amount);
    }

    /// @notice Tests the `burn` burns the amount and emits the `CrosschainBurn` event.
    function testFuzz_crosschainBurn_succeeds(address _from, uint256 _amount) public {
        // Ensure `_from` is not the zero address
        vm.assume(_from != ZERO_ADDRESS);

        // Mint some tokens to `_from` so then they can be burned
        vm.prank(SUPERCHAIN_TOKEN_BRIDGE);
        superchainERC20.crosschainMint(_from, _amount);

        // Get the total supply and balance of `_from` before the burn to compare later on the assertions
        uint256 _totalSupplyBefore = superchainERC20.totalSupply();
        uint256 _fromBalanceBefore = superchainERC20.balanceOf(_from);

        // Look for the emit of the `Transfer` event
        vm.expectEmit(address(superchainERC20));
        emit IERC20.Transfer(_from, ZERO_ADDRESS, _amount);

        // Look for the emit of the `CrosschainBurn` event
        vm.expectEmit(address(superchainERC20));
        emit IERC7802.CrosschainBurn(_from, _amount, SUPERCHAIN_TOKEN_BRIDGE);

        // Call the `burn` function with the bridge caller
        vm.prank(SUPERCHAIN_TOKEN_BRIDGE);
        superchainERC20.crosschainBurn(_from, _amount);

        // Check the total supply and balance of `_from` after the burn were updated correctly
        assertEq(superchainERC20.totalSupply(), _totalSupplyBefore - _amount);
        assertEq(superchainERC20.balanceOf(_from), _fromBalanceBefore - _amount);
    }

    // main logic

    /// @notice Tests the metadata of the token is set correctly.
    function testMetadata() public view {
        assertEq(superchainERC20.name(), "TestToken");
        assertEq(superchainERC20.symbol(), "TT");
        assertEq(superchainERC20.decimals(), 18);
    }

    /// @notice Tests that owner can mint tokens to an address.
    function testFuzz_mintTo_succeeds(address _to, uint256 _amount) public {
        vm.expectEmit(true, true, true, true);
        emit IERC20.Transfer(address(0), _to, _amount);

        vm.prank(owner);
        superchainERC20.mintTo(_to, _amount);

        assertEq(superchainERC20.totalSupply(), _amount);
        assertEq(superchainERC20.balanceOf(_to), _amount);
    }

    /// @notice Tests the mintTo function reverts when the caller is not the owner.
    function testFuzz_mintTo_succeeds(address _minter, address _to, uint256 _amount) public {
        vm.assume(_minter != owner);

        // Expect the revert with `Unauthorized` selector
        vm.expectRevert(Ownable.Unauthorized.selector);

        vm.prank(_minter);
        superchainERC20.mintTo(_to, _amount);
    }

    /// @notice Tests that ownership of the token can be renounced.
    function testRenounceOwnership() public {
        vm.expectEmit(true, true, true, true);
        emit IOwnable.OwnershipTransferred(owner, address(0));

        vm.prank(owner);
        superchainERC20.renounceOwnership();
        assertEq(superchainERC20.owner(), address(0));
    }

    /// @notice Tests that ownership of the token can be transferred.
    function testFuzz_testTransferOwnership(address _newOwner) public {
        vm.assume(_newOwner != owner);
        vm.assume(_newOwner != ZERO_ADDRESS);

        vm.expectEmit(true, true, true, true);
        emit IOwnable.OwnershipTransferred(owner, _newOwner);

        vm.prank(owner);
        superchainERC20.transferOwnership(_newOwner);

        assertEq(superchainERC20.owner(), _newOwner);
    }

    /// @notice Tests that tokens can be transferred using the transfer function.
    function testFuzz_transfer_succeeds(address _sender, uint256 _amount) public {
        vm.assume(_sender != ZERO_ADDRESS);
        vm.assume(_sender != bob);

        vm.prank(owner);
        superchainERC20.mintTo(_sender, _amount);

        vm.expectEmit(true, true, true, true);
        emit IERC20.Transfer(_sender, bob, _amount);

        vm.prank(_sender);
        assertTrue(superchainERC20.transfer(bob, _amount));
        assertEq(superchainERC20.totalSupply(), _amount);

        assertEq(superchainERC20.balanceOf(_sender), 0);
        assertEq(superchainERC20.balanceOf(bob), _amount);
    }

    /// @notice Tests that tokens can be transferred using the transferFrom function.
    function testFuzz_transferFrom_succeeds(address _spender, uint256 _amount) public {
        vm.assume(_spender != ZERO_ADDRESS);
        vm.assume(_spender != bob);
        vm.assume(_spender != alice);

        vm.prank(owner);
        superchainERC20.mintTo(bob, _amount);

        vm.prank(bob);
        superchainERC20.approve(_spender, _amount);

        vm.prank(_spender);
        vm.expectEmit(true, true, true, true);
        emit IERC20.Transfer(bob, alice, _amount);
        assertTrue(superchainERC20.transferFrom(bob, alice, _amount));

        assertEq(superchainERC20.balanceOf(bob), 0);
        assertEq(superchainERC20.balanceOf(alice), _amount);
    }

    /// @notice tests that an insufficient balance cannot be transferred.
    function testFuzz_transferInsufficientBalance_reverts(address _to, uint256 _mintAmount, uint256 _sendAmount)
        public
    {
        vm.assume(_mintAmount < type(uint256).max);
        _sendAmount = bound(_sendAmount, _mintAmount + 1, type(uint256).max);

        vm.prank(owner);
        superchainERC20.mintTo(address(this), _mintAmount);

        vm.expectRevert(ERC20.InsufficientBalance.selector);
        superchainERC20.transfer(_to, _sendAmount);
    }

    /// @notice tests that an insufficient allowance cannot be transferred.
    function testFuzz_transferFromInsufficientAllowance_reverts(
        address _to,
        address _from,
        uint256 _approval,
        uint256 _amount
    ) public {
        vm.assume(_from != ZERO_ADDRESS);
        vm.assume(_approval < type(uint256).max);
        _amount = _bound(_amount, _approval + 1, type(uint256).max);

        vm.prank(owner);
        superchainERC20.mintTo(_from, _amount);

        vm.prank(_from);
        superchainERC20.approve(address(this), _approval);

        vm.expectRevert(ERC20.InsufficientAllowance.selector);
        superchainERC20.transferFrom(_from, _to, _amount);
    }
}
