// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./IERC20.sol";

contract StakingRewards {

    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);

	IERC20 public rewardsToken;
    IERC20 public stakingToken;
    uint256 public rewardEmit;

    uint256 public initPeriod;
    uint256 public finishPeriod;

    uint256 public rewardsDuration = 1 hours;
    uint256 public lastUpdateTime;

    uint256 public accReward;
    uint256 public perTokenReward;

    // 区间开始累计
    mapping(address => uint256) public reward;
    // 已发未提取奖励
    mapping(address => uint256) public undrawnFunds;
    
    uint256 private _totalSupply;
    uint256 private _interalSupply;

    // 用户持有量
    mapping(address => uint256) private _balances;


    constructor (
    	address _rewardsToken,
    	address _stakingToken
    ) {
    	rewardsToken = IERC20(_rewardsToken);
        stakingToken = IERC20(_stakingToken);
        
        initPeriod = block.timestamp;
        finishPeriod = initPeriod + 30 days;

        rewardEmit = 0.05 ether;
    }

    // View Function

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function undrawnFundsOf(address account) external view returns (uint256) {
        return undrawnFunds[account];
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return block.timestamp < finishPeriod ? block.timestamp : finishPeriod;
    }

    // Update
    function updatePerTokenReward() internal {
        if (_interalSupply == 0) {
            perTokenReward = 0;
        } else {
            perTokenReward = rewardEmit / (_interalSupply / 1e18);
        }
    }

    function updateAccReward() internal {
        uint256 addAmount = perTokenReward * (lastTimeRewardApplicable() - lastUpdateTime) / rewardsDuration;
        accReward += addAmount;
    }

    function earned(address account) public view returns (uint256) {
        uint256 addAmount = perTokenReward * (lastTimeRewardApplicable() - lastUpdateTime) / rewardsDuration;
        return (accReward + addAmount - reward[account]) * (_balances[account] / 1e18);
    }

    function stake(uint256 amount) external {
        _totalSupply += amount;
        _interalSupply += amount;

        updatePerTokenReward();
        updateAccReward();

        reward[msg.sender] = accReward;
        _balances[msg.sender] += amount;

        lastUpdateTime = block.timestamp;

        stakingToken.transferFrom(msg.sender, address(this), amount);

        emit Staked(msg.sender, amount);
    }

    function withdraw(uint256 amount) public {
        require(amount > 0, "Cannot withdraw 0");

        uint256 stackReward = earned(msg.sender);

        _balances[msg.sender] -= amount;
        _totalSupply -= amount;
        _interalSupply -= amount;

        undrawnFunds[msg.sender] += stackReward;

        updatePerTokenReward();
        updateAccReward();

        lastUpdateTime = block.timestamp;

        stakingToken.transfer(msg.sender, amount);
        
        emit Withdrawn(msg.sender, amount);
    }

    function getReward() public {
        uint256 amount = undrawnFunds[msg.sender];

        if (amount > 0) {
            rewardsToken.transfer(msg.sender, amount);

            emit RewardPaid(msg.sender, amount);
        }
    }
}