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
    // map of withdrawal transactions
    mapping(address => uint256) public pendingWithdrawals;

    // map of seller withdrawals
    mapping(address => uint256) public sellerPendingWithdrawals;

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

        // Transfer new bid to escrow
        try token.transferFrom(msg.sender, address(this), _bidAmount) {
            // Refund previous highest bidder safely
            if (auction.highestBid > 0) {
                try token.transfer(auction.highestBidder, auction.highestBid) {
                    // Successful refund, nothing more to do
                } catch {
                    // Refund failed, store it for manual withdrawal
                    pendingWithdrawals[auction.highestBidder] += auction.highestBid;
                }
            }

            // Update highest bid
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
            // try transferring funds to seller
            try token.transfer(auction.seller, auction.highestBid) {
                emit AuctionFinalized(_auctionId, auction.highestBidder, auction.highestBid);
            } catch {
                // if transfer fails, store funds in pending withdrawals
                sellerPendingWithdrawals[auction.seller] += auction.highestBid;
                emit AuctionFinalized(_auctionId, auction.highestBidder, auction.highestBid);
            }
        } else {
            emit AuctionFinalized(_auctionId, address(0), 0);
        }
    }

    // allow sellers to withdraw failed payouts
    function withdrawSellerFunds() external {
        uint256 amount = sellerPendingWithdrawals[msg.sender];
        require(amount > 0, "No pending funds.");
        sellerPendingWithdrawals[msg.sender] = 0; // prevent re-entrancy attacks

        // attempt to transfer funds to the seller
        try token.transfer(msg.sender, amount) {
            // transfer success
        } catch {
            // revert and reassign funds to pending withdrawals in case of failure
            sellerPendingWithdrawals[msg.sender] = amount;
            revert("Withdraw failed.");
        }
    }

    // retrieves the details of a specific auction.
    function getAuctionDetails(uint256 _auctionId) external view returns (AuctionItem memory) {
        require(_auctionId < auctions.length, "Auction does not exist.");
        return auctions[_auctionId];
    }
}
