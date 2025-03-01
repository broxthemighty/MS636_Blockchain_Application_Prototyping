// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

/**Created by Matt Lindborg
 * UAT MS636 Week 6
 * @title VotingSystem
 * @dev Voting System Contract
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// voting system contract
contract VotingSystem {
    // State variables
    IERC20 public token;
    uint256 public proposalFee;
    uint256 public voteFee;

    // proposal structure
    struct Proposal {
        uint256 id; 
        address creator; 
        string description; 
        uint256 yesVotes; 
        uint256 noVotes; 
    }
    // array of proposals
    Proposal[] public proposals; 

    // counter to generate unique proposal IDs
    uint256 public proposalIdCounter; 

    // events
    event ProposalCreated(uint256 id, address creator, string description);
    event Voted(uint256 proposalId, address voter, bool vote);

    // initializes the contract with the ERC20 token address and fees.
    constructor(IERC20 _token, uint256 _proposalFee, uint256 _voteFee) {
        require(address(_token) != address(0), "Invalid token address.");
        require(_proposalFee > 0, "Proposal fee must be greater than zero.");
        require(_voteFee > 0, "Vote fee must be greater than zero.");

        token = _token;
        proposalFee = _proposalFee;
        voteFee = _voteFee;
    }

    // allows a user to create a new proposal by paying the proposal fee.
    function createProposal(string memory _description) external {
        require(bytes(_description).length > 0, "Proposal description cannot be empty.");

        // attempt to transfer the proposal fee from the user to the contract
        try token.transferFrom(msg.sender, address(this), proposalFee) {
            proposals.push(Proposal({
                id: proposalIdCounter,
                creator: msg.sender,
                description: _description,
                yesVotes: 0,
                noVotes: 0
            }));

            emit ProposalCreated(proposalIdCounter, msg.sender, _description);

            proposalIdCounter++;
        } catch {
            revert("Proposal fee transfer failed.");
        }
    }

    // allows a user to vote on a proposal by paying the vote fee.
    function vote(uint256 _proposalId, bool _vote) external {
        require(_proposalId < proposals.length, "Proposal does not exist.");
        Proposal storage proposal = proposals[_proposalId];

        // attempt to transfer the vote fee from the user to the contract
        try token.transferFrom(msg.sender, address(this), voteFee) {
            if (_vote) {
                proposal.yesVotes++;
            } else {
                proposal.noVotes++;
            }

            emit Voted(_proposalId, msg.sender, _vote);
        } catch {
            revert("Vote fee transfer failed.");
        }
    }


    // retrieves the details of a specific proposal.
    function getProposalDetails(uint256 _proposalId) external view returns (Proposal memory) {
        require(_proposalId < proposals.length, "Proposal does not exist.");
        return proposals[_proposalId];
    }
}
