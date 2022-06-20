// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {Errors} from "../contracts/libs/Errors.sol";

contract WKND is ERC20, Ownable {
    constructor() ERC20("WKND", "WKND") {}

    mapping(address => bool) public hasMinted;

    function mint(address to) public {
        // One user can only mint one token
        if (hasMinted[to] == true) {
            revert Errors.AlreadyMinted();
        }
        hasMinted[to] = true;
        // can only mint 1 token to an address for voting
        _mint(to, 1);
    }
}
