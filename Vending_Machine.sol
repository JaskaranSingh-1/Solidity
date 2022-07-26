// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

contract VendingMachine{
    address public owner;
    mapping(address => uint) public donutBalance;

    constructor(){
        owner = msg.sender;
        donutBalance[address(this)] = 100;
    }

    function getDonutBalance() public view returns (uint){
        return donutBalance[address(this)];
    }

    function purchase(uint purchaseAmount) public payable{
        require(msg.value == purchaseAmount * 1 ether, "Your Purchase balance is low, You are unable to buy Donut");
        require(donutBalance[address(this)] >= purchaseAmount, "Not Enough Donut is available in Vending Machine");
        donutBalance[address(this)] -= purchaseAmount;
        donutBalance[msg.sender] += purchaseAmount;
    }

    function restore(uint restoreAmount) public{
        require(msg.sender == owner, "Only the Owner of machine can restore it");
        donutBalance[address(this)] += restoreAmount;
    }

}