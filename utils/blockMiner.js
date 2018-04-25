var BlockMiner = artifacts.require("./BlockMiner.sol");

var instance = {};

/**
 * Run through blocks (e.g. so that block number will be greater than target block)
 * @param {address} addr, the address of the user who is transacting
 * @param {number}  numBlocksToMine - how far to move the block count
 * @return Function
 */

instance.mineBlocks = async function(addr, numBlocksToMine) {
  for (var i = 0; i < numBlocksToMine; i++) {
    if(typeof(this.contract) == "undefined"){
      this.contract = await BlockMiner.new();
    }
    await this.contract.mine({from: addr});
  }
};

module.exports = instance;
