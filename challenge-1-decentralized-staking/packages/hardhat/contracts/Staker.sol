// SPDX-License-Identifier: MIT
pragma solidity 0.8.4; //Do not change the solidity version as it negativly impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {
    ExampleExternalContract public exampleExternalContract;

    uint256 public constant threshold = 1 ether;
    uint256 public deadline = block.timestamp + 80 hours;
    bool public openForWithdraw;

    event Stake(address addressStaking, uint256 amountStaked);
    event Received(address, uint256);
    // event OpenForWithdrawal(bool);

    mapping(address => uint256) public balances;

    modifier notCompleted() {
        require(exampleExternalContract.completed() == false, "ExternalContract is already completed");
        _;
    }

    constructor(address exampleExternalContractAddress) {
        exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
    }

    // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
    // (Make sure to add a `Stake(address,uint256)` event and emit it for the frontend `All Stakings` tab to display)
    function stake() public payable notCompleted {
        // require(msg.value == amountToStake, "Incorrect amount sent");
        balances[msg.sender] += msg.value;
        emit Stake(msg.sender, msg.value);
    }

    // After some `deadline` allow anyone to call an `execute()` function
    // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`

    // If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance
    function execute() public payable notCompleted {
        require(block.timestamp >= deadline, "Block timestamp has not yet reached the deadline");
        if (address(this).balance < threshold) {
            openForWithdraw = true;
            return;
        }
        exampleExternalContract.complete{value: address(this).balance}();
    }

    function withdraw() public notCompleted {
        require(openForWithdraw, "Withdrawal is not open yet");
        require(balances[msg.sender] > 0, "No balance to withdraw");
        uint256 amountToWithdraw = balances[msg.sender];
        balances[msg.sender] = 0;
        (bool sent,) = msg.sender.call{value: amountToWithdraw}("");
        require(sent, "Failed to send Ether");
    }

    // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
    function timeLeft() public view returns (uint256) {
        if (block.timestamp >= deadline) {
            return 0;
        } else {
            return deadline - block.timestamp;
        }
    }

    // Add the `receive()` special function that receives eth and calls stake()
    receive() external payable {
        stake();
        emit Received(msg.sender, msg.value);
    }
}
