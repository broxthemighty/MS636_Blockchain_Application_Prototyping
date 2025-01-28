// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

/**Created by Matt Lindborg
 * UAT MS636 Week 5
 * @title Auction
 * @dev Auction Contract
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// auction contract
contract Auction {
    
    // state variables
    IERC20 public token;

    // auction item structure
    struct AuctionItem {
        uint256 id; 
        address seller; 
        uint256 minBid; 
        uint256 highestBid;
        address highestBidder; 
        bool isActive; 
        uint256 endTime; 
    }

    // array of auctions
    AuctionItem[] public auctions;

    // counter for auction id
    uint256 public auctionIdCounter;

    // events
    event AuctionCreated(uint256 id, address indexed seller, uint256 minBid, uint256 endTime);
    event BidPlaced(uint256 indexed auctionId, address indexed bidder, uint256 bidAmount);
    event AuctionFinalized(uint256 indexed auctionId, address indexed winner, uint256 highestBid);
    
    // initializes the auction contract with the ERC20 token address.
    constructor(address _token) {
        require(_token != address(0), "Token address cannot be zero.");
        token = IERC20(_token);
    }

    // creates a new auction.
    function createAuction(uint256 _minBid, uint256 _duration) external {
        require(_minBid > 0, "Minimum bid must be greater than zero.");
        require(_duration > 0, "Duration must be greater than zero.");

        auctions.push(AuctionItem({
            id: auctionIdCounter,
            seller: msg.sender,
            minBid: _minBid,
            highestBid: 0,
            highestBidder: address(0),
            isActive: true,
            endTime: block.timestamp + _duration
        }));

        emit AuctionCreated(auctionIdCounter, msg.sender, _minBid, block.timestamp + _duration);

        auctionIdCounter++;
    }

    // places a bid on an active auction.
    function placeBid(uint256 _auctionId, uint256 _bidAmount) external {
        require(_auctionId < auctions.length, "Auction does not exist.");
        AuctionItem storage auction = auctions[_auctionId];
        require(auction.isActive, "Auction is not active.");
        require(block.timestamp < auction.endTime, "Auction has ended.");
        require(_bidAmount > auction.highestBid, "Bid must be higher than the current highest bid.");
        require(_bidAmount >= auction.minBid, "Bid must meet the minimum bid amount.");

        // transfer tokens from bidder to the contract
        try token.transferFrom(msg.sender, address(this), _bidAmount) {
            // refund previous highest bidder, if able
            if (auction.highestBid > 0) {
                token.transfer(auction.highestBidder, auction.highestBid);
            }

            // update auction with new highest bid
            auction.highestBid = _bidAmount;
            auction.highestBidder = msg.sender;

            emit BidPlaced(_auctionId, msg.sender, _bidAmount);
        } catch {
            revert("Token transfer failed.");
        }
    }

    // finalizes an auction, transferring the highest bid to the seller.
    function finalizeAuction(uint256 _auctionId) external {
        require(_auctionId < auctions.length, "Auction does not exist.");
        AuctionItem storage auction = auctions[_auctionId];
        require(block.timestamp >= auction.endTime, "Auction has not ended.");
        require(auction.isActive, "Auction is not active.");

        auction.isActive = false;

        if (auction.highestBid > 0) {
            // transfer highest bid to the seller
            try token.transfer(auction.seller, auction.highestBid) {
                emit AuctionFinalized(_auctionId, auction.highestBidder, auction.highestBid);
            } catch {
                revert("Token transfer to seller failed.");
            }
        } else {
            // no bids, no transfer required
            emit AuctionFinalized(_auctionId, address(0), 0);
        }
    }

    // retrieves the details of a specific auction.
    function getAuctionDetails(uint256 _auctionId) external view returns (AuctionItem memory) {
        require(_auctionId < auctions.length, "Auction does not exist.");
        return auctions[_auctionId];
    }
}
