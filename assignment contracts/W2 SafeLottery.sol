// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

/**Created by Matt Lindborg
 * UAT MS636 Week 2
 * @title SafeLottery
 * @dev Safe Lottery Contract
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// safe lottery contract
 contract SafeLottery {

    // state variables
    IERC20 public token;
    address[] private _participants;
    address private _winner;
    uint256 public ticketPrice;
    uint256 public ticketPurchaseDeadline;

    // event Outputs
    event TicketPurchased(address participant);
    event WinnerSelected(address winner);
    event PayoutFailed(address winner, uint256 amount);

    // constructor initializes token, ticket price, and purchase deadline
    constructor(IERC20 _token, uint256 _ticketPrice) {
        require(address(_token) != address(0), "Token address cannot be zero");
        require(_ticketPrice > 0, "Ticket price must be greater than zero");

        token = _token;
        ticketPrice = _ticketPrice;
        ticketPurchaseDeadline = block.timestamp + 120;
    }

    // purchase a ticket
    function buyTicket() public {
        require(block.timestamp <= ticketPurchaseDeadline, "Ticket purchase deadline has passed");

        // check the allowance
        uint256 allowance = token.allowance(msg.sender, address(this));
        require(allowance >= ticketPrice, "Insufficient allowance. Approve the contract to spend tokens.");

        // try to transfer the tokens
        try token.transferFrom(msg.sender, address(this), ticketPrice) {
            // if successful, add the participant to the list
             _participants.push(msg.sender);
            emit TicketPurchased(msg.sender);
        } catch {
            // handle any token transfer failure
            revert("Token transfer failed. Ensure sufficient balance and proper approval.");
        }
    }

    // select the winner from participants and try to pay them
    function selectWinner() public {
        require(block.timestamp > ticketPurchaseDeadline, "Cannot select a winner before the deadline");
        require(_participants.length > 0, "No participants in the lottery");
        require(_winner == address(0), "Winner has already been selected");

        // generate a random index to select the winner
        uint256 randomIndex = generateRandomNumber() % _participants.length;
        _winner = _participants[randomIndex];
        emit WinnerSelected(_winner);

        // attempt to transfer the entire contract's token balance to the winner
        uint256 prizeAmount = token.balanceOf(address(this));
        try token.transfer(_winner, prizeAmount) {
            // success
        } catch {
            emit PayoutFailed(_winner, prizeAmount);
        }
    }

    // returns the list of participants
    function getParticipants() public view returns (address[] memory) {
        return _participants;
    }

     // using current block number, block timestamp, and contract address as inputs for randomness
    function generateRandomNumber() public view returns(uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, block.number, address(this))));
    }
 }