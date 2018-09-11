
# Smart Contract Documentation


## [Token/DCT.sol:DCT](../contracts/Token/DCT.sol)
`Solidity version 0.4.24+commit.e67f0147`
DCourt Arbitration contract

 ##### function owners `0x022914a7` 
 constant view 


 Type | Name |
--- | --- |
| address |  |
___
 ##### function generateBountyHash `0x03cbc098` 
 constant pure 


 Type | Name |
--- | --- |
| address | _recipient |
| uint256 | _amount |
| uint256 | _nonce |
___
 ##### function setSaleContract `0x0593d244` 
  nonpayable 


 Type | Name |
--- | --- |
| address | _contract |
___
 ##### function name `0x06fdde03` 
 constant view 


___
 ##### function approve `0x095ea7b3` 
  nonpayable 


 Type | Name |
--- | --- |
| address | _spender |
| uint256 | _value |
___
 ##### function bounty `0x1807ba7f` 
  nonpayable 


 Type | Name |
--- | --- |
| address | _recipient |
| uint256 | _amount |
| uint256 | _nonce |
| bytes | sig |
___
 ##### function totalSupply `0x18160ddd` 
 constant view 


___
 ##### function generateRelayedTransferHash `0x1e83eca0` 
 constant view 


 Type | Name |
--- | --- |
| address | _from |
| address | _to |
| uint256 | qty |
| uint256 | _fee |
| uint256 | timeout |
___
 ##### function transferFrom `0x23b872dd` 
  nonpayable 


 Type | Name |
--- | --- |
| address | _from |
| address | _to |
| uint256 | _value |
___
 ##### function balances `0x27e235e3` 
 constant view 


 Type | Name |
--- | --- |
| address |  |
___
 ##### function decimals `0x313ce567` 
 constant view 


___
 ##### function unpause `0x3f4ba83a` 
  nonpayable 


___
 ##### function relayed `0x3f82495d` 
 constant view 


 Type | Name |
--- | --- |
| bytes32 |  |
___
 ##### function mint `0x40c10f19` 
  nonpayable 


 Type | Name |
--- | --- |
| address | _to |
| uint256 | _amount |
___
 ##### function ownerPercentage `0x4cd0c96f` 
 constant view 


 Type | Name |
--- | --- |
| address | _owner |
___
 ##### function signal `0x552b836f` 
  nonpayable 


 Type | Name |
--- | --- |
| address | _owner |
___
 ##### function removeSaleContract `0x55ebe9e5` 
  nonpayable 


___
 ##### function allowed `0x5c658165` 
 constant view 


 Type | Name |
--- | --- |
| address |  |
| address |  |
___
 ##### function paused `0x5c975abb` 
 constant view 


___
 ##### function relayTransfer `0x67954a92` 
  nonpayable 


 Type | Name |
--- | --- |
| address | _from |
| address | _to |
| uint256 | _value |
| uint256 | _fee |
| uint256 | _timeout |
| bytes | sig |
___
 ##### function balanceOf `0x70a08231` 
 constant view 


 Type | Name |
--- | --- |
| address | _owner |
___
 ##### function burnAll `0x7e9d2ac1` 
  nonpayable 


 Type | Name |
--- | --- |
| address | _account |
___
 ##### function pause `0x8456cb59` 
  nonpayable 


___
 ##### function relayFee `0x86409381` 
  nonpayable 


 Type | Name |
--- | --- |
| address | _from |
| address | _relay |
| uint256 | _fee |
___
 ##### function getOwner `0x893d20e8` 
 constant view 


___
 ##### function owner `0x8da5cb5b` 
 constant view 


___
 ##### function symbol `0x95d89b41` 
 constant view 


___
 ##### function burn `0x9dc29fac` 
  nonpayable 


 Type | Name |
--- | --- |
| address | _account |
| uint256 | _amount |
___
 ##### function voters `0xa3ec138d` 
 constant view 


 Type | Name |
--- | --- |
| address |  |
___
 ##### function transfer `0xa9059cbb` 
  nonpayable 


 Type | Name |
--- | --- |
| address | _to |
| uint256 | _value |
___
 ##### function freeze `0xbf120ae5` 
  nonpayable 


 Type | Name |
--- | --- |
| address | _account |
| bool | _value |
___
 ##### function frozen `0xd0516650` 
 constant view 


 Type | Name |
--- | --- |
| address |  |
___
 ##### function saleContract `0xdaf6ca30` 
 constant view 


___
 ##### function allowance `0xdd62ed3e` 
 constant view 


 Type | Name |
--- | --- |
| address | _owner |
| address | _spender |
___
 ##### function transferOwnership `0xf2fde38b` 
  nonpayable 


 Type | Name |
--- | --- |
| address | newOwner |
___
 ##### event Mint `0x0f6798a560793a54c3bcfe86a93cde1e73087d944c0ea20544137d4121396885` 
   


 Type | Name |
--- | --- |
| address | to |
| uint256 | amount |
___
 ##### event Signal `0xebda6743c83f8926f57f32774da6ded1c80294405dc3e35b95d6064db1d2c8cd` 
   


 Type | Name |
--- | --- |
| address | _voter |
| address | _owner |
| uint256 | _amount |
___
 ##### event ElectedOwner `0x9871b6549038b3b446497a85745320a13e6b5cea38d16fc0f4b5b4ff806f039c` 
   


 Type | Name |
--- | --- |
| address | _owner |
| uint256 | _votes |
___
 ##### event Frozen `0x713eb400302cebac61f82eb8de5051d38458517ffac43ae45f4a9fd5d09ee698` 
   


 Type | Name |
--- | --- |
| address | addr |
| bool | _status |
___
 ##### event Pause `0x6985a02210a168e66602d3235cb6db0e70f92b3ba4d376a33c0f3d9434bff625` 
   


___
 ##### event Unpause `0x7805862f689e2f13df9f062ff482ad3ad112aca9e0847911ed832e158c525b33` 
   


___
 ##### event OwnershipTransferred `0x8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e0` 
   


 Type | Name |
--- | --- |
| address | previousOwner |
| address | newOwner |
___
 ##### event Transfer `0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef` 
   


 Type | Name |
--- | --- |
| address | from |
| address | to |
| uint256 | value |
___
 ##### event Approval `0x8c5be1e5ebec7d5bd14f71427d1e84f3dd0314c0f7b2291e5b200ac8c7c3b925` 
   


 Type | Name |
--- | --- |
| address | owner |
| address | spender |
| uint256 | value |
___


## [Token/OwnablePausable.sol:Ownable](../contracts/Token/OwnablePausable.sol)
`Solidity version 0.4.24+commit.e67f0147`


 ##### function owner `0x8da5cb5b` 
 constant view 


___
 ##### function transferOwnership `0xf2fde38b` 
  nonpayable 


 Type | Name |
--- | --- |
| address | newOwner |
___
 ##### constructor  `` 
  nonpayable 


___
 ##### event OwnershipTransferred `0x8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e0` 
   


 Type | Name |
--- | --- |
| address | previousOwner |
| address | newOwner |
___


## [Token/OwnablePausable.sol:Pausable](../contracts/Token/OwnablePausable.sol)
`Solidity version 0.4.24+commit.e67f0147`


 ##### function unpause `0x3f4ba83a` 
  nonpayable 


___
 ##### function paused `0x5c975abb` 
 constant view 


___
 ##### function pause `0x8456cb59` 
  nonpayable 


___
 ##### function owner `0x8da5cb5b` 
 constant view 


___
 ##### function transferOwnership `0xf2fde38b` 
  nonpayable 


 Type | Name |
--- | --- |
| address | newOwner |
___
 ##### event Pause `0x6985a02210a168e66602d3235cb6db0e70f92b3ba4d376a33c0f3d9434bff625` 
   


___
 ##### event Unpause `0x7805862f689e2f13df9f062ff482ad3ad112aca9e0847911ed832e158c525b33` 
   


___
 ##### event OwnershipTransferred `0x8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e0` 
   


 Type | Name |
--- | --- |
| address | previousOwner |
| address | newOwner |
___


## [Token/SafeMath.sol:SafeMath](../contracts/Token/SafeMath.sol)
`Solidity version 0.4.24+commit.e67f0147`
SafeMath


---