//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract EthSplitter {
    error EthSplitter_NotOwner();
    error EthSplitter__RecipientsAndPercentagesMustBeTheSameLength();
    error EthSplitter_TransferFailed();
    error EthSplitter__InvalidFunctionCall();
    error EthSplitter_ZeroBalanceInContract();
    error EthSplitter__InvalidPercentages();

    uint256 private constant PERCENTAGE_PRECISION = 100;
    address public owner;
    uint256 totalPercentage;
    mapping(address recipient => uint256 recipientPercent) public s_splits;
    address payable[] public s_recipients;
    uint256[] public s_percentages;

    constructor(address payable[] memory recipients, uint256[] memory percentages) {
        owner = msg.sender;
        if (recipients.length != percentages.length) {
            revert EthSplitter__RecipientsAndPercentagesMustBeTheSameLength();
        }
        for (uint256 i = 0; i < percentages.length; i++) {
            totalPercentage += percentages[i];
        }
        if (totalPercentage != PERCENTAGE_PRECISION) {
            revert EthSplitter__InvalidPercentages();
        }
        for (uint256 i = 0; i < recipients.length; i++) {
            s_splits[recipients[i]] = percentages[i];
            s_recipients.push(recipients[i]);
            s_percentages.push(percentages[i]);
        }
    }

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert EthSplitter_NotOwner();
        }
        _;
    }

    receive() external payable {
        uint256 totalReceived = msg.value;
        for (uint256 i = 0; i < s_recipients.length; i++) {
            uint256 amount = (totalReceived * s_percentages[i]) / PERCENTAGE_PRECISION;
            (bool success,) = payable(s_recipients[i]).call{value: amount}("");
            if (!success) {
                revert EthSplitter_TransferFailed();
            }
        }
    }

    function updateRecipients(address payable[] memory newRecipients, uint256[] memory newPercentages)
        public
        onlyOwner
    {
        for (uint256 i = 0; i < s_recipients.length; i++) {
            delete s_splits[s_recipients[i]];
        }
        delete s_recipients;
        delete s_percentages;

        for (uint256 i = 0; i < newRecipients.length; i++) {
            s_splits[newRecipients[i]] = newPercentages[i];
            s_recipients.push(newRecipients[i]);
            s_percentages.push(newPercentages[i]);
        }
    }

    function emergencyWithdraw() public onlyOwner {
        if (address(this).balance == 0) {
            revert EthSplitter_ZeroBalanceInContract();
        }
        (bool success,) = payable(msg.sender).call{value: address(this).balance}("");
        if (!success) {
            revert EthSplitter_TransferFailed();
        }
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getRecipients() public view returns (address payable[] memory) {
        return s_recipients;
    }

    fallback() external payable {
        revert EthSplitter__InvalidFunctionCall();
    }
}
