import { BigNumber } from "ethers";

export type Candidate = {
  id: BigNumber;
  name: string;
  age: BigNumber;
  cult: string;
  votes: BigNumber;
};
