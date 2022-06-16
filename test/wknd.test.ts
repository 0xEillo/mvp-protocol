import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { Signer } from "ethers";

// We import Chai to use its asserting functions here.
const { expect } = require("chai");
const { ethers } = require("hardhat");


describe("Token contract", function () {

    let Token: any;
    let token: any;

    // accounts
    let deployer: SignerWithAddress, account1: SignerWithAddress, account2: SignerWithAddress

  beforeEach(async function () {
    // Get the ContractFactory and Signers here.
    Token = await ethers.getContractFactory("WKND");
    [deployer, account1, account2] = await ethers.getSigners();
    token = await Token.deploy();
  });

  describe("WKND", function () {
  
    it("Owner should mint a token to a voter ", async function () {
        expect(await token.balanceOf(account1.address)).to.equal(0);
        await token.connect(deployer).mint(account1.address);
        expect(await token.balanceOf(account1.address)).to.equal(1);
    });
    it("Voter should attempt to mint a token, reverts due to not being the owner ", async function () {
        await expect(token.connect(account1).mint(account1.address)).to.be.revertedWith("Ownable: caller is not the owner")
    });
  });
});