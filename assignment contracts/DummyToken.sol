// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

/**Created by Matt Lindborg
 * UAT MS636
 * @title DummyToken
 * @dev Dummy Token creation for testing
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


// DummyToken contract
contract DummyToken is ERC20, Ownable, ERC20Permit {

    constructor(address initialOwner)
        ERC20("DummyToken", "DMT")
        Ownable(initialOwner)
        ERC20Permit("DummyToken")
        {
            _mint(msg.sender, 10000000 * 10 ** decimals());
        }
    

    // mints new tokens to the specified address.
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}