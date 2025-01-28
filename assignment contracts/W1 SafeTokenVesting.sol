// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

/**Created by Matt Lindborg
 * UAT MS636 Week 1
 * @title SafeTokenVesting
 * @dev Safe Token Vesting Contract
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// token vesting contract
contract SafeTokenVesting {

    // state variables
    IERC20 public token;
    address public beneficiary;
    uint256 public startTime;
    uint256 public vestingDuration;
    uint256 public totalTokens;
    uint256 public releasedTokens;

    // events
    event TokensClaimed(address beneficiary, uint256 amount);

    // constructor initilizes with the token, beneficiary, total tokens, and vesting duration
    constructor(
        IERC20 _token,
        address _beneficiary,
        uint256 _totalTokens,
        uint256 _vestingDuration
    ) {
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

    // beneficiary can claim vested tokens
    function claimTokens() external {
        require(msg.sender == beneficiary, "Only the beneficiary can claim tokens");

        uint256 vestedTokens = getVestedTokens();
        uint256 claimableTokens = vestedTokens - releasedTokens;

        require(claimableTokens > 0, "No tokens available to claim");

        releasedTokens += claimableTokens;

        // attempt to transfer tokens to the beneficiary
        try token.transfer(beneficiary, claimableTokens) {
            emit TokensClaimed(beneficiary, claimableTokens);
        } catch {
            // rollback released tokens on failure
            releasedTokens -= claimableTokens;
            revert("Token transfer failed");
        }
    }

    // returns the amount of currently vested tokens
    function getVestedTokens() public view returns (uint256) {
        if (block.timestamp < startTime) {
            return 0; // vesting hasn't started yet
        }

        uint256 elapsedTime = block.timestamp - startTime;
        if (elapsedTime > vestingDuration) {
            elapsedTime = vestingDuration; // cap at vesting duration
        }

        return (totalTokens * elapsedTime) / vestingDuration;
    }

    // returns the contracts token balance
    function getContractBalance() external view returns (uint256) {
        return token.balanceOf(address(this));
    }
}
