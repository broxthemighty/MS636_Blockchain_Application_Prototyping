// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;


contract VendingMachine {

    address public owner;

    mapping(address => uint) public cupcakeBalances;

    // when contract is deployed
    // 1- set the deploying address as the owner
    // 2- set the deployed smart contract cupcake balance to 100
    constructor() {
        owner = msg.sender;
        cupcakeBalances[address(this)] = 100;
    }

    // allow the owner to increase the smart contract's cupcake balance
    function refill(uint _amount) public {
        require(msg.sender == owner, "Only the owner can refill");
        cupcakeBalances[address(this)] += _amount;
    }

    // allow anyone to purchase cupcakes
    function purchase(uint amount) public payable {
        require(msg.value >= amount * 1 ether, "You must pay at least 1 eth per cupcake");
        require(cupcakeBalances[address(this)] >= amount, "Not enough cupcakes available");
        cupcakeBalances[address(this)] -= amount;
        cupcakeBalances[msg.sender] += amount;
    }

}