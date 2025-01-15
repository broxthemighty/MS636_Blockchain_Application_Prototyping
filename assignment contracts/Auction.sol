// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

/**Created by Matt Lindborg
 * UAT MS636 Week 5
 * @title Auction
 * @dev Auction Contract
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Auction {

    // state variables
    IERC20 public token;
    struct AuctionItem {
        uint256 id;
        address seller;
        uint256 minBid;
        uint256 highestBid;
        bool isActive;
        uint256 endTime;
    }

    AuctionItem[] public auctions;
    uint256 public auctionIdCounter;

    constructor() {

    }

    function createAuction(uint256 _minBid, uint256 _duration) public {

    }

    function placeBid(uint256 _auctionId, uint256 _bidAmount) public {

    }

    function finalizeAuction(uint256 _auctionId) public {

    }

    function getAuctionDetails(uint256 _auctionId) public view returns (AuctionItem memory) {
        
    }
}