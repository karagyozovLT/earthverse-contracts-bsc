const { ethers } = require("hardhat");

const main = async () => {
  const NFTAugmentedReality = await ethers.getContractFactory(
    "NFTAugmentedReality"
  );

  // Deploy the contract
  const nftAugmentedReality = await NFTAugmentedReality.deploy();
  await nftAugmentedReality.deployed();

  // Print the address of the deployed contract
  console.log(
    `Contract NFT Augmented Reality deployed to:`,
    nftAugmentedReality.address
  );

  // Wait for bscscan to notice that the contract has been deployed
  await nftAugmentedReality.deployTransaction.wait(10);

  // Verify the contract after deploying
  await hre.run("verify:verify", {
    address: nftAugmentedReality.address,
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
