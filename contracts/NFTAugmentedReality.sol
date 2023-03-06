//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Counters} from "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

/// @author Georgi Karagyozov
/// @notice NFT Augmented Reality contract which represents a piece of the AI Earthverse.
contract NFTAugmentedReality is ERC721URIStorage {
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  constructor() ERC721("NFT Augmented Reality", "NFTAR") {}

  /// @notice Allows the seller to mint a NFT Augmented Reality.
  /// @param ipfsURI: IPFS's link of metadata for the NFT Augmented Reality
  function safeMintNFT(
    string calldata ipfsURI
  ) external returns (uint256 newTokenId) {
    newTokenId = _tokenIds.current();

    _safeMint(msg.sender, newTokenId);
    _setTokenURI(newTokenId, ipfsURI);
    _tokenIds.increment();
  }
}
