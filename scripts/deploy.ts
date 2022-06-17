import { Candidate } from "../types/types";

const { ethers } = require("hardhat");

const { OFFICIAL_CANDIDATES_LIST } = require("../OfficialCandidatesList");

const CANDIDATES_URL = "https://wakanda-task.3327.io/list";

async function main() {
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
  await votesGovernor.connect(deployer).addCandidates(OFFICIAL_CANDIDATES_LIST);
  let newList: Candidate[] = [];
  for (var i = 0; i < OFFICIAL_CANDIDATES_LIST.length; i++) {
    let candidate: Candidate = await votesGovernor._candidates(i);
    candidate = {
      id: candidate.id,
      name: candidate.name,
      age: candidate.age,
      cult: candidate.cult,
      votes: candidate.votes,
    };
    newList.push(candidate);
    //Do something
  }
  console.log("Candidates added to the contract:");
  console.table(newList);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
