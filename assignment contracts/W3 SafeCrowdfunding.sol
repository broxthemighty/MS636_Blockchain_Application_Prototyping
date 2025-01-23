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

    // Events
    event ProjectCreated(uint256 projectId, address creator, uint256 goalAmount, uint256 vestingDuration);
    event ContributionMade(uint256 projectId, address contributor, uint256 amount);
    event FundsClaimed(uint256 projectId, address creator, uint256 amount);

    constructor(address _tokenAddress) {
        require(_tokenAddress != address(0), "Invalid token address");
        token = IERC20(_tokenAddress);
    }

    function createProject(uint256 _goalAmount, uint256 _vestingDuration) public {
        require(_goalAmount > 0, "Goal amount must be greater than zero");
        require(_vestingDuration > 0, "Vesting duration must be greater than zero");

        Project memory newProject = Project({
            id: projectIdCounter,
            creator: msg.sender,
            goalAmount: _goalAmount,
            currentAmount: 0,
            startTime: block.timestamp,
            vestingDuration: _vestingDuration,
            releasedTokens: 0

        });

        _projects.push(newProject);
        projectIdCounter++;

        emit ProjectCreated(newProject.id, msg.sender, _goalAmount, _vestingDuration);
    }

    function contribute(uint256 _projectId, uint256 _amount) public {
        require(_projectId < _projects.length, "Project does not exist");
        require(_amount > 0, "Contribution must be greater than zero");

        Project storage project = _projects[_projectId];
        require(project.currentAmount + _amount <= project.goalAmount, "Over project goal");

        // Safe token transfer using try-catch
        try token.transferFrom(msg.sender, address(this), _amount) {
            project.currentAmount += _amount;
            emit ContributionMade(_projectId, msg.sender, _amount);
        } catch Error(string memory reason) {
            revert(string(abi.encodePacked("Token transfer failed: ", reason)));
        }

    }

    function claimFunds(uint256 _projectId) public {
        require(_projectId < _projects.length, "Project does not exist");

        Project storage project = _projects[_projectId];
        require(msg.sender == project.creator, "Only the project creator can claim funds");
        require(project.currentAmount >= project.goalAmount, "Project goal not met");

        uint256 elapsedTime = block.timestamp - project.startTime;
        uint256 vestedAmount;

        if (elapsedTime >= project.vestingDuration) {
            vestedAmount = project.currentAmount; // All funds vested
        } else {
            vestedAmount = (project.currentAmount * elapsedTime) / project.vestingDuration;
        }

        uint256 releasable = vestedAmount - project.releasedTokens;
        require(releasable > 0, "No tokens available for release");

        // Safe token transfer using try-catch
        try token.transfer(project.creator, releasable) {
            project.releasedTokens += releasable;
            emit FundsClaimed(_projectId, msg.sender, releasable);
        } catch Error(string memory reason) {
            revert(string(abi.encodePacked("Token transfer failed: ", reason)));
        }
    }

    function getProjectDetails(uint256 _projectId) public view returns (Project memory) {
        require(_projectId < _projects.length, "Project does not exist");
        return _projects[_projectId];
    }
 }