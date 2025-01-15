// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

/**Created by Matt Lindborg
 * UAT MS636 Week 3
 * @title SafeCrowdfunding
 * @dev Safe Crowdfunding Contract
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

 contract SafeCrowdfunding {

    // state variables
    IERC20 public token;
    struct Project{
        uint256 id;
        address creator;
        uint256 goalAmount;
        uint256 currentAmount;
        uint256 startTime;
        uint256 vestingDuration;
        uint256 releasedTokens;
    }
    Project[] private _projects;
    uint256 public projectIdCounter;

    constructor() {

    }

    function createProject(uint256 _goalAmount, uint256 _vestingDuration) public {
            /*Project memory newProject = Project({
            id: projectCount,
            name: _name,
            goalAmount: _goalAmount,
            currentAmount: 0,
            isActive: true
            });

        projects[projectCount] = newProject;

        emit ProjectCreated(projectCount, _name, _goalAmount, msg.sender);
        */
    }

    function contribute(uint256 _projectId, uint256 _amount) public {

    }

    function claimFunds(uint256 _projectId) public {

    }

    function getProjectDetails(uint256 _projectId) public {

    }
 }