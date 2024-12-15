// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

import {ERC20} from "@openzeppelin-v0.5.0.2/token/ERC20/ERC20.sol";
import {ERC20Permit} from "@openzeppelin-v0.5.0.2/token/ERC20/extensions/ERC20Permit.sol";
import {ERC20Votes} from "@openzeppelin-v0.5.0.2/token/ERC20/extensions/ERC20Votes.sol";
import {Nonces} from "@openzeppelin-v0.5.0.2/utils/Nonces.sol";

contract MyERC20Token is ERC20, ERC20Permit, ERC20Votes {

    // to do : modify code geneerator to compatible with superfuse
    // constructor() ERC20("MyToken", "MTK") ERC20Permit("MyToken") {}
    
    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) ERC20Permit(name_) {

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
