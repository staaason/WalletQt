
const hre = require("hardhat");

async function main() {
  const name = 'Test token';
  const symbol = 'TST';
  const decimals = 18;
  const admin = '0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266';
  const totalSupply = 10000;

  const Token = await hre.ethers.getContractFactory("Token");
  const token = await Token.deploy(name, symbol, decimals, admin, totalSupply);

  await token.deployed();
  console.log("Token deployed to:", token.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
