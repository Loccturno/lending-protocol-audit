// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VulnerableLending {
    mapping(address => uint256) public deposits;
    mapping(address => uint256) public borrows;
    uint256 public totalLiquidity;

    event Deposit(address indexed user, uint256 amount);
    event Borrow(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event Repay(address indexed user, uint256 amount);

    function deposit() external payable {
        deposits[msg.sender] += msg.value;
        totalLiquidity += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function borrow(uint256 amount) external {
        require(amount <= totalLiquidity, "Not enough liquidity");
        require(deposits[msg.sender] >= amount / 2, "Need 50% collateral");
        
        borrows[msg.sender] += amount;
        totalLiquidity -= amount;
        
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
        emit Borrow(msg.sender, amount);
    }

    function repay() external payable {
        require(borrows[msg.sender] >= msg.value, "Overpaying");
        borrows[msg.sender] -= msg.value;
        totalLiquidity += msg.value;
        emit Repay(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external {
        require(deposits[msg.sender] >= amount, "Insufficient deposit");
        deposits[msg.sender] -= amount;
        totalLiquidity -= amount;
        
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
        emit Withdraw(msg.sender, amount);
    }
}
