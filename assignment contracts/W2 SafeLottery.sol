// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

/**Created by Matt Lindborg
 * UAT MS636 Week 2
 * @title SafeLottery
 * @dev Safe Lottery Contract
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// dummy ERC20 token for testing
contract DummyToken is IERC20 {

    string public name = "Dummy Token";
    string public symbol = "DMT";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;

    constructor(uint256 initialSupply) {
        mint(msg.sender, initialSupply);
    }

    function balanceOf(address account) public view override returns (uint256) {
        return balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        balances[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        require(balances[sender] >= amount, "Insufficient balance");
        require(allowances[sender][msg.sender] >= amount, "Allowance exceeded");
        balances[sender] -= amount;
        allowances[sender][msg.sender] -= amount;
        balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return allowances[owner][spender];
    }

    // mints tokens to a specified account (for testing purposes only).
    function mint(address account, uint256 amount) public {
        totalSupply += amount;
        balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }
}

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

    // constructor initializes the lottery contract with the token, ticket price, and purchase deadline
    constructor(IERC20 _token, uint256 _ticketPrice) {
        require(address(_token) != address(0), "Token address cannot be zero");
        require(_ticketPrice > 0, "Ticket price must be greater than zero");

        token = _token;
        ticketPrice = _ticketPrice;
        ticketPurchaseDeadline = block.timestamp + 24 hours;
    }

    // purchase a ticket
    function buyTicket() public payable {
     require(block.timestamp <= ticketPurchaseDeadline, "Ticket purchase deadline has passed");

        // attempt to transfer the ticket price from the participant to the contract
        try token.transferFrom(msg.sender, address(this), ticketPrice) {
            _participants.push(msg.sender);
            emit TicketPurchased(msg.sender);
        } catch {
            revert("Token transfer failed. Ensure you approved the contract to spend tokens.");
        }
    }

    // select the _winner from _participants and try to pay them
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
            // success case: nothing to do
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