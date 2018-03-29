var Token = artifacts.require("./DCT.sol");

module.exports = function(deployer) {
  deployer.deploy(Token);
};

