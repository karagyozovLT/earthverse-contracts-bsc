// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IOwnable} from "./interfaces/IOwnable.sol";

error Ownable_ZeroAddress();
error Ownable_CallerIsNotTheOwner();
error Ownable_CallerIsNotPendingOwner();
error Ownable_NewOwnerMustBeADifferentAddressThanTheCurrentOwner();

/// @author Georgi Karagyozov
/// @notice Ownable contract used to manage Access Contract - AccessContract contract.
abstract contract Ownable is IOwnable {
  address private _owner;
  address public pendingOwner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /// @notice Initializes the contract setting the deployer as the initial owner.
  constructor() {
    _transferOwnership(msg.sender);
  }

  /// @notice Throws if called by any account other than the owner.
  modifier onlyOwner() {
    if (owner() != msg.sender) revert Ownable_CallerIsNotTheOwner();
    _;
  }

  /// @notice Returns the address of the current owner.
  function owner() public view returns (address) {
    return _owner;
  }

  /// @notice Leaves the contract without owner. It will not be possible to call `onlyOwner` modifier anymore.
  /// @param isRenounce: Boolean parameter with which you confirm renunciation of ownership
  function renounceOwnership(bool isRenounce) external onlyOwner {
    if (isRenounce) _transferOwnership(address(0));
  }

  /// @notice Transfers ownership of the contract to a new account.
  /// @param newOwner: The address of the new owner of the contract
  /// @param direct: Boolean parameter that will be used to change the owner of the contract directly
  function transferOwnership(address newOwner, bool direct) external onlyOwner {
    if (newOwner == address(0)) revert Ownable_CallerIsNotTheOwner();

    if (direct) {
      if (newOwner == _owner)
        revert Ownable_NewOwnerMustBeADifferentAddressThanTheCurrentOwner();

      _transferOwnership(newOwner);
      pendingOwner = address(0);
    } else {
      pendingOwner = newOwner;
    }
  }

  /// @notice The `pendingOwner` have to confirm, if he wants to be the new owner of the contract.
  function claimOwnership() external {
    if (msg.sender != pendingOwner) revert Ownable_CallerIsNotPendingOwner();

    _transferOwnership(pendingOwner);
    pendingOwner = address(0);
  }

  /// @notice Transfers ownership of the contract to a new account.
  /// @param newOwner: The address of the new owner of the contract
  function _transferOwnership(address newOwner) internal {
    _owner = newOwner;
    emit OwnershipTransferred(_owner, newOwner);
  }
}
