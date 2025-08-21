//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";

contract SimpleERC4626Vault is ERC4626, ReentrancyGuard, Ownable {
    error UnderlyingAssetCannotBeZeroAddress();
    error ManagementFeeExceedsMaximumLimit();
    error CannotDepositZero();
    error ReceiverCannotBeZeroAddress();
    error ManagementFeeCanOnlyBeCollectedOncePerMonth();
    error ShareCannotBeZero();
    error AssetToWithdrawMustBeMoreThanZero();
    error InsufficientAssetsBalance();

    event ManagementFeeCollected(address indexed owner, uint256 feeAmount);

    address public immutable underlyingAsset;
    string public assetName;
    string public assetSymbol;
    uint256 public managementFee;
    uint256 public lastFeeTimestamp;
    uint256 private constant MAX_FEE = 1000; // 10% in basis points

    constructor(address _underlyingAsset, string memory _assetName, string memory _assetSymbol, uint256 _managementFee)
        ERC4626(IERC20(_underlyingAsset))
        ERC20(_assetName, _assetSymbol)
        Ownable(msg.sender)
    {
        if (_underlyingAsset == address(0)) {
            revert UnderlyingAssetCannotBeZeroAddress();
        }
        if (_managementFee > MAX_FEE) {
            revert ManagementFeeExceedsMaximumLimit();
        }
        if (_managementFee == 0) {
            _managementFee = 100; // Default to 1% if not specified
        }
        underlyingAsset = _underlyingAsset;
        assetName = _assetName;
        assetSymbol = _assetSymbol;
        managementFee = _managementFee;
        lastFeeTimestamp = block.timestamp;
    }

    function totalAssets() public view override returns (uint256) {
        return IERC20(underlyingAsset).balanceOf(address(this));
    }

    function deposit(uint256 assets, address receiver) public override nonReentrant returns (uint256 shares) {
        if (assets == 0) {
            revert CannotDepositZero();
        }
        if (receiver == address(0)) {
            revert ReceiverCannotBeZeroAddress();
        }
        _collectManagementFee();
        shares = super.deposit(assets, receiver);
        emit Deposit(msg.sender, receiver, assets, shares);
    }

    function mint(uint256 shares, address receiver) public override nonReentrant returns (uint256 assets) {
        if (shares == 0) {
            revert ShareCannotBeZero();
        }
        if (receiver == address(0)) {
            revert ReceiverCannotBeZeroAddress();
        }
        _collectManagementFee();
        assets = super.mint(shares, receiver);
    }

    function withdraw(uint256 _assets, address _receiver, address _owner)
        public
        override
        nonReentrant
        returns (uint256 shares)
    {
        if (_assets == 0) {
            revert AssetToWithdrawMustBeMoreThanZero();
        }
        if (_receiver == address(0)) {
            revert ReceiverCannotBeZeroAddress();
        }
        shares = super.withdraw(_assets, _receiver, _owner);
        emit Withdraw(msg.sender, _receiver, _owner, _assets, shares);
    }

    function redeem(uint256 _shares, address _receiver, address _owner)
        public
        override
        nonReentrant
        returns (uint256 assets)
    {
        if (_shares == 0) {
            revert ShareCannotBeZero();
        }
        if (_receiver == address(0)) {
            revert ReceiverCannotBeZeroAddress();
        }
        _collectManagementFee();
        assets = super.redeem(_shares, _receiver, _owner);
    }

    function setManagementFee(uint256 newManagementFee) external onlyOwner {
        if (newManagementFee > MAX_FEE) {
            revert ManagementFeeExceedsMaximumLimit();
        }
        managementFee = newManagementFee;
    }

    function collectManagementFee() external onlyOwner {
        _collectManagementFee();
    }

    function _collectManagementFee() internal {
        uint256 currentTime = block.timestamp;
        if (currentTime - lastFeeTimestamp >= 30 days) {
            uint256 feeAmount = (totalAssets() * managementFee) / 10000; // Calculate fee based on total assets
            if (feeAmount > 0) {
                IERC20(underlyingAsset).transfer(owner(), feeAmount);
                lastFeeTimestamp = currentTime;
            }
            emit ManagementFeeCollected(owner(), feeAmount);
        } else {
            revert ManagementFeeCanOnlyBeCollectedOncePerMonth();
        }
    }

    function emergencyWithdraw(uint256 amount) external onlyOwner nonReentrant {
        if (amount == 0) {
            revert AssetToWithdrawMustBeMoreThanZero();
        }
        uint256 balance = totalAssets();
        if (amount > balance) {
            revert InsufficientAssetsBalance();
        }
        IERC20(underlyingAsset).transfer(owner(), amount);
    }

    function getVaultDetails()
        external
        view
        returns (
            address asset,
            string memory name,
            string memory symbol,
            uint256 totalAssetsBalance,
            uint256 managementFeePercentage,
            uint256 lastFeeCollectionTimestamp
        )
    {
        return (underlyingAsset, assetName, assetSymbol, totalAssets(), managementFee, lastFeeTimestamp);
    }
}
