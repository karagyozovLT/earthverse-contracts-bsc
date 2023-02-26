// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IEarthverseMarketplace {
  function listNFTLand(
    IERC721 nftLand,
    uint256 tokenId,
    uint256 price
  ) external;

  function buyNFTLand(
    address buyer,
    uint256 tokenId,
    uint256 price,
    uint256 decimalsOfInput
  ) external returns (address);
}
