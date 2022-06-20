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
  let deployer: SignerWithAddress;
  let acc1: SignerWithAddress;
  let acc2: SignerWithAddress;
  let acc3: SignerWithAddress;
  let acc4: SignerWithAddress;
  let acc5: SignerWithAddress;
  let acc6: SignerWithAddress;
  let acc7: SignerWithAddress;
  let acc8: SignerWithAddress;
  let acc9: SignerWithAddress;

  beforeEach(async function () {
    // Get the ContractFactory and Signers here.
    Token = await ethers.getContractFactory("WKND");
    VotesGovernor = await ethers.getContractFactory("VotesGovernor");
    [deployer, acc1, acc2, acc3, acc4, acc5, acc6, acc7, acc8] =
      await ethers.getSigners();
    token = await Token.deploy();
    votesGovernor = await VotesGovernor.deploy(token.address);
  });

  describe("full", function () {
    this.beforeEach(async function () {
      await votesGovernor.connect(deployer).addCandidates(candidatesList);
    });

    it("Should vote multiple times for different candidates and check the leaderboard", async function () {
      const [, acc1, acc2, acc3, acc4, acc5, acc6, acc7, acc8] =
        await ethers.getSigners();
      let accountList = [acc1, acc2, acc3, acc4, acc5, acc6, acc7, acc8];
      accountList.forEach(async (element) => {
        await token.connect(deployer).mint(element.address);
      });
      expect(
        (await votesGovernor.connect(deployer).winningCandidates())[0].votes
      ).to.equal(0);
      expect(
        (await votesGovernor.connect(deployer).winningCandidates())[1].votes
      ).to.equal(0);
      expect(
        (await votesGovernor.connect(deployer).winningCandidates())[2].votes
      ).to.equal(0);

      await token.connect(acc2).transfer(acc1.address, 1);
      await token.connect(acc3).transfer(acc1.address, 1);
      await token.connect(acc4).transfer(acc1.address, 1);
      expect(await token.balanceOf(acc1.address)).to.equal(4);

      // acc1 votes with weight of 4
      await votesGovernor.connect(acc1).vote(4, 1);

      // acc2 attempts to vote after having transfered his token
      await expect(votesGovernor.connect(acc2).vote(1, 1)).to.be.revertedWith(
        `InsufficientTokenBalance(0, 1)`
      );

      await votesGovernor.connect(acc5).vote(1, 2);
      await votesGovernor.connect(acc6).vote(1, 2);
      await votesGovernor.connect(acc7).vote(1, 2);
      await votesGovernor.connect(acc8).vote(1, 3);

      // leaderboard should be (1) id=1 (2) id=2 (3) id=3
      expect(
        (await votesGovernor.connect(deployer).winningCandidates())[0].id
      ).to.equal(1);
      expect(
        (await votesGovernor.connect(deployer).winningCandidates())[1].id
      ).to.equal(2);
      expect(
        (await votesGovernor.connect(deployer).winningCandidates())[2].votes
      ).to.equal(1);

      expect(
        (await votesGovernor.connect(deployer).winningCandidates())[0].votes
      ).to.equal(4);
      expect(
        (await votesGovernor.connect(deployer).winningCandidates())[1].votes
      ).to.equal(3);
      expect(
        (await votesGovernor.connect(deployer).winningCandidates())[2].votes
      ).to.equal(1);
    });
  });
});
