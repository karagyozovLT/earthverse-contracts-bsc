//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {INFTLand} from "./interfaces/INFTLand.sol";
import {Counters} from "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

/// @author Georgi Karagyozov
/// @notice NFT Land contract which represents a piece of the Earthverse.
contract NFTLand is INFTLand, ERC721URIStorage {
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  constructor() ERC721("NFT Land", "NFTL") {}

  /// @notice Allows the seller to mint a NFT Land.
  /// @param ipfsURI: IPFS's link  of metadata for the NFT Land
  function safeMintNFT(
    string calldata ipfsURI
  ) external returns (uint256 newTokenId) {
    newTokenId = _tokenIds.current();

    _safeMint(msg.sender, newTokenId);
    _setTokenURI(newTokenId, ipfsURI);
    _tokenIds.increment();
  }
}
