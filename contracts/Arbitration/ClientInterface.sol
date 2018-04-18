pragma solidity ^0.4.18;

contract ClientContract{
    function register(bytes32 _ToA, uint256 _trialDuration, string _URL);
    function fileCase(address _defendant, string _statement, string _title) internal returns(uint256);
    function onVerdict(uint256, bool) public returns(bool); //Case ID, Decision.
}
