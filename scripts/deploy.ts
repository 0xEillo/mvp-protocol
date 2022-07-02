import { Candidate } from "../types/types";
import { BigNumber } from "ethers";

const { ethers } = require("hardhat");

const axios = require("axios").default;

async function deploy(candidates: Candidate[]) {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  console.log("Account balance:", (await deployer.getBalance()).toString());

  const WKND = await ethers.getContractFactory("WKND");
  const wkndToken = await WKND.deploy();
  const VotesGovernor = await ethers.getContractFactory("VotesGovernor");
  const votesGovernor = await VotesGovernor.deploy(wkndToken.address);

  console.log("WKND Token address:", wkndToken.address);
  console.log("VotesGovernor address:", votesGovernor.address);

  // add candidates
  await votesGovernor.connect(deployer).addCandidates(candidates);

  console.log("Candidates added to the contract");
}

async function main() {
  let candidates: Candidate[] = [];
  // Make a request for a user with a given ID
  axios
    .get("https://wakanda-task.3327.io/list")
    .then(function (response: any) {
      // handle success
      candidates = response.data.candidates;
      candidates.forEach((element) => {
        element.id = BigNumber.from(0);
        element.votes = BigNumber.from(0);
      });
      deploy(candidates);
    })
    .catch(function (error: string) {
      // handle error
      console.log(error);
    });
}

main();
