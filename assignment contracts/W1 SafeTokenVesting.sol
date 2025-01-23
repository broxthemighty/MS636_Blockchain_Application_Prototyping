// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

/**Created by Matt Lindborg
 * UAT MS636 Week 1
 * @title SafeTokenVesting
 * @dev Safe Token Vesting Contract
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */

// Professor is going to check this one out himself

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

 contract SafeTokenVesting {

   // state variables
   IERC20 token;
   address beneficiary;
   uint256 startTime;
   uint256 vestingDuration;
   uint256 totalTokens;
   uint256 releasedTokens;

   // events
   event TokensClaimed(address beneficiary, uint256 amount);

   constructor(
      IERC20 _token,
      address _beneficiary,
      uint256 _totalTokens,
      uint256 _vestingDuration
    ) 
    {
         require(address(_token) != address(0), "Token address cannot be zero");
         require(_beneficiary != address(0), "Beneficiary cannot be zero address");
         require(_vestingDuration > 0, "Vesting duration must be greater than zero");
         require(_totalTokens > 0, "Total tokens must be greater than zero");

         token = _token;
         beneficiary = _beneficiary;
         totalTokens = _totalTokens;
         vestingDuration = _vestingDuration;
         startTime = block.timestamp;
    }

    // allows beneficiary to claim vested tokens
    // should only release them once the vesting duration is finished
    // uses try catch to safely deliver tokens and handle errors
    function claimTokens() external {
        require(msg.sender == beneficiary, "Only the beneficiary can claim tokens");

        uint256 vestedTokens = getVestedTokens();
        uint256 claimableTokens = vestedTokens - releasedTokens;

        require(claimableTokens > 0, "No tokens available to claim");

        releasedTokens += claimableTokens;

        try token.transfer(beneficiary, claimableTokens) {
            emit TokensClaimed(beneficiary, claimableTokens);
        } catch {
            // Rollback released tokens in case of transfer failure
            releasedTokens -= claimableTokens;
            revert("Token transfer failed");
        }
    }

    // calculates and returns the number of tokens vested based on the current time
    function getVestedTokens() public view returns (uint256) {
        if (block.timestamp < startTime) {
            return 0; // Vesting hasn't started
        }

        uint256 elapsedTime = block.timestamp - startTime;
        if (elapsedTime > vestingDuration) {
            elapsedTime = vestingDuration; // Cap at vesting duration
        }

        return (totalTokens * elapsedTime) / vestingDuration;
    }
    
 }