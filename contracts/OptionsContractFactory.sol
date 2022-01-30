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
    
    // price feed is the address of the chainlink oracle for the token
    function deployNewERC20Option(string calldata _name, string calldata _symbol, address _owner, address _priceFeed) onlyOwner public returns (address) {
      OptionsContract token = new OptionsContract(_name, _symbol, _owner, _priceFeed);

      emit ERC20OptionCreated(address(token));

      return address(token);
    }
}