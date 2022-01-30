// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract OptionsContract is ERC20 {
    address owner;
    uint optionID;

    struct Option {
        address buyer;
        uint256 strikePrice; // in wei
        uint256 optionPremium; // in wei
        uint256 expirationTime; // in seconds
    }

    mapping(uint => Option) activeOptions;

    event OptionMinted(address buyer, uint strikePrice, uint optionPremium, uint expirationTime);

    constructor(string memory _name, string memory _symbol, address _owner) ERC20(_name, _symbol) {
      owner = _owner;
    }

    // when a user buys an option, we mint them an erc20 token
    function mintOption(uint _strikePrice, uint _optionPremium, uint _expirationTime) public payable {
      // TODO: check that there is enoguh liquidity to purchase an option for that strike
      // TODO: figure out how optionPremium is prices
      require(msg.value >= _strikePrice + _optionPremium, "not enough eth to lock in collateral");

      optionID++;
      Option memory option = Option({
        buyer: msg.sender,
        strikePrice: _strikePrice,
        optionPremium: _optionPremium,
        expirationTime: _expirationTime
      });

      activeOptions[optionID] = option;

      emit OptionMinted(msg.sender, _strikePrice, _optionPremium, _expirationTime);
    }
}
