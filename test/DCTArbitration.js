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
contract('DCArbitration', function(accounts){

it("can not register with duration less than minimum global trial period", function(){
  return DCT.new().then(async function(contract){
    var DCA = await DCArbitration.new(contract.address, 0,5,50,1,50);
    await contract.unpause({from: accounts[0]});
    await contract.transferOwnership(DCA.address, {from: accounts[0]});
    await DCA.register("e3b98a4da31a127d4bde6e43033f66ba274cab0eb7eb1c70ec41402bf6273dd8", 30, "http://twew.com". {from: accounts[1]}).catch(()=>{});
  })
})
it("can not transfer after deposit", function(){
    return DCT.new().then(async function(contract){
      var DCA = await DCArbitration.new(contract.address, 0,5,50,1,50);
      await contract.unpause({from: accounts[0]});
      await contract.mint(accounts[1], 1, {from: accounts[0]});
      await contract.transferOwnership(DCA.address, {from: accounts[0]});
      await DCA.deposit({from: accounts[1]});
      await contract.transfer(accounts[0], 1, {from: accounts[1]}).catch(()=>{});
      assert.equal((await contract.balanceOf(accounts[1])).toNumber(), 5);
    })
})

})
