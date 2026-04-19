// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FixedLending {
    mapping(address => uint256) public deposits;
    mapping(address => uint256) public borrows;
    mapping(address => uint256) public lockedCollateral;
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
        
        uint256 collateralNeeded = amount / 2;
        require(
            deposits[msg.sender] - lockedCollateral[msg.sender] >= collateralNeeded,
            "Need 50% collateral"
        );

        // FIX 1: Lock collateral πριν δώσεις το δάνειο
        lockedCollateral[msg.sender] += collateralNeeded;
        borrows[msg.sender] += amount;
        totalLiquidity -= amount;

        // FIX 2: Check-Effects-Interactions
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
        
        emit Borrow(msg.sender, amount);
    }

    function repay() external payable {
        require(borrows[msg.sender] >= msg.value, "Overpaying");
        
        // FIX 3: Unlock collateral όταν αποπληρώνεις
        uint256 collateralToUnlock = msg.value / 2;
        lockedCollateral[msg.sender] -= collateralToUnlock;
        borrows[msg.sender] -= msg.value;
        totalLiquidity += msg.value;
        
        emit Repay(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external {
        // FIX 4: Δεν μπορείς να κάνεις withdraw locked collateral
        uint256 available = deposits[msg.sender] - lockedCollateral[msg.sender];
        require(available >= amount, "Insufficient available deposit");

        // FIX 5: Check-Effects-Interactions — update state ΠΡΙΝ το transfer
        deposits[msg.sender] -= amount;
        totalLiquidity -= amount;

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
        
        emit Withdraw(msg.sender, amount);
    }
}
