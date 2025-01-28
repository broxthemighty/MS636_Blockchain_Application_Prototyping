// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

/**Created by Matt Lindborg
 * UAT MS636
 * @title DummyToken
 * @dev Dummy Token creation for testing
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// DummyToken contract
contract DummyToken is ERC20 {
    constructor()
        ERC20("DummyToken", "DMT") {}

    // mints new tokens to the specified address.
    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}