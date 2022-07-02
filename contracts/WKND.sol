// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Errors} from "../contracts/libs/Errors.sol";

import "hardhat/console.sol";

contract WKND is ERC20 {
    mapping(address => bool) public hasMinted;

    constructor() ERC20("WKND", "WKND") {
        // 6000000 is the population of Wakanda
        _mint(address(this), 6000000);
    }

    function claim(address to) public {
        if (this.balanceOf(address(this)) == 0)
            revert Errors.AllTokensClaimed();
        // One user can only mint one token
        if (hasMinted[to] == true) revert Errors.HasClaimed();

        hasMinted[to] = true;

        // can only mint 1 token to an address for voting
        _transfer(address(this), to, 1);
    }
}
