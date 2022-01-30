// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract OptionsContract is ERC20 {
    address owner;
    uint256 optionID;

    struct Option {
        address buyer;
        uint256 strikePrice; // in wei
        uint256 optionPremium; // in wei
        uint256 expirationTime; // in seconds
    }

    mapping(uint256 => Option) activeOptions;

    event OptionMinted(
        address buyer,
        uint256 strikePrice,
        uint256 optionPremium,
        uint256 expirationTime
    );
    event OptionExercised(uint256 optionID);

    constructor(
        string memory _name,
        string memory _symbol,
        address _owner
    ) ERC20(_name, _symbol) {
        owner = _owner;
    }

    // when a user buys an option, we mint them an erc20 token
    // 0x8A753747A1Fa494EC906cE90E9f37563A8AF630e eth/usd rinkeby oracle address
    // 0x5f4ec3df9cbd43714fe2740f5e3616155c5b8419 eth/usd mainnet oracle address
    function mintOption(
        uint256 _strikePrice,
        uint256 _optionPremium,
        uint256 _expirationTime
    ) public payable {
        // TODO: check that there is enoguh liquidity to purchase an option for that strike
        // TODO: figure out how optionPremium is prices
        require(
            msg.value >= _strikePrice + _optionPremium,
            "not enough eth to lock in collateral"
        );

        optionID++;
        Option memory option = Option({
            buyer: msg.sender,
            strikePrice: _strikePrice,
            optionPremium: _optionPremium,
            expirationTime: _expirationTime
        });

        activeOptions[optionID] = option;

        _mint(msg.sender, 1); // TODO: placeholder for now, but figure out how to calculate erc20 to option value

        emit OptionMinted(
            msg.sender,
            _strikePrice,
            _optionPremium,
            _expirationTime
        );
    }

    function exerciseOption(uint256 _optionID, uint256 _currentPrice)
        public
        returns (uint256)
    {
        // TODO: get current price from a price oracle. Placeholder for now
        Option storage option = activeOptions[_optionID];
        require(
            block.timestamp >= option.expirationTime - 3600,
            "not within exercise period"
        );

        uint256 profit = option.strikePrice - _currentPrice;

        // if there is a profit, then transfer the profit to owner + strike price (locked collateral)
        // if negative profit, then just transfer the strike price (locked collateral back) - buy loses on option premium
        if (profit >= 0) {
            uint256 amountPositiveProfit = profit + option.strikePrice;
            (bool success, ) = msg.sender.call{value: amountPositiveProfit}("");
            require(success);
        } else if (profit < 0) {
            uint256 amountNegativeProfit = option.strikePrice;
            (bool success, ) = msg.sender.call{value: amountNegativeProfit}("");
            require(success);
        }

        delete activeOptions[_optionID];

        emit OptionExercised(_optionID);
        return _optionID;
    }
}
