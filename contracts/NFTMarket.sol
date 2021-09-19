// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

//prevents re-entry attacks.
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract NFTMarket is ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _itemIds;
    Counters.Counter private _itemsSold;

    address payable owner;
    uint256 listingPrice = 0.025 ether;

    constructor() {
        owner = payable(msg.sender);
    }

    //the shape of the market item.
    struct MarketItem {
        uint itemId;
        address nftContract;
        uint256 tokenId;
        address payable seller;
        address payable owner;
        uint256 price;
        bool sold;
    }

    //pass id of item to retrieve it. This funtion will return the above struct with the corresponding market items information.
    mapping(uint256 => MarketItem) private idToMarketItem;

    //emmit an event when a market item is created. Able to listen to events from frontend.
    event MarketItemCreated (
        uint indexed itemId,
        address indexed nftContract,
        uint256 indexed tokenId,
        address seller,
        address owner, 
        uint256 price,
        bool sold
    );

    //get listing price for the frontend.
    function getListingPrice() public view returns (uint256) {
        return listingPrice;
    }

    //function for creating a market item.
    function createMarketItem(
        address nftContract,
        uint256 tokenId,
        uint256 price
    ) public payable nonReentrant {
        //wei is the smallest denomination of ether. real-world might require atleast 0.1 eth.
        require(price > 0, "Price must be at least 1 wei");
        require(msg.value == listingPrice, "Price must be equal to listing price");

        _itemIds.increment();
        uint256 itemId = _itemIds.current();

        //create the market item, and then set the mapping for the market item.
        idToMarketItem[itemId] = MarketItem( 
            itemId,
            nftContract,
            tokenId,
            payable(msg.sender),

            //set the owner to NO ONE - because the seller listed the item and no one has purchased.
            payable(address(0)),
            price,
            false
        );

        //transfer the ownership of the NFT to the contract itself. The contract will take ownership of the NFT and then the contract can pass the ownership to the buyer.
        //transfer from the msg.sender, to the contract itself, and the NFT. 
        IERC721(nftContract).transferFrom(msg.sender, address(this), tokenId);


        //emit the event. a market item has been created!
        emit MarketItemCreated(
            itemId, 
            nftContract, 
            tokenId, 
            msg.sender, 
            address(0), 
            price, 
            false
            );
    }

    function createMarketSale(
        address nftContract,
        uint256 itemId
    ) public payable nonReentrant {
        uint price = idToMarketItem[itemId].price;
        uint tokenId = idToMarketItem[itemId].tokenId;

        //the buyer must enter the asking price - if not - "error message".
        require(msg.value == price, "Please submit the asking price in order to complete the purchase");

        //transfer the value of the transaction to the seller.
        idToMarketItem[itemId].seller.transfer(msg.value);

        //transfer from this contract address, to the message sender. transferring the ownership of the NFT from the contract address to the buyer. This sends money to the seller, transfers the NFT to the buyer.
        IERC721(nftContract).transferFrom(address(this), msg.sender, tokenId);

        //updating the mapping - setting the owner to the buyer.
        idToMarketItem[itemId].owner = payable(msg.sender);
        idToMarketItem[itemId].sold = true;

        //keep up with the number of items sold.
        _itemsSold.increment();

        //pay the owner of the contract. the owner gets the listing price.
        payable(owner).transfer(listingPrice);

    }


    // view means this function does NOT transact.
    function fetchMarketItems() public view returns (MarketItem[] memory) {
        //total number of items created.
        uint itemCount = _itemIds.current();
        uint unsoldItemCount = _itemIds.current() - _itemsSold.current();
        uint currentIndex = 0;

        //creates an empty array called 'items'. The values in this array are going to be of MarketItem. Solidity arrays need a specified length - in this instance the length is represented by the unsoldItemCount.
        MarketItem[] memory items = new MarketItem[] (unsoldItemCount);

        //loop over the number of items that have been created.
        for (uint i = 0; i < itemCount; i++) {
            //if the item has not been sold, push it to the MarketItem array.
            //we are starting the actual item ids from 1. this is why we are using the index + 1.
            if (idToMarketItem[i + 1].owner == address(0)) {
                uint currentId = idToMarketItem[i + 1].itemId;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    function fetchMyNFTs() public view returns (MarketItem[] memory) {
        uint totalItemCount = _itemIds.current();
        uint itemCount = 0;
        uint currentIndex = 0;

        //keep up with the total item count.
        for (uint i = 0; i  < totalItemCount; i++) {
            if (idToMarketItem[i + 1].owner == msg.sender) {
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[] (itemCount);

        for (uint i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].owner == msg.sender) {
                uint currentId = idToMarketItem[i + 1].itemId;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }

    function fetchItemsCreated() public view returns (MarketItem[] memory) {
        uint totalItemCount = _itemIds.current();
        uint itemCount = 0;
        uint currentIndex = 0;

        //keep up with the total item count.
        for (uint i = 0; i< totalItemCount; i++) {
            if (idToMarketItem[i+1].seller == msg.sender) {
                itemCount += 1;
            }
        }

        MarketItem[] memory items = new MarketItem[] (itemCount);

        for (uint i = 0; i < totalItemCount; i++) {
            if (idToMarketItem[i + 1].seller == msg.sender) {
                uint currentId = idToMarketItem[i + 1].itemId;
                MarketItem storage currentItem = idToMarketItem[currentId];
                items[currentIndex] = currentItem;
                currentIndex += 1;
            }
        }
        return items;
    }
}