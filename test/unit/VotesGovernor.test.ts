import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { candidatesList } from "../utils/candidatesListTest";
// We import Chai to use its asserting functions here.
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("VotesGovernor Contract", function () {
  let VotesGovernor: any;
  let votesGovernor: any;
  let Token: any;
  let token: any;

  // accounts
  let deployer: SignerWithAddress,
    account1: SignerWithAddress,
    account2: SignerWithAddress,
    account3: SignerWithAddress;

  beforeEach(async function () {
    // Get the ContractFactory and Signers here.
    Token = await ethers.getContractFactory("WKND");
    VotesGovernor = await ethers.getContractFactory("VotesGovernor");
    [deployer, account1, account2, account3] = await ethers.getSigners();
    token = await Token.deploy();
    votesGovernor = await VotesGovernor.deploy(token.address);
  });

  describe("Success cases", function () {
    this.beforeEach(async function () {
      await votesGovernor.connect(deployer).addCandidates(candidatesList);
      await token.connect(account1).claim(account1.address);
      await token.connect(account2).claim(account2.address);
      await token.connect(account3).claim(account3.address);
    });

    it("Should add a list of candidates to the contract", async function () {
      let list = await votesGovernor._candidates(0);
      expect(list.id).to.equal(candidatesList[0].id + 1);
      expect(list.name).to.equal(candidatesList[0].name);
      expect(list.age).to.equal(candidatesList[0].age);
      expect(list.cult).to.equal(candidatesList[0].cult);
      expect(list.votes).to.equal(0);
    });
    it("Should vote for a candidate", async function () {
      expect((await votesGovernor._candidates(0))[4]).to.equal(0);
      await votesGovernor.connect(account1).vote(1, 1);
      expect((await votesGovernor._candidates(0))[4]).to.equal(1);
    });

    it("Should test the voting, the sorting and the retrieved winners", async function () {
      let tx1 = await votesGovernor.connect(account1).winningCandidates();
      await expect(tx1[0].votes).to.equal(0);
      await expect(tx1[1].votes).to.equal(0);
      await expect(tx1[2].votes).to.equal(0);
      expect(await votesGovernor.connect(account1).vote(1, 1)).to.emit(
        VotesGovernor,
        "NewChallenger"
      );
      expect(await votesGovernor.connect(account2).vote(1, 1)).to.emit(
        VotesGovernor,
        "NewChallenger"
      );
      expect(await votesGovernor.connect(account3).vote(2, 1)).to.emit(
        VotesGovernor,
        "NewChallenger"
      );
      let tx2 = await votesGovernor.connect(account1).winningCandidates();
      await expect(tx2[0].votes).to.equal(2);
      await expect(tx2[1].votes).to.equal(1);
      await expect(tx2[2].votes).to.equal(0);
    });
  });
  describe("Revert cases", function () {
    it("Should attempt to vote with no candidates signed up", async function () {
      await token.connect(deployer).claim(account1.address);
      await expect(
        votesGovernor.connect(account1).vote(1, 1)
      ).to.be.revertedWith("NoCandidatesSignedUp()");
    });
    it("Should attempt to vote without a token", async function () {
      const tokenBalance = await token.balanceOf(account1.address);
      await votesGovernor.connect(deployer).addCandidates(candidatesList);
      await expect(
        votesGovernor.connect(account1).vote(1, 1)
      ).to.be.revertedWith(`InsufficientTokenBalance(${tokenBalance}, 1)`);
    });
    it("Should attempt to vote more times than tokens owned", async function () {
      await token.connect(deployer).claim(account1.address);
      const tokenBalance = await token.balanceOf(account1.address);
      await votesGovernor.connect(deployer).addCandidates(candidatesList);
      await expect(
        votesGovernor.connect(account1).vote(1, 100)
      ).to.be.revertedWith(`InsufficientTokenBalance(${tokenBalance}, 100)`);
    });
    it("Should attempt to vote for a wrong id", async function () {
      await token.connect(deployer).claim(account1.address);
      await votesGovernor.connect(deployer).addCandidates(candidatesList);
      await expect(
        votesGovernor.connect(account1).vote(100, 1)
      ).to.be.revertedWith("InvalidId(100)");
    });
  });
});
