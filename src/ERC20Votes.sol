// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

import { IERC7802, IERC165 } from "@superfuse-core/interfaces/L2/IERC7802.sol";
import {Predeploys} from "@superfuse-core/libraries/Predeploys.sol";

import { Unauthorized } from "@superfuse-core//libraries/errors/CommonErrors.sol";

import { IERC20 } from "@openzeppelin-v0.5.0.2/token/ERC20/IERC20.sol";
import {ERC20} from "@openzeppelin-v0.5.0.2/token/ERC20/ERC20.sol";
import {ERC20Permit} from "@openzeppelin-v0.5.0.2/token/ERC20/extensions/ERC20Permit.sol";
import {ERC20Votes} from "@openzeppelin-v0.5.0.2/token/ERC20/extensions/ERC20Votes.sol";
import {Nonces} from "@openzeppelin-v0.5.0.2/utils/Nonces.sol";

contract MyERC20VotesToken is IERC7802, ERC20, ERC20Permit, ERC20Votes {

    // to do : modify code geneerator to compatible with superfuse
    // constructor() ERC20("MyToken", "MTK") ERC20Permit("MyToken") {}
    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) ERC20Permit(name_) {

    }


    /// @notice Allows the SuperchainTokenBridge to mint tokens.
    /// @param _to     Address to mint tokens to.
    /// @param _amount Amount of tokens to mint.
    function crosschainMint(address _to, uint256 _amount) external {
        // Only the `SuperchainTokenBridge` has permissions to mint tokens during crosschain transfers.
        if (msg.sender != Predeploys.SUPERCHAIN_TOKEN_BRIDGE) revert Unauthorized();
        
        // Mint tokens to the `_to` account's balance.
        _mint(_to, _amount);

        // Emit the CrosschainMint event included on IERC7802 for tracking token mints associated with cross chain transfers.
        emit CrosschainMint(_to, _amount, msg.sender);
    }

    /// @notice Allows the SuperchainTokenBridge to burn tokens.
    /// @param _from   Address to burn tokens from.
    /// @param _amount Amount of tokens to burn.
    function crosschainBurn(address _from, uint256 _amount) external {
        // Only the `SuperchainTokenBridge` has permissions to burn tokens during crosschain transfers.
        if (msg.sender != Predeploys.SUPERCHAIN_TOKEN_BRIDGE) revert Unauthorized();

        // Burn the tokens from the `_from` account's balance.
        _burn(_from, _amount);

        // Emit the CrosschainBurn event included on IERC7802 for tracking token burns associated with cross chain transfers.
        emit CrosschainBurn(_from, _amount, msg.sender);
    }

    /// @inheritdoc IERC165
    function supportsInterface(bytes4 _interfaceId) public view virtual returns (bool) {
        return _interfaceId == type(IERC7802).interfaceId || _interfaceId == type(IERC20).interfaceId
            || _interfaceId == type(IERC165).interfaceId;
    }


    // The following functions are overrides required by Solidity.

    function _update(address from, address to, uint256 value)
        internal
        override(ERC20, ERC20Votes)
    {
        super._update(from, to, value);
    }

    function nonces(address owner)
        public
        view
        override(ERC20Permit, Nonces)
        returns (uint256)
    {
        return super.nonces(owner);
    }
}
