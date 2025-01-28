// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

/**Created by Matt Lindborg
 * UAT MS636 Week 4
 * @title Marketplace
 * @dev Marketplace Contract
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// marketplace contract
contract Marketplace {

    // state variables
    IERC20 public token;

    // item structure
    struct Item {
        uint256 id;          
        address seller;     
        uint256 price;       
        bool isSold;         
        address buyer;       
    }

    // array to store listed items
    Item[] public items;

    // counter for generating unique item IDs
    uint256 public itemIdCounter;

    // events
    event ItemCreated(uint256 id, address seller, uint256 price);
    event ItemPurchased(uint256 id, address buyer);
    event ItemRefunded(uint256 id, address seller, address buyer);

    // constructor initilizes with the token address
    constructor(address _token) {
        require(_token != address(0), "Token address cannot be zero.");
        token = IERC20(_token);
    }

    // lists an item for sale on the marketplace.
    function listItem(uint256 _price) external {
        require(_price > 0, "Price must be greater than zero.");

        // create a new item and add it to the items array
        items.push(Item({
            id: itemIdCounter,
            seller: msg.sender,
            price: _price,
            isSold: false,
            buyer: address(0)
        }));

        emit ItemCreated(itemIdCounter, msg.sender, _price);

        // increment the item ID counter
        itemIdCounter++;
    }

    // purchases an item using ERC20 tokens.
    function purchaseItem(uint256 _itemId) external {
        require(_itemId < items.length, "Item does not exist.");
        Item storage item = items[_itemId];

        require(!item.isSold, "Item has already been sold.");
        require(msg.sender != item.seller, "Seller cannot purchase their own item.");
        require(token.balanceOf(msg.sender) >= item.price, "Insufficient token balance.");

        // Attempt to transfer tokens from buyer to seller
        try token.transferFrom(msg.sender, item.seller, item.price) {
            item.isSold = true;
            item.buyer = msg.sender;

            emit ItemPurchased(item.id, msg.sender);
        } catch {
            revert("Token transfer failed.");
        }
    }

    // refunds the buyer in case the seller agrees to a refund.
    function refund(uint256 _itemId) external {
        require(_itemId < items.length, "Item does not exist.");
        Item storage item = items[_itemId];

        require(item.isSold, "Item has not been sold.");
        require(msg.sender == item.seller, "Only the seller can issue refunds.");

        // Attempt to transfer tokens back to the buyer
        try token.transfer(item.buyer, item.price) {
            item.isSold = false;
            item.buyer = address(0);

            emit ItemRefunded(item.id, item.seller, msg.sender);
        } catch {
            revert("Refund failed.");
        }
    }

    // retrieves the details of a specific item.
    function getItemDetails(uint256 _itemId) external view returns (Item memory) {
        require(_itemId < items.length, "Item does not exist.");
        return items[_itemId];
    }
}
