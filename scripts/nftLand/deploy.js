const { ethers } = require("hardhat");

const main = async () => {
  const NFTLand = await ethers.getContractFactory("NFTLand");

  // Deploy the contract
  const nftLand = await NFTLand.deploy();
  await nftLand.deployed();

  // Print the address of the deployed contract
  console.log(`Contract NFT Land deployed to:`, nftLand.address);

  // Wait for bscscan to notice that the contract has been deployed
  await nftLand.deployTransaction.wait(10);

  // Verify the contract after deploying
  await hre.run("verify:verify", {
    address: nftLand.address,
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
