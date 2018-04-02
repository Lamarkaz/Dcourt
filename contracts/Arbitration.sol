
pragma solidity ^0.4.18;

contract DCT {
    function getOwner() public view returns(address);
    mapping (address => uint256) public balances;
    mapping (address => bool) public frozen;
    function balanceOf(address _owner) public view returns (uint256 balance);
    function mint(address _to, uint256 _amount) public returns (bool);
    function relayFee(address _from, address _relay, uint256 _fee) public returns(bool);
    function freeze(address _account, bool _value) public  returns (uint256);
    function burn(address _account, uint256 _amount) public returns (uint256);
    function burnAll(address _account) public returns(bool);
}

contract ClientContract{
    function onVerdict(uint256, bool) public returns(bool); //Case ID, Decision. 
}

library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}
contract DCArbitration {
    using SafeMath for uint256;
    DCT DCToken;
    
    /*
        Variables
    */
    
    uint256 round;
    uint256 caseCounter;
    uint256 RoundReward;
    uint256 roundsPerHalving;
    uint256 votingPeriod;
    uint256 unlockingPeriod;
    uint256 minTrialPeriod;
    uint256 roundWeight;
    uint256 blocksPerRound;
    uint256 genesisBlock;
    
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
        bool decided;
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
        bool unlocked;
        bool claimed; //Rewarded or penalized. 
    }
    
    struct Round{
        uint256 roundWeight;
        uint256 caseCount;
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
        require(jurors[msg.sender].round.add(2) <= round);
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
    /*
        events
    */
    event Registration(address indexed addr, bytes32 ToA, uint256 trialDuration, string URL);
    event newCase(address accuser,
        address defendant,
        address client,
        uint256 block,
        string title,
        string statement
        );
    event newEvidence(string body, address author, uint256 caseID);
    
    /*
        Functions
    */
    
    function DCArbitration(address DCTAddress, uint256 _votingPeriod, uint256 _minTrialPeriod, uint256 _roundReward,  uint256 _blocksPerRound, uint256 _roundsPerHalving) public{
        DCToken = DCT(DCTAddress);
        votingPeriod = _votingPeriod;
        minTrialPeriod = _minTrialPeriod;
        RoundReward = _roundReward;
        blocksPerRound = _blocksPerRound;
        roundsPerHalving = _roundsPerHalving;
        genesisBlock = block.number;
    }
    function register(bytes32 _ToA, uint256 _trialDuration, string _URL) onlyContract onlyWhenOwner public returns(bool){
        require(_trialDuration >= minTrialPeriod);
        require(clients[msg.sender].trialDuration == 0);
        clients[msg.sender].ToA = _ToA;
        clients[msg.sender].trialDuration = _trialDuration;
        clients[msg.sender].URL = _URL;
        emit Registration(msg.sender, _ToA, _trialDuration, _URL);
        return true;
    }
    
    function fileCase(address _defendant, string _statement, string _title) public onlyContract onlyWhenOwner returns(uint256){
        require(clients[msg.sender].trialDuration != 0);
        caseCounter++;
        Case storage filedCase = cases[caseCounter];
        filedCase.client = msg.sender;
        filedCase.accuser = tx.origin;
        filedCase.defendant = _defendant;
        filedCase.block = block.number;
        evidence storage _evidence = filedCase._evidence[0];
        _evidence.body = _statement;
        _evidence.author = tx.origin;
        filedCase.title = _title;
        filedCase._phase = phase.TRIAL;
        emit newCase(tx.origin,
        _defendant,
        msg.sender,
        block.number,
        _title,
        _statement
        );
        return caseCounter;
    }
    
    function deposit() onlyWhenOwner public{
        uint256 balance = DCToken.balanceOf(msg.sender);
        require(balance > 0);
        require(jurors[msg.sender].deposit == 0);
        jurors[msg.sender].deposit = balance;
        jurors[msg.sender].remaining = balance;
        DCToken.freeze(msg.sender, true);
    }
    
    function withdraw() onlyJuror onlyWhenOwner public{
        require(jurors[msg.sender].activeCases == 0);
        DCToken.freeze(msg.sender, false);
    }
    
    function generateHash(string nonce, bool decision) public pure returns(bytes32){
        uint8 dec;
        if(decision == true)
            dec = 1;
        else
            dec = 0;
        return keccak256(dec,nonce);
    }
    
    function vote(uint256 _caseID, bytes32 hash, uint256 _amount) onlyJuror onlyWhenOwner public returns(uint256){
        require((block.number >= cases[_caseID].block + clients[cases[_caseID].client].trialDuration) && block.number < cases[_caseID].block + clients[cases[_caseID].client].trialDuration + votingPeriod); 
        
        require(votes[msg.sender][_caseID].amount == 0);
        require(jurors[msg.sender].remaining.sub(_amount) >= 0 );
        jurors[msg.sender].remaining = jurors[msg.sender].remaining.sub(_amount);

        votes[msg.sender][_caseID].amount = _amount;
        votes[msg.sender][_caseID]._hash = hash;
        cases[_caseID].voteWeight = cases[_caseID].voteWeight.add(_amount);
        if(cases[_caseID]._phase != phase.VOTING){
           cases[_caseID]._phase = phase.VOTING; 
        }
        jurors[msg.sender].activeCases = jurors[msg.sender].activeCases.add(1);
        return _caseID; //?
    }
    function unlock(bool decision, string nonce, uint256 _caseID) onlyJuror public returns(bool){
        require(votes[msg.sender][_caseID].amount > 0);
        require((block.number >= cases[_caseID].block + clients[cases[_caseID].client].trialDuration + votingPeriod) && (block.number < cases[_caseID].block + clients[cases[_caseID].client].trialDuration + votingPeriod + unlockingPeriod));
        require(votes[msg.sender][_caseID].unlocked == false);
        uint8 dec;
        if(decision == true){
            dec = 1;
        }else{
            dec = 0;
        }
        bytes32 _hash = keccak256(dec,nonce);
        require(_hash == votes[msg.sender][_caseID]._hash);
        jurors[msg.sender].caseCount = jurors[msg.sender].caseCount.add(1);
        jurors[msg.sender].cases[jurors[msg.sender].caseCount] = _caseID;
        if(decision == true){
            cases[_caseID].ayes = cases[_caseID].ayes.add(votes[msg.sender][_caseID].amount);
        }else{
            cases[_caseID].nayes = cases[_caseID].nayes.add(votes[msg.sender][_caseID].amount);
        }
        votes[msg.sender][_caseID].unlocked = true;
        votes[msg.sender][_caseID].nonce = nonce;
        votes[msg.sender][_caseID].decision = decision;
        jurors[msg.sender].activeCases = jurors[msg.sender].activeCases.sub(1);
        return true;
    }
    function finalize(uint256 _caseID) public onlyWhenOwner returns(bool){
         require(block.number > cases[_caseID].block + clients[cases[_caseID].client].trialDuration + votingPeriod + unlockingPeriod);
         require(cases[_caseID].decided == false);
         bool verdict = cases[_caseID].ayes > cases[_caseID].nayes;
         ClientContract cc = ClientContract(cases[_caseID].client);
         cc.onVerdict(_caseID, verdict);
         cases[_caseID].decided = true;
         cases[_caseID].verdict = verdict;
         rounds[(block.number.sub(genesisBlock)).div(blocksPerRound)].roundWeight = rounds[(block.number.sub(genesisBlock)).div(blocksPerRound)].roundWeight.add(cases[_caseID].voteWeight);
         rounds[(block.number.sub(genesisBlock)).div(blocksPerRound)].caseCount = rounds[(block.number.sub(genesisBlock)).div(blocksPerRound)].caseCount.add(1);
        //  rounds[(block.number.sub(genesisBlock)).div(blocksPerRound)].roundWeight = roundWeights[(block.number.sub(genesisBlock)).roundWeight.div(blocksPerRound)].add(cases[_caseID].voteWeight);
         cases[_caseID].round = (block.number.sub(genesisBlock)).div(blocksPerRound);
         return verdict;
    }
    function claimReward() public onlyJuror onlyWhenOwner returns(bool){ // optional iterations argument
        require(jurors[msg.sender].caseCount > 0); // activeCases >> caseCount 
        uint256 NCases = jurors[msg.sender].caseCount;
        uint256 currentRound = uint((block.number.sub(genesisBlock)).div(blocksPerRound)); 
        int256 Claimed;
        uint256 one = 1;
        for(uint256 i=1; i <= NCases; i++){
            uint256 individualRR;
            if(/* cases[jurors[msg.sender].cases[i]].decided == false || */ cases[jurors[msg.sender].cases[i]].round == currentRound) continue;
            // uint256 tokenShare = ;
            uint256 halvings = (cases[jurors[msg.sender].cases[i]].round / roundsPerHalving);
            individualRR = (one.div(2**halvings)).mul(RoundReward);
            if(cases[jurors[msg.sender].cases[i]].verdict == votes[msg.sender][jurors[msg.sender].cases[i]].decision){
                Claimed += int(votes[msg.sender][jurors[msg.sender].cases[i]].amount * (1/rounds[currentRound].caseCount) * individualRR);
                // DCToken.mint(msg.sender, Claimed);
            }else{ //75% threshold?
                Claimed -= int(votes[msg.sender][jurors[msg.sender].cases[i]].amount * (1/rounds[currentRound].caseCount) * individualRR);
            }
        }
        if(Claimed > 0 ){
            DCToken.mint(msg.sender, uint256(Claimed));
        }else if(Claimed < 0){
            DCToken.burn(msg.sender, uint256(Claimed));
        }
        //Remove cases from array
    }
    
    function addEvidence(uint256 _caseID, string _body) public onlyWhenOwner onlyCaseParty(_caseID) returns (uint256){
        require(cases[_caseID].client != address(0));
        require(block.number < cases[_caseID].block + clients[cases[_caseID].client].trialDuration); 
        uint256 evidenceLength = cases[_caseID]._evidence.length;
        evidenceLength++;
        evidence storage _evidence = cases[_caseID]._evidence[evidenceLength];
        _evidence.body = _body;
        _evidence.author = msg.sender;
        emit newEvidence(_body, msg.sender, _caseID);
        return evidenceLength;
    }
    
    /*
    utils
    */
    function isContract(address addr) private view returns (bool) {
        uint size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

}
