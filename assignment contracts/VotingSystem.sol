// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

/**Created by Matt Lindborg
 * UAT MS636 Week 6
 * @title VotingSystem
 * @dev Voting System Contract
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract VotingSystem {

    // state variables
    IERC20 public token;
    uint256 public proposalFee;
    uint256 public voteFee;
    struct Proposal {
        uint256 id;
        address creator;
        string description;
        uint256 yesVotes;
        uint256 noVotes;
    }

    Proposal[] public proposals;
    uint256 public proposalIdCounter;

    constructor() {

    }

    function createProposal(string memory _description) public {

    }

    function vote(uint256 _proposalId, bool _vote) public {

    }

    function getProposalDetails(uint256 _proposalId) public view returns (Proposal memory) {
        
    }
}