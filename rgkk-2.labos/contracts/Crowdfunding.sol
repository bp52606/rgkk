// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Timer.sol";

/// This contract represents most simple crowdfunding campaign.
/// This contract does not protects investors from not receiving goods
/// they were promised from crowdfunding owner. This kind of contract
/// might be suitable for campaigns that does not promise anything to the
/// investors except that they will start working on some project.
/// (e.g. almost all blockchain spinoffs.)
contract Crowdfunding {

    address private owner;

    Timer private timer;

    uint256 public goal;

    uint256 public endTimestamp;

    mapping (address => uint256) public investments;
    
    uint256 public total;

    constructor(
        address _owner,
        Timer _timer,
        uint256 _goal,
        uint256 _endTimestamp
    ) {
        owner = (_owner == address(0) ? msg.sender : _owner);
        timer = _timer; // Not checking if this is correctly injected.
        goal = _goal;
        endTimestamp = _endTimestamp;
        total = 0;
    }

    function invest() public payable {

        require(timer.getTime()<endTimestamp, "The crowdfunding must be active for investment");
        investments[msg.sender] += msg.value;
        total+=msg.value;

    }

    function claimFunds() public {

        require(timer.getTime()>=endTimestamp, "The crowdfunding must be over to claim funds");
        require(total>=goal, "The money goal must be reached to claim funds");
        require(msg.sender == owner, "Only the owner can claim funds");
        payable(owner).transfer(total);

    }

    function refund() public {

        require(timer.getTime()>=endTimestamp, "The crowdfunding must be over for refunds");
        require(total<goal, "The money goal should not be reached");
        require(msg.sender != owner, "Owner can't take refunds");

        payable(msg.sender).transfer(investments[msg.sender]);

    }
    
}