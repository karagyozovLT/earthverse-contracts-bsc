const { ethers } = require("hardhat");

const main = async () => {
  const EarthverseMarketplace = await ethers.getContractFactory(
    "EarthverseMarketplace"
  );

  // Deploy the contract
  const earthverseMarketplace = await EarthverseMarketplace.deploy();
  await earthverseMarketplace.deployed();

  // Print the address of the deployed contract
  console.log(
    `Contract EarthverseMarketplace deployed to:`,
    earthverseMarketplace.address
  );

  // Wait for bscscan to notice that the contract has been deployed
  await earthverseMarketplace.deployTransaction.wait(10);

  // Verify the contract after deploying
  await hre.run("verify:verify", {
    address: earthverseMarketplace.address,
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
