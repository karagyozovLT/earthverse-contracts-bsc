const { ethers } = require("hardhat");

const main = async () => {
  const EarthverseDeposit = await ethers.getContractFactory(
    "EarthverseDeposit"
  );

  // Deploy the contract
  const earthverseDeposit = await EarthverseDeposit.deploy(
    "0xaa2d297654134830a3E053C0996A96c7d91FaDf3",
    "0xE900fe902760013eF826a1E2d7899eD677c73570",
  );
  await earthverseDeposit.deployed();

  // Print the address of the deployed contract
  console.log(
    `Contract EarthverseDeposit deployed to:`,
    earthverseDeposit.address
  );

  // Wait for bscscan to notice that the contract has been deployed
  await earthverseDeposit.deployTransaction.wait(10);

  // Verify the contract after deploying
  await hre.run("verify:verify", {
    address: earthverseDeposit.address,
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
