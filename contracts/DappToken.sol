// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DappToken is ERC20 {
  constructor() ERC20('Dapp Token', 'DAPP') {}

  function mint(address beneficiary, uint256 mintAmount) external {
    _mint(beneficiary, mintAmount);
  }
}