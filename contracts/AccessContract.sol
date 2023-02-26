//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {Ownable} from "./Ownable.sol";
import {IAccessContract} from "./interfaces/IAccessContract.sol";

// Custom errros
error AccessContract_ZeroAddress();
error AccessContract_NotHaveAccess(address sender);

/// @author Georgi Karagyozov
/// @notice Access Contract contract through which it provides access to certain functions.
contract AccessContract is Ownable, IAccessContract {
  address public earthverseDepositAddress;

  event EarthverseDepositAddressChanged(address oldAddress, address newAddress);

  modifier onlyEarthverseDeposit() {
    if (msg.sender != earthverseDepositAddress)
      revert AccessContract_NotHaveAccess(msg.sender);
    _;
  }

  /// @notice Аllows the contract owner to give a new address for earthverseDeposit.
  /// @param _earthverseDepositAddress: The address of earthverseDeposit contract.
  function setNewEarthverseDepositAddress(
    address _earthverseDepositAddress
  ) external onlyOwner {
    if (_earthverseDepositAddress == address(0))
      revert AccessContract_ZeroAddress();

    emit EarthverseDepositAddressChanged(
      earthverseDepositAddress,
      _earthverseDepositAddress
    );

    earthverseDepositAddress = _earthverseDepositAddress;
  }
}
