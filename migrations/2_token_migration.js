var Token = artifacts.require("./Token/DCT.sol");

module.exports = function(deployer) {
  deployer.deploy(Token);
};
