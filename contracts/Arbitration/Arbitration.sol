pragma solidity ^0.4.18;

import "./TokenInterface.sol";
import "./ClientInterface.sol";
import "./SafeMath.sol";

/**
@title DCourt Arbitration contract
@author Ihab McShea Nour Haridy
*/
contract DCArbitration {
    using SafeMath for uint256;
    DCTInterface DCToken;

    /*
        Variables
    */

    uint256 round;
    uint256 caseCounter;
    uint256 RoundReward;
    uint256 collateral;
    uint256 roundsPerHalving;
    uint256 votingPeriod;
    uint256 unlockingPeriod;
    uint256 minTrialPeriod;
    uint256 challengingPeriod;
    uint256 roundWeight;
    uint256 blocksPerRound;
    uint256 genesisBlock;
    uint8 witnessCount;
    uint8 maxWitnesses;
    uint256 courtCouncilPool;
    /*
        structs
    */
    struct Client{
        bytes32 ToA;
        uint256 trialDuration;
        string URL;
    }
    struct Case{
        address accuser;
        address defendant;
        address client;
        uint256 block;
        phase _phase;
        string title;
        evidence[] _evidence;
        uint256 voteWeight;
        uint256 ayes;
        uint256 nayes;
        uint256 round;
        uint256 trialDuration;
        uint256 collateral;
        bool decided;
        bool spam;
        bool verdict;
    }
    struct evidence{
        string body;
        address author;
    }

    struct juror{
        uint256 deposit;
        uint256 round;
        uint256 remaining;
        uint256 activeCases;
        uint256 caseCount;
        uint256[] cases;
    }
    struct Vote{
        bytes32 _hash;
        uint256 amount;
        string nonce;
        bool decision;
        uint256 caseID;
        bool unlocked;
        bool claimed; //Rewarded or penalized.
    }

    struct Round{
        uint256 roundWeight;
        uint256 caseCount;
        uint256 reportCount;
    }
    struct Witness {
       address addr;
       string name;
       uint256 reportCount;
       uint256[] reports;
    }
    struct spamReport{
      address submitter;
      uint256 caseID;
      address accuser;
      bool verdict;
    }
    /*
        modifiers

    */

    modifier onlyWhenOwner(){
         require(DCToken.getOwner() == address(this));
        _;
    }

    modifier onlyContract(){
        require(isContract(msg.sender));
        _;
    }
    modifier onlyCaseParty(uint256 _caseID){
        require(cases[_caseID].defendant == msg.sender || cases[_caseID].accuser == msg.sender);
        _;
    }
    modifier onlyJuror(){
/* //           require(jurors[msg.sender].round.add(2) <= round); */
        _;
    }

    modifier onlyWitness {
      require(witnessRanks[msg.sender] > 0);
      _;
    }

    /*
        Enumerators
    */
    enum phase {
        TRIAL,
        VOTING,
        UNLOCKING,
        FINAL
    }


    /*
        mappings
    */
    mapping (address => Client) clients;
    mapping(uint256 => Case) cases;
    mapping (address => juror) jurors;
    mapping (uint256 => Round) rounds;
    mapping (address => mapping(uint256 => Vote)) votes;
    mapping (address => uint256) frozenBalance;
    mapping(address => uint256) public delegates;
    mapping(address => address) public voters;
    mapping (uint => Witness) public witnesses;
    mapping(uint2 56 => mapping(uint256 => bool)) witnessVote;
    mapping(uint256 => spamReport) reportedCases;
    mapping(uint => uint) reportVotes;
    mapping (address => uint) public witnessRanks;

    /*
        events
    */

    event Registration(address indexed addr, bytes32 ToA, string URL);
    event newCase(address accuser, address defendant, address client, uint256 block, string title, string statement);
    event newEvidence(string body, address author, uint256 caseID);
    event Stepdown(address indexed _witness, string _name, uint rank);
    event NewWitness(address indexed _witness, string _name, uint rank);
    event Filed(address indexed _accuser, address indexed _defendant, string _statement, string _title);
    event rewardClaimed(bool decided, uint256 round, uint256 currentRound, uint256 test);
    event loss(uint256 loss);
    event Delegation(address indexed voter, address indexed delegate, uint256 balance);
    event Reported(uint256 _caseID, address reporter);
    event Voted(address indexed voter, uint256 _caseID);
    function DCArbitration(address DCTAddress, uint256 _votingPeriod, uint256 _minTrialPeriod, uint256 _roundReward,  uint256 _blocksPerRound, uint256 _roundsPerHalving, uint256 _collateral, uint256 _challengingPeriod, uint8 _maxWitnesses, uint256 _unlockingPeriod) public{
        DCToken = DCTInterface(DCTAddress);
        votingPeriod = _votingPeriod;
        minTrialPeriod = _minTrialPeriod;
        RoundReward = _roundReward;
        blocksPerRound = _blocksPerRound;
        unlockingPeriod = _unlockingPeriod;
        roundsPerHalving = _roundsPerHalving;
        genesisBlock = block.number;
        collateral = _collateral;
        challengingPeriod = _challengingPeriod;
        maxWitnesses = _maxWitnesses;
    }
    /**
    @notice Register a decentralized application on the Dcourt system, called by the smart contract of the decentralized application.
    @dev You must call this function from your dApp smart contract in order to be able to build it on top of Dcourt.
    @param _ToA the hash of terms of agreement
    @param _URL the address of the dApp.
    @return {
      "registered": "if registered"
    }
    */
    function register(bytes32 _ToA, string _URL) public   onlyWhenOwner returns(bool registered){
        require(clients[msg.sender].trialDuration == 0);
        clients[msg.sender].ToA = _ToA;
        clients[msg.sender].URL = _URL;
        emit Registration(msg.sender, _ToA, _URL);
        return true;
    }
    function isContract(address addr) private view returns (bool) {
        uint size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }
    function getVoteWeight(uint256 _caseID) public view returns(uint256 vote){
      return cases[_caseID].voteWeight;
    }
    function generateHash(string nonce, bool decision) public pure returns(bytes32 _hash){
        uint8 dec;
        if(decision == true)
            dec = 1;
        else
            dec = 0;
        return keccak256(dec,nonce);
    }
    function getV(bool decision, uint256 _caseID) public view returns(uint256){
      if(decision){
        return cases[_caseID].ayes;
      }else{
        return cases[_caseID].nayes;
      }
      return cases[_caseID].nayes;
    }
    function burnAll(address _addr){
      DCToken.burnAll(_addr);
    }
    function burn(address _addr, uint256 qty){
      DCToken.burn(_addr, qty);
    }
}
