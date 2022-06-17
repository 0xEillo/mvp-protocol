// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {Errors} from "../contracts/libs/Errors.sol";

contract WKND is ERC20, Ownable {
    constructor() ERC20("WKND", "WKND") {}

    function mint(address to) public onlyOwner {
        // One user can only mint one token
        if (ERC20(this).balanceOf(to) != 0) {
            revert Errors.AlreadyMinted();
        }
        // can only mint 1 token to an address for voting
        _mint(to, 1);
    }
}
