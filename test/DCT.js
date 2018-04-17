var DCT = artifacts.require('./DCT.sol');
var DCArbitration = artifacts.require('./DCArbitration.sol')
var eth = require('../lib/ethereumjs-util');
var currentProvider = web3.currentProvider;
var web3lib = require('web3');
var web4 = new web3lib(currentProvider);
contract('DCT', function(accounts){

  /*
    transfer()
  */
  var address0 = "0x0000000000000000000000000000000000000000";

  it("should not allow transfers by non owners when paused", function(){
    return DCT.new().then(async function(contract){
      await contract.mint(accounts[1], 1, {from:accounts[0]});
      await contract.transfer(accounts[0], 1, {from:accounts[1]}).catch(() => {});
      assert.equal((await contract.balanceOf.call(accounts[1])).toNumber(), 1);
      assert.equal((await contract.balanceOf.call(accounts[0])).toNumber(), 0);
    })
  });
  it("should allow transfers by owner when paused", function(){
    return DCT.new().then(async function(contract){
      await contract.mint(accounts[0], 1, {from:accounts[0]});
      await contract.transfer(accounts[1], 1, {from:accounts[0]}).catch(() => {});
      assert.equal((await contract.balanceOf.call(accounts[1])).toNumber(), 1);
      assert.equal((await contract.balanceOf.call(accounts[0])).toNumber(), 0);
    })
  });
  it("should allow transfers when unpaused", function(){
    return DCT.new().then(async function(contract){
      await contract.unpause({from:accounts[0]});
      await contract.mint(accounts[0], 1, {from:accounts[0]});
      await contract.transfer(accounts[1], 1, {from:accounts[0]});
      assert.equal((await contract.balanceOf.call(accounts[0])).toNumber(), 0);
      assert.equal((await contract.balanceOf.call(accounts[1])).toNumber(), 1);
    })
  })
  it("should not allow transfers to address(0)", function(){
    return DCT.new().then(async function(contract){
      await contract.unpause({from:accounts[0]});
      await contract.mint(accounts[1], 1, {from:accounts[0]});
      await contract.transfer(address0, 1, {from:accounts[0]}).catch(() => {});
      assert.equal((await contract.balanceOf.call(accounts[1])).toNumber(), 1);
      assert.equal((await contract.balanceOf.call(address0)).toNumber(), 0);
    })
  })
  it("should not allow transfers bigger than balance", function(){
    return DCT.new().then(async function(contract){
      await contract.unpause({from:accounts[0]});
      await contract.mint(accounts[1], 1, {from:accounts[0]});
      await contract.transfer(accounts[2], 2, {from:accounts[1]}).catch(() => {});
      assert.equal((await contract.balanceOf.call(accounts[1])).toNumber(), 1);
      assert.equal((await contract.balanceOf.call(accounts[2])).toNumber(), 0);
    })
  })
  it("should transfer vote weight with tokens", function(){
    return DCT.new().then(async function(contract){
      var othercontract1 = await DCT.new();
      var othercontract2 = await DCT.new();
      await contract.unpause({from:accounts[0]});
      await contract.mint(accounts[1], 1, {from:accounts[0]});
      await contract.mint(accounts[2], 1, {from:accounts[0]});
      await contract.signal(othercontract1.address, {from:accounts[1]});
      await contract.signal(othercontract2.address, {from:accounts[2]});
      await contract.transfer(accounts[2], 1, {from:accounts[1]});
      assert.equal((await contract.balanceOf.call(accounts[1])).toNumber(), 0);
      assert.equal((await contract.balanceOf.call(accounts[2])).toNumber(), 2);
      assert.equal((await contract.owners.call(othercontract1.address, {from:accounts[0]})).toNumber(), 0);
      assert.equal((await contract.owners.call(othercontract2.address, {from:accounts[0]})).toNumber(), 2);
    })
  })
  it("should not allow transfer overflows", function(){
    return DCT.new().then(async function(contract){
      await contract.unpause({from:accounts[0]});
      await contract.mint(accounts[1], 2**256, {from:accounts[0]}).catch(()=>{});
      await contract.transfer(accounts[2], 2**256, {from:accounts[1]}).catch(()=>{});
      assert.equal((await contract.balanceOf.call(accounts[1])).toNumber(), 0);
      assert.equal((await contract.balanceOf.call(accounts[2])).toNumber(), 0);
    })
  })

  /*
    transferFrom()
  */

  it("should not transferFrom more than allowed", function(){
    return DCT.new().then(async function(contract){
      await contract.unpause({from:accounts[0]});
      await contract.mint(accounts[1],2, {from:accounts[0]});
      await contract.approve(accounts[2], 1, {from:accounts[1]});
      await contract.transferFrom(accounts[1], accounts[3], 1, {from:accounts[2]});
      assert((await contract.balanceOf(accounts[1])).toNumber(), 1);
      assert((await contract.balanceOf(accounts[3])).toNumber(), 1);
      await contract.transferFrom(accounts[1], accounts[3], 1, {from:accounts[2]}).catch(()=>{});
      assert((await contract.balanceOf(accounts[1])).toNumber(), 1);
      assert((await contract.balanceOf(accounts[3])).toNumber(), 1);
    })
  })

  it("should not allow transferFrom by non owners when paused", function(){
    return DCT.new().then(async function(contract){
      await contract.unpause({from:accounts[0]});
      await contract.mint(accounts[1],1, {from:accounts[0]});
      await contract.approve(accounts[2], 1, {from:accounts[1]});
      await contract.pause({from:accounts[0]});
      await contract.transferFrom(accounts[1], accounts[3], 1, {from:accounts[2]}).catch(()=>{});
      assert.equal((await contract.balanceOf.call(accounts[1])).toNumber(), 1);
      assert.equal((await contract.balanceOf.call(accounts[3])).toNumber(), 0);
    })
  });

  it("should allow transferFrom by owner when paused", function(){
    return DCT.new().then(async function(contract){
      await contract.unpause({from:accounts[0]});
      await contract.mint(accounts[0],1, {from:accounts[0]});
      await contract.approve(accounts[1], 1, {from:accounts[0]});
      await contract.pause({from:accounts[0]});
      await contract.transferFrom(accounts[0], accounts[2], 1, {from:accounts[1]}).catch(()=>{});
      assert.equal((await contract.balanceOf.call(accounts[0])).toNumber(), 1);
      assert.equal((await contract.balanceOf.call(accounts[2])).toNumber(), 0);
    })
  });

  it("should not allow transferFrom to address(0)", function(){
    return DCT.new().then(async function(contract){
      await contract.unpause({from:accounts[0]});
      await contract.mint(accounts[1], 1, {from:accounts[0]});
      await contract.approve(accounts[2], 1, {from:accounts[1]});
      await contract.transferFrom(accounts[1], address0, 1, {from:accounts[2]}).catch(()=>{});
      assert.equal((await contract.balanceOf.call(accounts[1])).toNumber(), 1);
      assert.equal((await contract.balanceOf.call(address0)).toNumber(), 0);
    })
  })

  it("should transfer vote weight with tokens on transferFrom", function(){
    return DCT.new().then(async function(contract){
      var othercontract1 = await DCT.new();
      var othercontract2 = await DCT.new();
      await contract.unpause({from:accounts[0]});
      await contract.mint(accounts[1], 1, {from:accounts[0]});
      await contract.mint(accounts[2], 1, {from:accounts[0]});
      await contract.signal(othercontract1.address, {from:accounts[1]});
      await contract.signal(othercontract2.address, {from:accounts[2]});
      await contract.approve(accounts[3], 1, {from:accounts[1]});
      await contract.transferFrom(accounts[1], accounts[2], 1, {from:accounts[3]});
      assert.equal((await contract.balanceOf.call(accounts[1])).toNumber(), 0);
      assert.equal((await contract.balanceOf.call(accounts[2])).toNumber(), 2);
      assert.equal((await contract.owners.call(othercontract1.address, {from:accounts[0]})).toNumber(), 0);
      assert.equal((await contract.owners.call(othercontract2.address, {from:accounts[0]})).toNumber(), 2);
    })
  })

  it("should not allow transferFrom overflows", function(){
    return DCT.new().then(async function(contract){
      await contract.unpause({from:accounts[0]});
      await contract.mint(accounts[1], 2**256, {from:accounts[0]}).catch(()=>{});
      await contract.approve(accounts[3], 1, {from:accounts[1]});
      await contract.transferFrom(accounts[1], accounts[2], 2**256, {from:accounts[3]}).catch(()=>{});
      assert.equal((await contract.balanceOf.call(accounts[1])).toNumber(), 0);
      assert.equal((await contract.balanceOf.call(accounts[2])).toNumber(), 0);
    })
  })
  it("should not allow transferFroms bigger than balance", function(){
    return DCT.new().then(async function(contract){
      await contract.unpause({from:accounts[0]});
      await contract.mint(accounts[1], 1, {from:accounts[0]});
      await contract.approve(accounts[2], 2, {from:accounts[1]}).catch(() => {});
      await contract.transferFrom(accounts[1], accounts[3], 2, {from:accounts[2]}).catch(()=>{});
      assert.equal((await contract.balanceOf.call(accounts[1])).toNumber(), 1);
      assert.equal((await contract.balanceOf.call(accounts[3])).toNumber(), 0);
    })
  })
  /*
    setSaleContract()
 */
 it("should only allow setSaleContract for contract addresses", function(){
     return DCT.new().then(async function(contract){
       await contract.setSaleContract(accounts[1], {from: accounts[0]}).catch(() => {});
       assert.equal(await contract.saleContract.call(),address0);
       var othercontract = await DCT.new();
       await contract.setSaleContract(othercontract.address, {from: accounts[0]});
       assert.equal(await contract.saleContract.call(), othercontract.address);
     });
 })

 /*
    mint()
 */

it("should increase vote after mint", function(){
  return DCT.new().then(async function(contract){
    var othercontract1 = await DCT.new();
    await contract.mint(accounts[1], 1,{from:accounts[0]});
    await contract.mint(accounts[2], 2, {from:accounts[0]});
    await contract.unpause({from:accounts[0]});
    await contract.signal(othercontract1.address, {from:accounts[1]});
    await contract.mint(accounts[1],1,{from:accounts[0]});
    assert.equal((await contract.owners.call(othercontract1.address, {from:accounts[0]})).toNumber(), 2);
  });
});

  /*
    signal()
  */

  it("should have a balance greater than 0 to signal", function(){
    return DCT.new().then(async function(contract){
      await contract.unpause({from:accounts[0]});
      await contract.signal(contract.address, {from:accounts[1]}).catch(()=>{});
      assert.equal((await contract.owners.call(contract.address, {from:accounts[0]})).toNumber(), 0);
    })
  })

  it("should elect a new owner once he has majority of totalSupply", function(){
    return DCT.new().then(async function(contract){
      var othercontract1 = await DCT.new();
      var othercontract2 = await DCT.new();
      await contract.mint(accounts[1], 1,{from:accounts[0]});
      await contract.mint(accounts[2], 2, {from:accounts[0]});
      await contract.unpause({from:accounts[0]});
      await contract.signal(othercontract1.address, {from:accounts[1]});
      await contract.signal(othercontract2.address, {from:accounts[2]});
      assert.equal((await contract.getOwner({from:accounts[0]})), othercontract2.address);
    })
  });

/*
  bounty()
*/

  it("should only allow users with valid signature from owner to mint", function(){
    return DCT.new().then(async function(contract){
      var newOwner = {}
      newOwner.key = eth.ripemd160("1", true); // "1" = nonce
      newOwner.pub = eth.privateToAddress(newOwner.key);
      await contract.transferOwnership(eth.bufferToHex(newOwner.pub), {from:accounts[0]});
      var hash = await eth.toBuffer(await contract.generateBountyHash.call(accounts[1], 1, 1));
      var sig = eth.ecsign(hash, newOwner.key);
      var rpcsig = eth.toRpcSig(sig.v, sig.r, sig.s);
      await contract.bounty(accounts[1], 1, 1, rpcsig, {from:accounts[1]});
      assert.equal((await contract.balanceOf.call(accounts[1])).toNumber(), 1);
      var hash = await eth.toBuffer(await contract.generateBountyHash.call(accounts[1], 1, 1));
      var fakesig = eth.ecsign(hash, eth.ripemd160("2", true));
      var fakerpcsig = eth.toRpcSig(fakesig.v, fakesig.r, fakesig.s);
      await contract.bounty(accounts[1], 1, 1, fakerpcsig, {from:accounts[1]}).catch(()=>{});
      assert.equal((await contract.balanceOf.call(accounts[1])).toNumber(), 1);
    })
  })
/*
  relayFee
*/

  // it("should not ...", function(){
  //   return DCT.new().then(async function(contract){
  //     var DCA = await DCArbitration.new(contract.address, 5,2,50,10,50);
  //     await contract.transferOwnership(DCA.address);
  //
  //   });
  // });
/*
  freeze
*/
it("should not transfer when frozen", function(){
  return DCT.new().then(async function(contract){
    var DCA = await DCArbitration.new(contract.address, 0,0,50,1,50);
    await contract.unpause({from: accounts[0]});
    await contract.mint(accounts[1],5, {from: accounts[0]});
    await contract.transferOwnership(DCA.address, {from: accounts[0]});
    await DCA.deposit({from: accounts[1]});
    await contract.transfer(accounts[0], 1, {from: accounts[1]}).catch(()=>{});
    assert.equal((await contract.balanceOf(accounts[1])).toNumber(), 5);
    // await DCA.withdraw({from: accounts[1]});
    // await contract.transfer(accounts[0], 1, {from: accounts[1]}).catch(()=>{});
    // assert.equal((await contract.balanceOf(accounts[1])).toNumber(), 4);
  })
})
/*
  burn
*/

it("should change balance after burn", function(){
  return DCT.new().then(async function(contract){
    var DCA = await DCArbitration.new(contract.address, 0,0,50,1,50);
    await contract.unpause({from: accounts[0]});
    await contract.mint(accounts[1],5, {from: accounts[0]});
    await contract.transferOwnership(DCA.address, {from: accounts[0]});
    await DCA.burn(accounts[1], 4, {from: accounts[0]});
    assert.equal((await contract.balanceOf(accounts[1])).toNumber(), 1);
  })
})
it("should change total supply after burnAll", function(){
  return DCT.new().then(async function(contract){
    var DCA = await DCArbitration.new(contract.address, 0,0,50,1,50);
    await contract.unpause({from: accounts[0]});
    await contract.mint(accounts[1],5, {from: accounts[0]});
    await contract.mint(accounts[2], 5, {from: accounts[0]});
    await contract.transferOwnership(DCA.address, {from: accounts[0]});
    await DCA.burn(accounts[1], 4, {from: accounts[0]});
    assert.equal((await contract.totalSupply()).toNumber(), 6);
  })
})

/*
  burnAll
*/
it("should have zero balance after burnAll", function(){
  return DCT.new().then(async function(contract){
    var DCA = await DCArbitration.new(contract.address, 0,0,50,1,50);
    await contract.unpause({from: accounts[0]});
    await contract.mint(accounts[1],5, {from: accounts[0]});
    await contract.transferOwnership(DCA.address, {from: accounts[0]});
    await DCA.burnAll(accounts[1], {from: accounts[0]});
    assert.equal((await contract.balanceOf(accounts[1])).toNumber(), 0);
  })
})
it("should change total supply after burnAll", function(){
  return DCT.new().then(async function(contract){
    var DCA = await DCArbitration.new(contract.address, 0,0,50,1,50);
    await contract.unpause({from: accounts[0]});
    await contract.mint(accounts[1],5, {from: accounts[0]});
    await contract.mint(accounts[2], 5, {from: accounts[0]});
    await contract.transferOwnership(DCA.address, {from: accounts[0]});
    await DCA.burnAll(accounts[1], {from: accounts[0]});
    assert.equal((await contract.totalSupply()).toNumber(), 5);
  })
})
/*
  relayTransfer
*/
// it("should --", function(){
// return DCT.new().then(async function(contract){
//   await contract.mint(accounts[1], 5, {from: accounts[0]});
//   await contract.unpause();
//
//   // await contract.transferOwnership(eth.bufferToHex(newOwner.pub), {from:accounts[0]});
//
//
//   var hash = await contract.generateRelayedTransferHash.call(accounts[1], accounts[2], 2, 1, 5, {from: accounts[1]});
//   // var hash = await eth.toBuffer();
//
//
//   var account_one = accounts[1];
//   // var sig = web4.eth.sign(account_one, hash);
//
//   // var sig = web3.eth.sign(account_one, hash, function (err, result) { console.log(err, result); });
//   console.log(sig);
//   var rpcsig = await eth.toRpcSig(sig.v, sig.r, sig.s);
//   await contract.relayTransfer(accounts[1], accounts[2], 2, 1, 5, rpcsig, {from: accounts[0]});
//   // await contract.bounty(accounts[1], 1, 1, rpcsig, {from:accounts[1]});
//   // assert.equal((await contract.balanceOf.call(accounts[1])).toNumber(), 1);
//   assert.equal((await contract.balanceOf.call(accounts[1])).toNumber(), 2);
// })
// })
})
