// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

/**Created by Matt Lindborg
 * UAT MS636 Week 4
 * @title Marketplace
 * @dev Marketplace Contract
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Marketplace {

    // state variables
    IERC20 public token;
    struct Item {
        uint256 id;
        address seller;
        uint256 price;
        bool isSold;
        address buyer;
    }

    Item[] public items;

    uint256 itemIdCounter;

    // events
    event ItemCreated(uint256 id, address seller, uint256 price);

    constructor() {

    }

    function listItem(uint256 _price) public {
        require(_price > 0, "Price must be greater than zero");

        Item memory newItem = Item({
            id: itemIdCounter,
            seller: msg.sender,
            price: _price,
            isSold: false,
            buyer: address(0)
        });

        items.push(newItem);
        itemIdCounter++;

        emit ItemCreated(newItem.id, newItem.seller, newItem.price);
    }

    function purchaseItem(uint256 _itemId) public {

    }

    function refund(uint256 _itemId) public {

    }

    function getItemDetails(uint256 _itemId) public view returns (Item memory) {

    }
}