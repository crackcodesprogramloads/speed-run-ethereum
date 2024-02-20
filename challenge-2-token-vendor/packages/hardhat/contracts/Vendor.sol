pragma solidity 0.8.4; //Do not change the solidity version as it negativly impacts submission grading
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";
import "./YourToken.sol";
import "hardhat/console.sol";

contract Vendor is Ownable {
    event BuyTokens(address buyer, uint256 amountOfETH, uint256 amountOfTokens);

    YourToken public yourToken;

    uint256 public constant tokensPerEth = 100;

    event TokenWithdrawal(address toAddress, uint256 amountWithdrawn);
    event SellTokens(address seller, uint256 amountOfTokens, uint256 amountOfETH);

    constructor(address tokenAddress) {
        yourToken = YourToken(tokenAddress);
    }

    // ToDo: create a payable buyTokens() function:
    function buyTokens() external payable {
        yourToken.transfer(msg.sender, msg.value * tokensPerEth);
        emit BuyTokens(msg.sender, msg.value, msg.value * tokensPerEth);
    }

    // ToDo: create a withdraw() function that lets the owner withdraw ETH
    //  owner withdraw all the ETH from the vendor contract.
    function withdraw() external payable onlyOwner {
        (bool sent,) = msg.sender.call{value: address(this).balance}("Transfer sent");
        emit TokenWithdrawal(msg.sender, address(this).balance);
    }

    // ToDo: create a sellTokens(uint256 _amount) function:
    function sellTokens(uint256 _amount) public {
        require(yourToken.balanceOf(msg.sender) >= _amount, "Insufficient balance");
        uint256 amountOfETH = _amount / tokensPerEth;
        require(address(this).balance >= amountOfETH, "Vendor contract does not have enough Ether");

        yourToken.transferFrom(msg.sender, address(this), _amount);
        (bool sent,) = msg.sender.call{value: address(this).balance}("Transfer sent");
        emit SellTokens(msg.sender, _amount, amountOfETH);
    }
}
