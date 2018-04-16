pragma solidity ^0.4.18;

contract ClientContract{
    function onVerdict(uint256, bool) public returns(bool); //Case ID, Decision.
}
