var DCT = artifacts.require('./DCT.sol');
var DCArbitration = artifacts.require('./DCArbitration.sol')
var client = artifacts.require('./client.sol')
var eth = require('../libs/ethereumjs-util');
var currentProvider = web3.currentProvider;
var web3lib = require('web3');
var blockminer = require("../utils/blockMiner");
var web4 = new web3lib(currentProvider);

contract('DCArbitration', function(accounts){
  var address0 = "0x0000000000000000000000000000000000000000";
  /*
    register
  */

/*
  fileCase
*/



  /*
    deposit
  */
it("can not transfer after deposit", function(){
    return DCT.new().then(async function(contract){
      var DCA = await DCArbitration.new(contract.address, 0,5,50,1,50,0,0,21);
      await contract.unpause({from: accounts[0]});
      await contract.mint(accounts[1], 1, {from: accounts[0]});
      await contract.transferOwnership(DCA.address, {from: accounts[0]});
      await DCA.deposit({from: accounts[1]});
      await contract.transfer(accounts[0], 1, {from: accounts[1]}).catch(()=>{});
      assert.equal((await contract.balanceOf(accounts[1])).toNumber(),1);
    })
})

/*
  withdraw
*/
it("can withdraw if no cases are active", function(){
  return DCT.new().then(async function(contract){
    var DCA = await DCArbitration.new(contract.address, 5, 10, 50, 25,100,0,0,21);
    await contract.unpause({from:accounts[0]});
    await contract.mint(accounts[1], 2, {from: accounts[0]});
    await contract.transferOwnership(DCA.address, {from: accounts[0]});
    await DCA.deposit({from: accounts[1]});
    await contract.transfer(accounts[0], 1, {from: accounts[1]}).catch(()=>{});
    assert.equal((await contract.balanceOf(accounts[1])).toNumber(),2);
    await DCA.withdraw({from: accounts[1]});
    await contract.transfer(accounts[0], 1, {from: accounts[1]}).catch(()=>{});
    assert.equal((await contract.balanceOf(accounts[1])).toNumber(),1);
  })
})
/*
  vote
*/
it("can not vote before voting period", function(){
  return DCT.new().then(async function(contract){
    var DCA = await DCArbitration.new(contract.address, 5,10,50,25,100,0,0,21);
    await contract.unpause({from: accounts[0]});
    await contract.mint(accounts[1], 50, {from: accounts[0]});
    await contract.transferOwnership(DCA.address, {from: accounts[0]});
    var clientC = await client.new(DCA.address);
    await DCA.deposit({from: accounts[1]});
    await clientC.createVideo("test", {from: accounts[4]});
    await clientC.claimVideo(1, {from: accounts[3]});
    var hash = await DCA.generateHash("nonce", true, {from: accounts[1]});
    await DCA.vote(1, hash, 25, {from: accounts[1]}).catch(()=>{});
    assert.equal((await DCA.getVoteWeight(1, {from: accounts[0]})).toNumber(),0);
  })
})

it("can only vote after the trial period", async function(){
    return DCT.new().then(async function(contract){
      DCA = await DCArbitration.new(contract.address, 5,10,50,25,100,0,0,21);
      await contract.unpause({from: accounts[0]});
      await contract.mint(accounts[1], 50, {from: accounts[0]});
      await contract.transferOwnership(DCA.address, {from: accounts[0]});
      var clientC = await client.new(DCA.address);
      await DCA.deposit({from: accounts[1]});
      await clientC.createVideo("test", {from: accounts[4]});
      await clientC.claimVideo(1, {from: accounts[3]});
      var hash = await DCA.generateHash("nonce", true, {from: accounts[1]});
      await blockminer.mineBlocks(accounts[0], 10);
      await DCA.vote(1, hash, 25, {from: accounts[1]}).catch();
      assert.equal((await DCA.getVoteWeight(1, {from: accounts[0]})).toNumber(),25);
    });
})
/*
  unlock
*/

it("can not unlock votes before the voting period", function(){
    return DCT.new().then(async function(contract){
      DCA = await DCArbitration.new(contract.address, 5,10,50,25,100,0,0,21);
      await contract.unpause({from: accounts[0]});
      await contract.mint(accounts[1], 50, {from: accounts  [0]});
      await contract.transferOwnership(DCA.address, {from: accounts[0]});
      var clientC = await client.new(DCA.address);
      await DCA.deposit({from: accounts[1]});
      await clientC.createVideo("test", {from: accounts[4]});
      await clientC.claimVideo(1, {from: accounts[3]});
      var hash = await DCA.generateHash("nonce", true, {from: accounts[1]});
      await blockminer.mineBlocks(accounts[0], 10);
      await DCA.vote(1, hash, 25, {from: accounts[1]}).catch();
      assert.equal((await DCA.getVoteWeight(1, {from: accounts[0]})).toNumber(),25);
      await DCA.unlock(true, "nonce", 1, {from: accounts[1]}).catch(()=>{});
      assert.equal((await DCA.getV(true, 1)).toNumber(), 0);
    })
})
it("can only unlock votes after the voting period", function(){
    return DCT.new().then(async function(contract){
      DCA = await DCArbitration.new(contract.address, 5,10,50,25,100,0,0,21);
      await contract.unpause({from: accounts[0]});
      await contract.mint(accounts[1], 50, {from: accounts  [0]});
      await contract.transferOwnership(DCA.address, {from: accounts[0]});
      var clientC = await client.new(DCA.address);
      await DCA.deposit({from: accounts[1]});
      await clientC.createVideo("test", {from: accounts[4]});
      await clientC.claimVideo(1, {from: accounts[3]});
      var hash = await DCA.generateHash("nonce", true, {from: accounts[1]});
      await blockminer.mineBlocks(accounts[0], 10);
      await DCA.vote(1, hash, 25, {from: accounts[1]}).catch();
      assert.equal((await DCA.getVoteWeight(1, {from: accounts[0]})).toNumber(),25);
      await blockminer.mineBlocks(accounts[0], 5);
      await DCA.unlock(true, "nonce", 1, {from: accounts[1]});
      assert.equal((await DCA.getV(true, 1)).toNumber(), 25);
    })
})

/*
  Finalize
*/
it("can not finalize a case before the unlocking period ends", function(){
    return DCT.new().then(async function(contract){
      DCA = await DCArbitration.new(contract.address, 5,10,50,25,100,0,0,21);
      await contract.unpause({from: accounts[0]});
      await contract.mint(accounts[1], 50, {from: accounts  [0]});
      await contract.transferOwnership(DCA.address, {from: accounts[0]});
      var clientC = await client.new(DCA.address);
      await DCA.deposit({from: accounts[1]});
      await clientC.createVideo("test", {from: accounts[4]});
      await clientC.claimVideo(1, {from: accounts[3]});
      var hash = await DCA.generateHash("nonce", true, {from: accounts[1]});
      await blockminer.mineBlocks(accounts[0], 10);
      await DCA.vote(1, hash, 25, {from: accounts[1]}).catch();
      assert.equal((await DCA.getVoteWeight(1, {from: accounts[0]})).toNumber(),25);
      await blockminer.mineBlocks(accounts[0], 5);
      await DCA.unlock(true, "nonce", 1, {from: accounts[1]});
      assert.equal((await DCA.getV(true, 1)).toNumber(), 25);
      await DCA.finalize(1, {from: accounts[2]}).catch(()=>{});
      assert.equal(await clientC.getVideoOwner(1), accounts[4]);
    })
})

it("can only finalize a case after the unlocking period", function(){
    return DCT.new().then(async function(contract){
      DCA = await DCArbitration.new(contract.address, 5,10,50,25,100,0,0,21);
      await contract.unpause({from: accounts[0]});
      await contract.mint(accounts[1], 50, {from: accounts  [0]});
      await contract.transferOwnership(DCA.address, {from: accounts[0]});
      var clientC = await client.new(DCA.address);
      await DCA.deposit({from: accounts[1]});
      await clientC.createVideo("test", {from: accounts[4]});
      await clientC.claimVideo(1, {from: accounts[3]});
      var hash = await DCA.generateHash("nonce", true, {from: accounts[1]});
      await blockminer.mineBlocks(accounts[0], 10);
      await DCA.vote(1, hash, 25, {from: accounts[1]}).catch();
      assert.equal((await DCA.getVoteWeight(1, {from: accounts[0]})).toNumber(),25);
      await blockminer.mineBlocks(accounts[0], 5);
      await DCA.unlock(true, "nonce", 1, {from: accounts[1]});
      assert.equal((await DCA.getV(true, 1)).toNumber(), 25);
      await blockminer.mineBlocks(accounts[0], 5);
      await DCA.finalize(1, {from: accounts[2]});
      assert.equal(await clientC.getVideoOwner(1), accounts[3]);
    })
})
/*
  claimReward
*/
it("can claim the reward after case is finalized and round is over", function(){
    return DCT.new().then(async function(contract){
      DCA = await DCArbitration.new(contract.address, 5,10,50,25,100,0,0,21);
      await contract.unpause({from: accounts[0]});
      await contract.mint(accounts[1], 50, {from: accounts  [0]});
      await contract.transferOwnership(DCA.address, {from: accounts[0]});
      var clientC = await client.new(DCA.address);
      await DCA.deposit({from: accounts[1]});
      await clientC.createVideo("test", {from: accounts[4]});
      await clientC.claimVideo(1, {from: accounts[3]});
      var hash = await DCA.generateHash("nonce", true, {from: accounts[1]});
      await blockminer.mineBlocks(accounts[0], 10);
      await DCA.vote(1, hash, 25, {from: accounts[1]}).catch();
      assert.equal((await DCA.getVoteWeight(1, {from: accounts[0]})).toNumber(),25);
      await blockminer.mineBlocks(accounts[0], 5);
      await DCA.unlock(true, "nonce", 1, {from: accounts[1]});
      assert.equal((await DCA.getV(true, 1)).toNumber(), 25);
      await blockminer.mineBlocks(accounts[0], 5);
      await DCA.finalize(1, {from: accounts[2]});
      assert.equal(await clientC.getVideoOwner(1), accounts[3]);
      await blockminer.mineBlocks(accounts[0], 5);
      await DCA.claimReward({from: accounts[1]});
      assert.equal((await contract.balanceOf.call(accounts[1])).toNumber(), 100);
    })
})
it("can get penalized after case is finalized and round is over", function(){
    return DCT.new().then(async function(contract){
      DCA = await DCArbitration.new(contract.address, 5,10,5000,25,100,0,0,21);
      await contract.unpause({from: accounts[0]});
      await contract.mint(accounts[1], 50, {from: accounts  [0]});
      await contract.mint(accounts[4], 50, {from: accounts  [0]});
      await contract.mint(accounts[5], 50, {from: accounts  [0]});
      await contract.mint(accounts[6], 50, {from: accounts  [0]});
      await contract.mint(accounts[ 7], 50, {from: accounts  [0]});
      await contract.transferOwnership(DCA.address, {from: accounts[0]});
      var clientC = await client.new(DCA.address);
      await DCA.deposit({from: accounts[1]});
      await DCA.deposit({from: accounts[4]});
      await DCA.deposit({from: accounts[5]});
      await DCA.deposit({from: accounts[6]});
      await DCA.deposit({from: accounts[7]});
      await clientC.createVideo("test", {from: accounts[4]});
      await clientC.claimVideo(1, {from: accounts[3]});
      var hash = await DCA.generateHash("nonce", true, {from: accounts[1]});
      var hash1 = await DCA.generateHash("nonce1", true, {from: accounts[4]});
      var hash2 = await DCA.generateHash("nonce2", true, {from: accounts[5]});
      var hash4 = await DCA.generateHash("nonce4", false, {from: accounts[7]});
      await blockminer.mineBlocks(accounts[0], 11);
      await DCA.vote(1, hash, 25, {from: accounts[1]}).catch();
      await DCA.vote(1, hash1, 25, {from: accounts[4]}).catch();
      await DCA.vote(1, hash2, 25, {from: accounts[5]}).catch();
      // await DCA.vote(1, hash3, 25, {from: accounts[6]}).catch();
      await DCA.vote(1, hash4, 25, {from: accounts[7]}).catch();
      // assert.equal((await DCA.getVoteWeight(1, {from: accounts[0]})).toNumber(),100);
      // await blockminer.mineBlocks(accounts[0], 1);
      await DCA.unlock(true, "nonce", 1, {from: accounts[1]});
      await DCA.unlock(true, "nonce1", 1, {from: accounts[4]});
      await DCA.unlock(true, "nonce2", 1, {from: accounts[5]});
      // // await DCA.unlock(true, "nonce3", 1, {from: accounts[6]});
      await DCA.unlock(false, "nonce4", 1, {from: accounts[7]});
      assert.equal((await DCA.getV(true, 1)).toNumber(), 75);
      assert.equal((await DCA.getV(false, 1)).toNumber(), 25);
      await blockminer.mineBlocks(accounts[0], 5);
      await DCA.finalize(1, {from: accounts[2]});
      assert.equal(await clientC.getVideoOwner(1), accounts[3]);
      await blockminer.mineBlocks(accounts[0], 5);
      await DCA.claimReward({from: accounts[1]});
      await DCA.claimReward({from: accounts[4]});
      await DCA.claimReward({from: accounts[5]});
      // await DCA.claimReward({from: accounts[6]});
      receipt = await DCA.claimReward({from: accounts[7]});
      const gasUsed = receipt.receipt.gasUsed;
      console.log(`ClaimReward GasUsed: ${receipt.receipt.gasUsed}`);
      assert.equal((await contract.balanceOf.call(accounts[1])).toNumber(), 1050);
      assert.equal((await contract.balanceOf.call(accounts[4])).toNumber(), 1050);
      assert.equal((await contract.balanceOf.call(accounts[5])).toNumber(), 1050);
      // assert.equal((await contract.balanceOf.call(accounts[6])).toNumber(), 62);
      assert.equal((await contract.balanceOf.call(accounts[7])).toNumber(), 0);
    })
})
it("can report cases", function(){
    return DCT.new().then(async function(contract){
      DCA = await DCArbitration.new(contract.address, 5,10,5000,25,100,100,10,21);
      await contract.unpause({from: accounts[0]});
      await contract.mint(accounts[1], 50, {from: accounts  [0]});
      await contract.mint(accounts[4], 50, {from: accounts  [0]});
      await contract.mint(accounts[5], 50, {from: accounts  [0]});
      await contract.mint(accounts[6], 50, {from: accounts  [0]});
      await contract.mint(accounts[3], 300, {from: accounts  [0]});
      await contract.mint(accounts[7], 50, {from: accounts  [0]});
      await contract.mint(accounts[8], 500, {from: accounts[0]});
      await contract.mint(accounts[9], 500, {from: accounts[0]});
      await contract.mint(accounts[10], 500, {from: accounts[0]});
      await contract.transferOwnership(DCA.address, {from: accounts[0]});
      var clientC = await client.new(DCA.address);
      await DCA.deposit({from: accounts[1]});
      await DCA.signal(accounts[10], {from: accounts[9]});
      witnessFee = await DCA.becomeWitness("Ihab",{from: accounts[10]});
      // const gasUsed = witnessFee.receipt.gasUsed;
      // console.log(`BecomeWitness  GasUsed: ${receipt.receipt.gasUsed}`);
      await DCA.deposit({from: accounts[4]});
      await DCA.deposit({from: accounts[5]});
      await DCA.deposit({from: accounts[6]});
      await DCA.deposit({from: accounts[7]});
      await clientC.createVideo("test", {from: accounts[4]});
      await clientC.claimVideo(1, {from: accounts[3]});
      var hash = await DCA.generateHash("nonce", true, {from: accounts[1]});
      var hash1 = await DCA.generateHash("nonce1", true, {from: accounts[4]});
      var hash2 = await DCA.generateHash("nonce2", true, {from: accounts[5]});
      var hash4 = await DCA.generateHash("nonce4", false, {from: accounts[7]});
      await DCA.reportCase(1, {from: accounts[3]});
      await blockminer.mineBlocks(accounts[0], 10);

      await DCA.vote(1, hash, 25, {from: accounts[1]}).catch();
      await DCA.vote(1, hash1, 25, {from: accounts[4]}).catch();
      await DCA.vote(1, hash2, 25, {from: accounts[5]}).catch();
      // await DCA.vote(1, hash3, 25, {from: accounts[6]}).catch();
      await DCA.vote(1, hash4, 25, {from: accounts[7]}).catch();
      // assert.equal((await DCA.getVoteWeight(1, {from: accounts[0]})).toNumber(),100);
      // await blockminer.mineBlocks(accounts[0], 1);
      await blockminer.mineBlocks(accounts[0], 1);
      await DCA.unlock(true, "nonce", 1, {from: accounts[1]});
      await DCA.unlock(true, "nonce1", 1, {from: accounts[4]});
      await DCA.unlock(true, "nonce2", 1, {from: accounts[5]});
      // // await DCA.unlock(true, "nonce3", 1, {from: accounts[6]});
      await DCA.unlock(false, "nonce4", 1, {from: accounts[7]});
      assert.equal((await DCA.getV(true, 1)).toNumber(), 75);
      assert.equal((await DCA.getV(false, 1)).toNumber(), 25);
      await blockminer.mineBlocks(accounts[0], 5);
      await DCA.finalize(1, {from: accounts[2]});
      assert.equal(await clientC.getVideoOwner(1), accounts[3]);
      await blockminer.mineBlocks(accounts[0], 1);
      await DCA.decideReport(1, {from:accounts[10]});
      await blockminer.mineBlocks(accounts[0], 4);

      await DCA.claimReward({from: accounts[1]});
      await DCA.claimReward({from: accounts[4]});
      await DCA.claimReward({from: accounts[5]});
      // await DCA.claimReward({from: accounts[6]});
      receipt = await DCA.claimReward({from: accounts[7]});
      // const gasUsed = receipt.receipt.gasUsed;
      // console.log(`ClaimReward GasUsed: ${receipt.receipt.gasUsed}`);
      await blockminer.mineBlocks(accounts[0], 10);
      assert.equal((await contract.balanceOf.call(accounts[1])).toNumber(), 50);
      assert.equal((await contract.balanceOf.call(accounts[4])).toNumber(), 50);
      assert.equal((await contract.balanceOf.call(accounts[5])).toNumber(), 50);
      // assert.equal((await contract.balanceOf.call(accounts[6])).toNumber(), 62);
      assert.equal((await contract.balanceOf.call(accounts[7])).toNumber(), 50);
    })
})

})
