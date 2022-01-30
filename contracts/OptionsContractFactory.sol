// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./OptionsContract.sol";

contract OptionsContractFactory {
    address private owner;
  
    event ERC20OptionCreated(address tokenAddress);

    constructor() {
      owner = msg.sender;
    }

    modifier onlyOwner {
      require(msg.sender == owner);
      _;
    }

    function deployNewERC20Option(string calldata _name, string calldata _symbol) onlyOwner public returns (address) {
      OptionsContract token = new OptionsContract(_name, _symbol);

      emit ERC20OptionCreated(address(token));

      return address(token);
    }
}