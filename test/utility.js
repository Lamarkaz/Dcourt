var BlockMiner = artifacts.require("./BlockMiner.sol");

var instance = {};

/**
 * Run through blocks (e.g. so that block number will be greater than target block)
 * @param {address} addr, the address of the user who is transacting
 * @param {number}  numBlocksToMine - how far to move the block count
 * @return Function
 */
instance.mineBlocks = function(addr, numBlocksToMine) {
  return function () {
    return new Promise(function (resolve) {
      BlockMiner.deployed().then(function (blockMiner) {
        var miners = [];
        for (var ii = 0; ii < numBlocksToMine; ii++) {
          miners.push(blockMiner.mine({from: addr}));
        }
        return Promise.all(miners).then(resolve);
      });
    });
  }
};

module.exports = instance;
