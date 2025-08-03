// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Confessions {
    error MustInputASecret();

    event ConfessionSubmitted(uint256 indexed id, string secret);

    struct Confession {
        address confessor;
        string secret;
    }

    uint256 public confessionIdCounter;
    mapping(uint256 => Confession) private s_confessions;

    function submitConfession(string memory _secret) public {
        if (bytes(_secret).length == 0) {
            revert MustInputASecret();
        }

        uint256 confessionId = confessionIdCounter;
        confessionIdCounter++;

        Confession memory newConfessionData = Confession({confessor: msg.sender, secret: _secret});

        s_confessions[confessionId] = newConfessionData;

        emit ConfessionSubmitted(confessionId, _secret);
    }

    function getConfession(uint256 confessionId) public view returns (string memory) {
        return s_confessions[confessionId].secret;
    }

    function getAllConfessions() public view returns (Confession[] memory) {
        Confession[] memory all = new Confession[](confessionIdCounter);
        for (uint256 i = 0; i < confessionIdCounter; i++) {
            all[i] = s_confessions[i];
        }
        return all;
    }
}
