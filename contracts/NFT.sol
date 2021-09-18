// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFT is ERC721URIStorage {
    using Counters for Counters.Counter;

    //tokenIds will give a unique ID for minted tokens. Counters will allow us to continually increment the IDs.
    Counters.Counter private _tokenIds;

    //the address of the marketplace that we want to allow the NFT to be able to interact with, and vise versa. (transact/change ownership from seperate contract.)
    address contractAddress;

    constructor(address marketplaceAddress) ERC721("Metaverse Tokens", "METT") {
        contractAddress = marketplaceAddress;
    }

    //the function for minting tokens.
    function createToken(string memory tokenURI) public returns (uint) {
        
        //increment the tokenIds: increment the values from 0
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();

        _mint(msg.sender, newItemId);
        _setTokenURI(newItemId, tokenURI);

        //allow transactions between users within another contract.
        setApprovalForAll(contractAddress, true);
        return newItemId;
    }

}


