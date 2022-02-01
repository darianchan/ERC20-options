import React from "react";
import { ethers, BigNumber } from "ethers";
import optionsContractABI from './OptionsContract';

const optionsContractAddress = '0x94f26f763e0362Aabd242A473BD50A3638Bc2Cc8';
const provider = new ethers.providers.Web3Provider(window.ethereum);
const signer = provider.getSigner();
const optionsContract = new ethers.Contract(optionsContractAddress, optionsContractABI.abi, provider);

class OptionVaults extends React.Component {
  constructor(props) {
    super(props);

    this.state={
      latestETHPrice: 0
    }

    this.getETHPrice = this.getETHPrice.bind(this);
  }

  componentDidMount() {
    this.getETHPrice()
  }

  async getETHPrice() {
    let latestETHPrice = await optionsContract.getLatestPrice();
    let decimals = await optionsContract.getDecimals();
    let formattedPrice = (latestETHPrice.toString() / 10 ** decimals).toFixed(2)
    console.log(formattedPrice)
    this.setState({latestETHPrice: formattedPrice})
  }

  render() {
    return(
      <div>
        <select>
          <option value="1">1000</option>
          </select>
        <form>
          ETH/USD
          
          <br/>
          <label for="name">First name:</label>
          <input type="text"/>
          <br/>
          <label for="lname">Last name:</label>
          <input type="text" id="lname" name="lname"/>
        </form>
      </div>
    )
  }
}



export default OptionVaults;
