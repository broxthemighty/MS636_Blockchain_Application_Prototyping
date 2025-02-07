// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;  // Ensure using a Cancun-compatible Solidity version

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract ChainlinkPriceFeed {
    AggregatorV3Interface internal priceFeed;

    /**
     * Network: Sepolia Testnet (Supports Cancun)
     * Aggregator: ETH/USD
     * Address: 0x694AA1769357215DE4FAC081bf1f309aDC325306
     */
    constructor() {
        priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
    }

    /**
     * Returns the latest ETH/USD price with 8 decimal places
     */
    function getLatestPrice() public view returns (int) {
        (
            , 
            int price,
            ,
            ,
            
        ) = priceFeed.latestRoundData();
        return price;
    }
}
