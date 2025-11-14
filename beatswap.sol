// SPDX-License-Identifier: MIT
// BeatSwap (BTX) — ERC20 token with a predefined total supply.
// Key characteristics:
// • No owner or privileged roles
// • No additional minting after deployment
// • Optional burn functionality for holders
//
// Compatible with OpenZeppelin Contracts ^5.5.0

pragma solidity ^0.8.27;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract BeatSwap is ERC20, ERC20Burnable {
    constructor(address recipient) ERC20("BeatSwap", "BTX") {
        _mint(recipient, 1_500_000_000 * 10 ** decimals());
    }
}

