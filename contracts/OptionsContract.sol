// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract OptionsContract is ERC20 {
    address owner;
    uint256 optionID;
    uint256 totalLiquidity; // For eth, it would just be how much ppl have single sided stake for eth
    int256 currentPrice = 2 ether; // TODO for testing purposes only in exercise option function
    AggregatorV3Interface private priceFeed;

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
        address _owner,
        address _priceFeed
    ) ERC20(_name, _symbol) {
        owner = _owner;
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    // when a user buys an option, we mint them an erc20 token
    // 0x8A753747A1Fa494EC906cE90E9f37563A8AF630e eth/usd rinkeby oracle address
    // 0x5f4ec3df9cbd43714fe2740f5e3616155c5b8419 eth/usd mainnet oracle address
    function mintOption(
        uint256 _strikePrice,
        uint256 _optionPremium,
        uint256 _expirationTime
    ) public payable {
        // uint256 currentPrice = getLatestPrice(); // price returned in wei
        uint256 currentPrice = 1 ether; // for testing purposes
        
        // TODO: add a model (potential black scholes) to calculate option premium
        require(totalLiquidity >= _strikePrice); // check that there is enough liquidty to purchase a call option at that strike
        require(
            msg.value >= _strikePrice + _optionPremium,
            "LOCK COLLATERAL: not enough eth to lock in collateral"
        );

        optionID++;
        Option memory option = Option({
            buyer: msg.sender,
            strikePrice: _strikePrice,
            optionPremium: _optionPremium,
            expirationTime: _expirationTime
        });

        activeOptions[optionID] = option;

        _mint(msg.sender, _optionPremium); // erc20 value = _optionPremium. If an option costs 2 eth, then we mint them 2 erc tokens

        emit OptionMinted(
            msg.sender,
            _strikePrice,
            _optionPremium,
            _expirationTime
        );
    }

    function exerciseOption(uint256 _optionID)
        public
        returns (uint256)
    {
        // int256 currentPrice = getLatestPrice(); // price returned in wei
        // int256 currentPrice = 2 ether; // for testing purposes
        Option storage option = activeOptions[_optionID];
        require(
            block.timestamp >= option.expirationTime - 3600,
            "not within exercise period"
        );

        int256 profit = currentPrice - int256(option.strikePrice);

        // if there is a profit, then transfer the profit to owner + strike price (locked collateral)
        // if negative profit, then just transfer the strike price (locked collateral back) - buy loses on option premium
        if (profit >= 0) {
            uint256 amountPositiveProfit = uint256(profit) + option.strikePrice;
            (bool success, ) = msg.sender.call{value: amountPositiveProfit}("");
            require(success);
        } else if (profit < 0) {
            uint256 collateralAmount = option.strikePrice;
            (bool success, ) = msg.sender.call{value: collateralAmount}("");
            require(success);
        }
        
        // burn erc20 option tokens and delete from active options mapping
        _burn(msg.sender, option.optionPremium);
        delete activeOptions[_optionID];

        emit OptionExercised(_optionID);
        return _optionID;
    }

    // price gets returned in wei
    function getLatestPrice() private view returns (int256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        return price;
    }

    function getDecimals() public view returns (uint8) {
        uint8 decimals = priceFeed.decimals();
        return decimals;
    }

    // function to simulate a user adding liquidity to a vault. Ensures there is enough liquidity for another to buy an option
    function addLiquidity() public payable {
        totalLiquidity += msg.value;
    }
}
