
# Smart Contract Documentation


## [core/Dcourt.sol:Dcourt](../contracts/core/Dcourt.sol)
`Solidity version 0.4.24+commit.e67f0147`


 ##### function finalize `0x05261aea` 
  nonpayable 


 Type | Name |
--- | --- |
| uint256 | id |
___
 ##### function dividend `0x0ff8cf9b` 
 constant view 


___
 ##### function minCaseDuration `0x17490969` 
 constant view 


___
 ##### function numCases `0x1fa0a99f` 
 constant view 


___
 ##### function minFee `0x24ec7590` 
 constant view 


___
 ##### function caseEvidence `0x3a92f489` 
 constant view 
Returns the evidence body, the address of the submitter and the evidence submission timestamp in seconds. Throws if evidence does not exist.

 Type | Name |
--- | --- |
| uint256 | caseId |
| uint256 | evidenceId |
___
 ##### function commitDuration `0x6f833811` 
 constant view 


___
 ##### function juryJoinDuration `0x72485200` 
 constant view 


___
 ##### function revealDuration `0x886a6de1` 
 constant view 


___
 ##### function jurorShare `0x8c14e919` 
 constant view 


 Type | Name |
--- | --- |
| uint256 | caseId |
| address | account |
___
 ##### function reveal `0xa2357231` 
  nonpayable 


 Type | Name |
--- | --- |
| uint256 | id |
| string | salt |
| bool | vote |
___
 ##### function submitEvidence `0xa6a7f0eb` 
  payable payable


 Type | Name |
--- | --- |
| uint256 | id |
| string | body |
___
 ##### function motion `0xad0873e6` 
  payable payable
Called by client smart contract to file a new case. Must include a payment bigger or equal to minFee Throws if sender is not a contract, fee is smaller than minFee or duration is smaller than minCaseDuration.

 Type | Name |
--- | --- |
| string | allegation |
| string | firstEvidence |
| string | agreement |
| address | defendant |
| uint256 | duration |
| uint256 | appeal |
___
 ##### function joinJury `0xbd18f44c` 
  payable payable


___
 ##### function generateCommit `0xc2ba39a0` 
 constant pure 


 Type | Name |
--- | --- |
| string | salt |
| bool | vote |
___
 ##### function bumpFee `0xc8b72b7b` 
  payable payable


 Type | Name |
--- | --- |
| uint256 | id |
___
 ##### function commit `0xe2543d7c` 
  nonpayable 


 Type | Name |
--- | --- |
| uint256 | id |
| uint256 | weight |
| bytes32 | h |
___
 ##### function leaveJury `0xf640c0e9` 
  nonpayable 


___
 ##### function caseStatus `0xffaad7f2` 
 constant view 
Returns a string indicating the current status of a case. Possible return values are: trial, commit, reveal, unfinalized, yes, no and undecided. Throws if case does not exist.

 Type | Name |
--- | --- |
| uint256 | id |
___
 ##### constructor  `` 
  nonpayable 


 Type | Name |
--- | --- |
| address | tokenContract |
| uint256 | _minFee |
| uint256 | _minCaseDuration |
| uint256 | _commitDuration |
| uint256 | _revealDuration |
| uint256 | _juryJoinDuration |
___
 ##### event Motion `0x455a328685d04445ea4e3ea7d8e40f596f8716df8128b0255d84daa2eb69cc7d` 
   


 Type | Name |
--- | --- |
| address | clientContract |
| uint256 | caseId |
| uint256 | fee |
| string | allegation |
| string | agreement |
| address | requester |
| address | defendant |
| uint256 | duration |
| uint256 | timestamp |
| uint256 | appeal |
___
 ##### event BumpFee `0xbf4854da0de05f03c61bb1ea31a97ed9d950e82187b5d2c0253fb4197a6734e5` 
   


 Type | Name |
--- | --- |
| address | account |
| uint256 | caseId |
| uint256 | fee |
| uint256 | timestamp |
___
 ##### event EvidenceSubmission `0xea1671f964b228b1e0b155d82a2adc5cf90ca8b9398e84fb89b3782acd1d94bd` 
   


 Type | Name |
--- | --- |
| address | submitter |
| uint256 | caseId |
| uint256 | evidenceId |
| string | body |
| uint256 | timestamp |
___
 ##### event JuryJoin `0x19aa9f700b980be183cfb3a68de51ae3967c420544dcd1ed4ee88814663d7368` 
   


 Type | Name |
--- | --- |
| address | account |
| uint256 | weight |
| uint256 | timestamp |
___
 ##### event JuryLeave `0x4a83cd0f8108e960927b13a52bb0ccad92bcdb792c38a0fb1e41032cbbbf9381` 
   


 Type | Name |
--- | --- |
| address | account |
| uint256 | timestamp |
___
 ##### event Commit `0x767a3c1f6dc2dc27dc5848b692c3cfc0643a9a64444f9f4c470bd0e9a60398fc` 
   


 Type | Name |
--- | --- |
| address | account |
| uint256 | caseId |
| uint256 | weight |
| uint256 | timestamp |
___
 ##### event Reveal `0x0759ed7449443e6512ffcc3ec61018f5e2b416c470f1631b9eaf314833f59f6e` 
   


 Type | Name |
--- | --- |
| address | account |
| uint256 | caseId |
| bool | vote |
___
 ##### event Verdict `0xdf8cb1f75a1ef33922fde1b5ff0b7323f00900502deffd7a420fb57136b6e329` 
   


 Type | Name |
--- | --- |
| uint256 | caseId |
| uint8 | verdict |
| uint8 | percentage |
___


## [token/DCT.sol:DCT](../contracts/token/DCT.sol)
`Solidity version 0.4.24+commit.e67f0147`


 ##### function name `0x06fdde03` 
 constant view 


___
 ##### function approve `0x095ea7b3` 
  nonpayable 
Approve the passed address to spend the specified amount of tokens on behalf of msg.sender. Beware that changing an allowance with this method brings the risk that someone may use both the old and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this race condition is to first reduce the spender&#x27;s allowance to 0 and set the desired value afterwards: https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

 Type | Name |
--- | --- |
| address | spender |
| uint256 | value |
___
 ##### function totalSupply `0x18160ddd` 
 constant view 
Total number of tokens in existence

___
 ##### function transferFrom `0x23b872dd` 
  nonpayable 
Transfer tokens from one address to another

 Type | Name |
--- | --- |
| address | from |
| address | to |
| uint256 | value |
___
 ##### function decimals `0x313ce567` 
 constant view 


___
 ##### function increaseAllowance `0x39509351` 
  nonpayable 
Increase the amount of tokens that an owner allowed to a spender. approve should be called when allowed_[_spender] &#x3D;&#x3D; 0. To increment allowed value is better to use this function to avoid 2 calls (and wait until the first transaction is mined) From MonolithDAO Token.sol

 Type | Name |
--- | --- |
| address | spender |
| uint256 | addedValue |
___
 ##### function mint `0x40c10f19` 
  nonpayable 
Allows only the owner to mint an amount of tokens and assign it to an account. This encapsulates the modification of balances such that the proper events are emitted.

 Type | Name |
--- | --- |
| address | account |
| uint256 | amount |
___
 ##### function balanceOf `0x70a08231` 
 constant view 
Gets the balance of the specified address.

 Type | Name |
--- | --- |
| address | owner |
___
 ##### function renounceOwnership `0x715018a6` 
  nonpayable 
Allows the current owner to relinquish control of the contract.

___
 ##### function owner `0x8da5cb5b` 
 constant view 


___
 ##### function isOwner `0x8f32d59b` 
 constant view 


___
 ##### function symbol `0x95d89b41` 
 constant view 


___
 ##### function decreaseAllowance `0xa457c2d7` 
  nonpayable 
Decrease the amount of tokens that an owner allowed to a spender. approve should be called when allowed_[_spender] &#x3D;&#x3D; 0. To decrement allowed value is better to use this function to avoid 2 calls (and wait until the first transaction is mined) From MonolithDAO Token.sol

 Type | Name |
--- | --- |
| address | spender |
| uint256 | subtractedValue |
___
 ##### function transfer `0xa9059cbb` 
  nonpayable 
Allows the current owner to transfer control of the contract to a newOwner.

 Type | Name |
--- | --- |
| address | to |
| uint256 | value |
___
 ##### function freeze `0xbf120ae5` 
  nonpayable 
Allows only the owner to (un)freeze an account. Used by the Dcourt core to freeze accounts in order to make them eligible for dividends and unfreeze them after they opt out.

 Type | Name |
--- | --- |
| address | account |
| bool | value |
___
 ##### function allowance `0xdd62ed3e` 
 constant view 
Function to check the amount of tokens that an owner allowed to a spender.

 Type | Name |
--- | --- |
| address | owner |
| address | spender |
___
 ##### function isFrozen `0xe5839836` 
 constant view 
Checks whether or not an account is frozen by owner Used by the Dcourt core to check whether or not this address is eligible for dividends.

 Type | Name |
--- | --- |
| address | account |
___
 ##### function transferOwnership `0xf2fde38b` 
  nonpayable 
Allows the current owner to transfer control of the contract to a newOwner.

 Type | Name |
--- | --- |
| address | newOwner |
___
 ##### event OwnershipRenounced `0xf8df31144d9c2f0f6b59d69b8b98abd5459d07f2742c4df920b25aae33c64820` 
   


 Type | Name |
--- | --- |
| address | previousOwner |
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


## [token/ERC20.sol:ERC20](../contracts/token/ERC20.sol)
`Solidity version 0.4.24+commit.e67f0147`
Standard ERC20 token

 ##### function approve `0x095ea7b3` 
  nonpayable 
Approve the passed address to spend the specified amount of tokens on behalf of msg.sender. Beware that changing an allowance with this method brings the risk that someone may use both the old and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this race condition is to first reduce the spender&#x27;s allowance to 0 and set the desired value afterwards: https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

 Type | Name |
--- | --- |
| address | spender |
| uint256 | value |
___
 ##### function totalSupply `0x18160ddd` 
 constant view 
Total number of tokens in existence

___
 ##### function transferFrom `0x23b872dd` 
  nonpayable 
Transfer tokens from one address to another

 Type | Name |
--- | --- |
| address | from |
| address | to |
| uint256 | value |
___
 ##### function increaseAllowance `0x39509351` 
  nonpayable 
Increase the amount of tokens that an owner allowed to a spender. approve should be called when allowed_[_spender] &#x3D;&#x3D; 0. To increment allowed value is better to use this function to avoid 2 calls (and wait until the first transaction is mined) From MonolithDAO Token.sol

 Type | Name |
--- | --- |
| address | spender |
| uint256 | addedValue |
___
 ##### function balanceOf `0x70a08231` 
 constant view 
Gets the balance of the specified address.

 Type | Name |
--- | --- |
| address | owner |
___
 ##### function decreaseAllowance `0xa457c2d7` 
  nonpayable 
Decrease the amount of tokens that an owner allowed to a spender. approve should be called when allowed_[_spender] &#x3D;&#x3D; 0. To decrement allowed value is better to use this function to avoid 2 calls (and wait until the first transaction is mined) From MonolithDAO Token.sol

 Type | Name |
--- | --- |
| address | spender |
| uint256 | subtractedValue |
___
 ##### function transfer `0xa9059cbb` 
  nonpayable 
Transfer tokens from one address to another

 Type | Name |
--- | --- |
| address | to |
| uint256 | value |
___
 ##### function allowance `0xdd62ed3e` 
 constant view 
Function to check the amount of tokens that an owner allowed to a spender.

 Type | Name |
--- | --- |
| address | owner |
| address | spender |
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


## [utils/Address.sol:Address](../contracts/utils/Address.sol)
`Solidity version 0.4.24+commit.e67f0147`




## [utils/ECDSA.sol:ECDSA](../contracts/utils/ECDSA.sol)
`Solidity version 0.4.24+commit.e67f0147`
Elliptic curve signature operations



## [utils/Ownable.sol:Ownable](../contracts/utils/Ownable.sol)
`Solidity version 0.4.24+commit.e67f0147`
Ownable

 ##### function renounceOwnership `0x715018a6` 
  nonpayable 
Allows the current owner to relinquish control of the contract.

___
 ##### function owner `0x8da5cb5b` 
 constant view 


___
 ##### function isOwner `0x8f32d59b` 
 constant view 


___
 ##### function transferOwnership `0xf2fde38b` 
  nonpayable 
Allows the current owner to transfer control of the contract to a newOwner.

 Type | Name |
--- | --- |
| address | newOwner |
___
 ##### constructor  `` 
  nonpayable 


___
 ##### event OwnershipRenounced `0xf8df31144d9c2f0f6b59d69b8b98abd5459d07f2742c4df920b25aae33c64820` 
   


 Type | Name |
--- | --- |
| address | previousOwner |
___
 ##### event OwnershipTransferred `0x8be0079c531659141344cd1fd0a4f28419497f9722a3daafe3b4186f6b6457e0` 
   


 Type | Name |
--- | --- |
| address | previousOwner |
| address | newOwner |
___


## [utils/SafeMath.sol:SafeMath](../contracts/utils/SafeMath.sol)
`Solidity version 0.4.24+commit.e67f0147`
SafeMath


---