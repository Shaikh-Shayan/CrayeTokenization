//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Funds is Ownable{
    
    event FundsReleased(uint256, address);
    uint256 public totalFunds;
    address public manager;

    constructor(){
       manager = msg.sender;
    }

    //the manager will deposit funds in the contract for repairing purposes
    function deposit() public payable{
        require(msg.value <= msg.sender.balance);
        totalFunds+= msg.value;
    }

    //Release Funds to the Recipient
    function releaseFunds(address recipient, uint256 amount) public onlyOwner {
        require(amount <= totalFunds, "Insufficient funds");
        payable(recipient).transfer(amount);
        totalFunds -= amount;
    }
}
