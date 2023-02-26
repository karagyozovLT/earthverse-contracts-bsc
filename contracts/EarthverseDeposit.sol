//SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import {IBFTDollar} from "./interfaces/IBFTDollar.sol";
import {IStaderStake} from "./interfaces/IEarthverseDeposit.sol";
import {IEarthverseMarketplace} from "./interfaces/IEarthverseMarketplace.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {IUniswapV2Router02} from "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import {TransferHelper} from "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";

// Custom errors
error EarthverseDeposit_ZeroAddress();
error EarthverseDeposit_NoBNBXWasMinted();
error EarthverseDeposit_InvalidDepositAmount();
error EarthverseDeposit_NotStablecoinAdderRole();
error EarthverseDeposit_AlreadyStablecoinAdded(address stablecoin);
error EarthverseDeposit_NotAvailableStablecoinForBuyNFTLand(address stablecoin);

/// @author Georgi Karagyozov
/// @notice EarthverseDeposit contract that is used to call the EarthverseMarketplace and NFDTollar contracts
/// and deposit a stablecoin(USDC, DAI, USDT etc.) which swaped for WETH and staking it in Rocket Pool.
contract EarthverseDeposit is AccessControl {
  bytes32 public constant ADDER_STABLECOIN_ROLE =
    keccak256("ADDER_STABLECOIN_ROLE");
  address public constant BNBX = 0x3ECB02c703C815e9cFFd8d9437B7A2F93638d7Cb;
  address public constant STADER_STAKE_MANAGER =
    0xDAdcae6bF110c0e70E5624bCdcCBe206f92A2Df9;

  uint24 public constant POOL_FEE = 3000;

  address public immutable bftd;
  address public immutable earthverseMarketplace;
  IUniswapV2Router02 public immutable uniswapV2Router;

  mapping(address => uint256) public balances;
  mapping(address => bool) public availableStablecoins;

  modifier hasStablecoinAdderRole() {
    if (!hasRole(ADDER_STABLECOIN_ROLE, msg.sender))
      revert EarthverseDeposit_NotStablecoinAdderRole();
    _;
  }

  modifier zeroAddress(address _address) {
    if (_address == address(0)) revert EarthverseDeposit_ZeroAddress();
    _;
  }

  // Events
  event NewStablecoinAddressAdded(address stablecoinAddress);
  event StablecoinAddressRemoved(address stablecoinAddress);
  event StakedAndReceivedNFTLand(
    address indexed sender,
    uint256 indexed amountOut
  );

  constructor(address _bftd, address _earthverseMarketplace) {
    if (_bftd == address(0) || _earthverseMarketplace == address(0))
      revert EarthverseDeposit_ZeroAddress();

    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _setupRole(ADDER_STABLECOIN_ROLE, msg.sender);

    bftd = _bftd;
    earthverseMarketplace = _earthverseMarketplace;
    uniswapV2Router = IUniswapV2Router02(
      0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
    );

    availableStablecoins[0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee] = true; // BUSD address
    availableStablecoins[0x64544969ed7EBf5f083679233325356EbE738930] = true; // USDC address
    availableStablecoins[0x337610d27c682E347C9cD60BD4b3b107C9d34dDd] = true; // USDT address
    availableStablecoins[0xEC5dCb5Dbf4B114C9d0F65BcCAb49EC54F6A0867] = true; // DAI address
  }

  /// @notice swapExactTokensForETH swaps a fixed amount of stablecoin for a maximum possible amount of WBNB
  /// @dev The calling address must approve this contract to spend at least `amountIn` worth of its stablecoin for this function to succeed.
  /// @param amountIn: The exact amount of stablecoin that will be swapped for WBNB.
  /// @param tokenIn: Stablecoin's address, which we will swap fro WBNB.
  function swapExactTokensForWBNB(uint256 amountIn, address tokenIn) private {
    // Transfer the specified amount of stablecoin to this contract.
    TransferHelper.safeTransferFrom(
      tokenIn,
      msg.sender,
      address(this),
      amountIn
    );

    // Approve the router to spend stablecoin.
    TransferHelper.safeApprove(tokenIn, address(uniswapV2Router), amountIn);

    address[] memory path = new address[](2);
    path[0] = tokenIn;
    path[1] = uniswapV2Router.WETH();

    // Swaps stablecoin for WBNB
    uniswapV2Router.swapExactTokensForETH(
      amountIn,
      0,
      path,
      address(this),
      block.timestamp
    );
  }

  /// @notice Sends the requested NFT Land to the buyer, sends stablecoin BFTD to the seller,
  /// swaping stablecoin(BUSD, USDC, DAI, USDT etc.) to WBNB and then staking it in Stader.
  /// @dev First manually call Stablecoin contract "Approve" function.
  /// @param tokenIn: The address of the stablecoin contract like BUSD, USDC, DAI, USDT etc.
  /// @param amountIn: The amount in the stablecoin(BUSD, USDC, DAI, USDT etc.) that is offered to buy this NFT Land.
  /// @param nftLandId: Item id of listing mapping where this NFT Land is stored.
  /// @param decimalsOfInput: Decimal of the stablecoin(BUSD, USDC, DAI, USDT etc.), through which NFT Land will be purchased by the buyer.
  function depositStaderAndSendNFTLand(
    address tokenIn,
    uint256 amountIn,
    uint256 nftLandId,
    uint256 decimalsOfInput
  ) external {
    if (amountIn <= 0) revert EarthverseDeposit_InvalidDepositAmount();
    if (!availableStablecoins[tokenIn])
      revert EarthverseDeposit_NotAvailableStablecoinForBuyNFTLand(tokenIn);

    // Swaps stablecoin for WBNB
    swapExactTokensForWBNB(amountIn, tokenIn);

    // Transfer NFTLand to the buyer
    address seller = IEarthverseMarketplace(earthverseMarketplace).buyNFTLand(
      msg.sender,
      nftLandId,
      amountIn,
      decimalsOfInput
    );

    // Mints the native BFTD token at 1 to 1 ratio and send to the seller
    IBFTDollar(bftd).mint(seller, amountIn, decimalsOfInput);

    // Queries the senders BNBX balance prior to deposit
    uint256 bnbxBalance1 = IERC20(BNBX).balanceOf(address(this));
    uint256 balanceOfContract = address(this).balance;

    // Deposits the BNB and gets BNBX back
    IStaderStake(STADER_STAKE_MANAGER).deposit{value: balanceOfContract}();

    // Queries the senders BNBX balance after the deposit
    uint256 bnbxBalance2 = IERC20(BNBX).balanceOf(address(this));
    if (bnbxBalance2 < bnbxBalance1) revert EarthverseDeposit_NoBNBXWasMinted();
    uint256 bnbxMinted = bnbxBalance2 - bnbxBalance1;

    // Stores the amount of BNBX received by the user in a mapping
    balances[msg.sender] += bnbxMinted;

    emit StakedAndReceivedNFTLand(msg.sender, balanceOfContract);
  }

  /// @notice Allows the admin to add a new address for the stablecoin.
  /// @param stablecoinAddress: The stablecoin address.
  function addNewStablecoinAddress(
    address stablecoinAddress
  ) external zeroAddress(stablecoinAddress) hasStablecoinAdderRole {
    if (availableStablecoins[stablecoinAddress])
      revert EarthverseDeposit_AlreadyStablecoinAdded(stablecoinAddress);

    availableStablecoins[stablecoinAddress] = true;

    emit NewStablecoinAddressAdded(stablecoinAddress);
  }

  /// @notice Allows the admin to remove a address for the stablecoin.
  /// @param stablecoinAddress: The stablecoin address.
  function removeStablecoinAddress(
    address stablecoinAddress
  ) external zeroAddress(stablecoinAddress) hasStablecoinAdderRole {
    delete (availableStablecoins[stablecoinAddress]);

    emit StablecoinAddressRemoved(stablecoinAddress);
  }

  fallback() external payable {}

  receive() external payable {}
}
