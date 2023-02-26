const { ethers } = require("hardhat");

const main = async () => {
  const BFTDollar = await ethers.getContractFactory("BFTDollar");

  // Deploy the contract
  const bftDollar = await BFTDollar.deploy();
  await bftDollar.deployed();

  // Print the address of the deployed contract
  console.log(`Contract BFT Dollar deployed to:`, bftDollar.address);

  // Wait for bscscan to notice that the contract has been deployed
  await bftDollar.deployTransaction.wait(10);

  // Verify the contract after deploying
  await hre.run("verify:verify", {
    address: bftDollar.address,
    constructorArguments: [],
  });
};

// Call the main function and catch if there is any error
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
