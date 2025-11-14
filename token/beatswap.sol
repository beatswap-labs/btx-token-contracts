// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.5.0
pragma solidity ^0.8.27;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract BeatSwap is ERC20, ERC20Burnable {
    constructor(address recipient) ERC20("BeatSwap", "BTX") {
        _mint(recipient, 1500000000 * 10 ** decimals());
    }
}