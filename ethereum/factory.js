import web3 from './web3';
import VotacionFactory from './build/CampaignFactory.json';

const instance = new web3.eth.Contract(
  JSON.parse(VotacionFactory.interface),
  '0x4Ec317d8d391cCB6dD3856B4615FC1A37927b9Bc'
);

export default instance;
