// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./DappToken.sol";
import "./LPToken.sol";

/**
    A super simple token farm 
*/
contract TokenFarm {
  // State variables
  DappToken public dappToken; //mock platform reward token
  LPToken public lpToken; // mock LP Token staked by users

  struct Staker {
    uint256 staking;
    uint256 checkpoint;
    uint256 pendingRewards;
    bool hasStaked;
    bool isStaker;
  }

  address public owner;   

  // rewards per block
  uint256 public constant MIN_REWARD_PER_BLOCK = 5e17;
  uint256 public constant MAX_REWARD_PER_BLOCK = 1e18;
  uint256 public rewardPerBlock = 1e18;

  // mapping of users staking and rewards info
  mapping(address => Staker) public stakers;
  uint256 public stakingBalance;
  uint256 private stakingFees;
  
  // Events
  event NewDeposit(address indexed _staker, uint256 _amount);
  event NewWithdraw(address indexed _staker, uint256 _amount);
  event RewardsClaimed(address indexed _staker, uint256 _amount);

  /**
      constructor
    */ 
  constructor(address _dappTokenAddress, address _lpTokenAddress) {
      owner = msg.sender;
      dappToken = DappToken(_dappTokenAddress);
      lpToken = LPToken(_lpTokenAddress);
  }

  modifier onlyOwner() {
    require(msg.sender == owner, 'NOT_OWNER');
    _;
  }

  modifier onlyStakingUser() {
    require(stakers[msg.sender].isStaker, 'NOT_STAKING_USER');
    _;
  }

  function setRewardPerBlock(uint256 _newReward) external onlyOwner {
    require(
      _newReward > MIN_REWARD_PER_BLOCK && _newReward < MAX_REWARD_PER_BLOCK,
      'REWARD_OUT_OF_RANGE'
    );
    rewardPerBlock = _newReward;
  }

  /**
    @notice Deposit
    Users deposits LP Tokens
    */
  function deposit(uint256 _amount) public {
    // Require amount greater than 0
    require(_amount != 0, 'AMOUNT_LESS_ZERO');

    // Trasnfer Mock LP Tokens to this contract for staking
    lpToken.transferFrom(msg.sender, address(this), _amount);
    Staker storage staker = stakers[msg.sender];
    if (staker.isStaker) {
      distributeRewards(staker);
      staker.staking = staker.staking + _amount;   
    } else {
      staker.staking = _amount;
      staker.checkpoint = block.number;
      staker.isStaker = true;
    }
    stakingBalance = stakingBalance + _amount;

    emit NewDeposit(msg.sender, _amount);
  }

  /**
    @notice Withdraw
    Unstaking LP Tokens (Withdraw all LP Tokens)
    */
  function withdraw() external onlyStakingUser {
    // Fetch staking balance
    Staker storage staker = stakers[msg.sender];
    uint256 _amount = staker.staking;
    require(_amount != 0, 'STAKING_LESS_ZERO');

    // calculate rewards before reseting staking balance
    distributeRewards(staker);
    
    staker.staking = 0;
    staker.isStaker = false;

    lpToken.transfer(msg.sender, _amount);
    
    emit NewDeposit(msg.sender, _amount);
  }

  /**
    @notice Claim Rewards
    Users harvest pendig rewards
    Pendig rewards are minted to the user
    */
  function claimRewards() external onlyStakingUser {
    // fetch pendig rewards
    Staker storage staker = stakers[msg.sender];
    distributeRewards(staker);
    uint256 reward = staker.pendingRewards;
    require(reward != 0, 'NOT_PENDING_REWARDS');
    
    staker.pendingRewards = 0;

    uint256 rewardFee = reward / 1000;
    uint256 amount = reward - rewardFee;
    stakingFees = stakingFees + rewardFee;
    dappToken.mint(msg.sender, amount);
    
    emit RewardsClaimed(msg.sender, amount);
  }

  function withdrawFees() external onlyOwner {
    dappToken.mint(msg.sender, stakingFees);
  }

  /**
    @notice Distribute rewards
    calculates rewards for the indicated beneficiary 
    */
  function distributeRewards(Staker storage beneficiary) private {
    uint256 checkpoint = beneficiary.checkpoint;

    // calculates rewards:
    if (block.number > checkpoint) {
      uint256 totalRewards = (block.number - checkpoint) * rewardPerBlock;
      uint256 reward = (totalRewards / stakingBalance) * beneficiary.staking;
      beneficiary.pendingRewards = beneficiary.pendingRewards + reward;
      beneficiary.checkpoint = block.number;
    }
  }
}
