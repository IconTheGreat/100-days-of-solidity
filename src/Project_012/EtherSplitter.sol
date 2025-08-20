// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title EthSplitter
 * @author ICON
 * @notice A contract to split incoming Ether among multiple recipients based on predefined percentages.
 * @dev This contract allows the owner to set recipients and their respective percentages, ensuring that the total percentage equals 100.
 */
contract EthSplitter {
    //==== Custom Errors ====
    error EthSplitter__NotOwner();
    error EthSplitter__RecipientsAndPercentagesMustBeTheSameLength();
    error EthSplitter__InvalidPercentages();
    error EthSplitter_TransferFailed();

    //==== State Variables ====
    address public immutable owner;
    uint8 private constant PERCENTAGE_PRECISION = 100;

    address payable[] private s_recipients;
    uint256[] private s_percentages;
    mapping(address => uint256) private s_splits;

    //==== Modifiers ====

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert EthSplitter__NotOwner();
        }
        _;
    }

    //==== Functions ====

    constructor(address payable[] memory recipients, uint256[] memory percentages) {
        uint256 length = recipients.length;
        if (length != percentages.length) {
            revert EthSplitter__RecipientsAndPercentagesMustBeTheSameLength();
        }

        owner = msg.sender;

        uint256 _totalPercentage;
        for (uint256 i; i < length;) {
            _totalPercentage += percentages[i];
            s_splits[recipients[i]] = percentages[i];
            s_recipients.push(recipients[i]);
            s_percentages.push(percentages[i]);
            unchecked {
                i++;
            }
        }

        if (_totalPercentage != PERCENTAGE_PRECISION) {
            revert EthSplitter__InvalidPercentages();
        }
    }

    receive() external payable {
        uint256 totalReceived = msg.value;
        uint256 length = s_recipients.length;

        for (uint256 i; i < length;) {
            uint256 percentage = s_percentages[i];
            uint256 amount = (totalReceived * percentage) / PERCENTAGE_PRECISION;

            (bool success,) = s_recipients[i].call{value: amount}("");
            if (!success) revert EthSplitter_TransferFailed();

            unchecked {
                i++;
            }
        }
    }

    function updateRecipients(address payable[] memory newRecipients, uint256[] memory newPercentages)
        public
        onlyOwner
    {
        uint256 length = newRecipients.length;
        if (length != newPercentages.length) {
            revert EthSplitter__RecipientsAndPercentagesMustBeTheSameLength();
        }

        // Reset storage arrays
        delete s_recipients;
        delete s_percentages;

        uint256 _totalPercentage;
        for (uint256 i; i < length;) {
            _totalPercentage += newPercentages[i];
            s_splits[newRecipients[i]] = newPercentages[i];
            s_recipients.push(newRecipients[i]);
            s_percentages.push(newPercentages[i]);
            unchecked {
                i++;
            }
        }

        if (_totalPercentage != PERCENTAGE_PRECISION) {
            revert EthSplitter__InvalidPercentages();
        }
    }

    function emergencyWithdraw() public onlyOwner {
        (bool success,) = owner.call{value: address(this).balance}("");
        if (!success) revert EthSplitter_TransferFailed();
    }

    // ===== View functions =====
    function getRecipients() external view returns (address payable[] memory) {
        return s_recipients;
    }

    function getPercentages() external view returns (uint256[] memory) {
        return s_percentages;
    }

    function getSplit(address recipient) external view returns (uint256) {
        return s_splits[recipient];
    }
}
