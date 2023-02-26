//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IOwnable {
  function renounceOwnership(bool isRenounce) external;

  function transferOwnership(address newOwner, bool direct) external;

  function claimOwnership() external;
}
