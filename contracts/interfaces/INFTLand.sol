//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface INFTLand {
  function safeMintNFT(string calldata ipfsURI) external returns (uint256);
}
