//SPDX-License-Identifier:MIT
pragma solidity ^0.8.19;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract MyNFT is ERC721, Ownable {
    uint256 public tokenIdCounter;

    constructor() ERC721("ICON", "ICON") Ownable(msg.sender) {
        tokenIdCounter = 0;
    }

    function mint(address to) public onlyOwner {
        uint256 tokenId = tokenIdCounter;
        _safeMint(to, tokenId);
        tokenIdCounter++;
    }
}
