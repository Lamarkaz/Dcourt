pragma solidity ^0.4.18;

import "./TokenInterface.sol";
import "./ClientInterface.sol";
import "./SafeMath.sol";

contract ClientContract{
    function register(bytes32 _ToA, uint256 _trialDuration, string _URL) public   returns(bool);

    function fileCase(address _defendant, string _statement, string _title) public  returns(uint256);

    function deposit()  public;

    function withdraw()   public;
    function getVoteWeight(uint256 _caseID) public view returns(uint256);
    function generateHash(string nonce, bool decision) public pure returns(bytes32);
    function what() public returns(uint256);
    function vote(uint256 _caseID, bytes32 hash, uint256 _amount)   public returns(uint256);
    /*
    utils
    */
    function isContract(address addr) private view returns (bool);
    function onVerdict(uint256 caseID, bool verdict) public;

}
