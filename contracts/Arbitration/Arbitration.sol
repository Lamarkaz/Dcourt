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
    mapping(address => uint256) public delegates;
    mapping(address => address) public voters;
    mapping (uint => Witness) public witnesses;
    mapping(uint256 => mapping(uint256 => bool)) witnessVote;
    mapping(uint256 => spamReport) reportedCases;
    mapping(uint => uint) reportVotes;
    mapping (address => uint) public witnessRanks;
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
//           require(jurors[msg.sender].round.add(2) <= round);
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
    /*
        events
    */

    event Registration(address indexed addr, bytes32 ToA, string URL);
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

    function DCArbitration(address DCTAddress, uint256 _votingPeriod, uint256 _minTrialPeriod, uint256 _roundReward,  uint256 _blocksPerRound, uint256 _roundsPerHalving, uint256 _collateral, uint256 _challengingPeriod, uint8 _maxWitnesses) public{
        DCToken = DCTInterface(DCTAddress);
        votingPeriod = _votingPeriod;
        minTrialPeriod = _minTrialPeriod;
        RoundReward = _roundReward;
        blocksPerRound = _blocksPerRound;
        unlockingPeriod = 5;
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
    event Filed(address indexed _accuser, address indexed _defendant, string _statement, string _title);
    /**
    @notice File a case from a dApp to the Dcourt system
    @dev You should implement a "fileCase" function in your smart contract which can be invoked by the accuser
    @param _defendant the address of the defendant
    @param _statement the opening statement of the case, also considered the first body of evidence
    @param _title the title of the case. should be hard-coded in your contract.
    @param trialDuration the duration in which case parties can submit evidence, should be at least as long as the global duration
    @return {
      "_caseID": "the ID of the filed case"
    }
    */
    function fileCase(address _defendant, uint256 trialDuration, string _statement, string _title) public  returns(uint256 _caseID){
        require(trialDuration >= minTrialPeriod);
        caseCounter++;
        Case storage filedCase = cases[caseCounter];
        filedCase.client = msg.sender;
        filedCase.accuser = tx.origin;
        filedCase.defendant = _defendant;
        filedCase.block = block.number;
        filedCase.trialDuration = trialDuration;
        //  evidence storage _evidence = filedCase._evidence[0];
        //  _evidence.body = _statement;
        //  _evidence.author = tx.origin;
        filedCase.title = _title;
        filedCase._phase = phase.TRIAL;
        filedCase.collateral = collateral;
        emit newCase(tx.origin,
        _defendant,
        msg.sender,
        block.number,
        _title,
        _statement
        );
        frozenBalance[tx.origin] = frozenBalance[tx.origin].add(collateral);
        DCToken.burn(tx.origin, collateral);
        return caseCounter;

    }
    function unfreezeCollateral(uint256 _caseID){
     require(block.number > cases[_caseID].block + clients[cases[_caseID].client].trialDuration + votingPeriod + unlockingPeriod + challengingPeriod && cases[_caseID].spam == false);
      DCToken.mint(cases[_caseID].accuser, (cases[_caseID].collateral/2));
    }
    event Delegation(address indexed voter, address indexed delegate, uint256 balance);
    function increaseVote(address _voter, uint256 _amount){
      delegates[voters[_voter]] = delegates[voters[_voter]].add(_amount);
      emit Delegation(_voter, voters[msg.sender], DCToken.balanceOf(msg.sender));
    }
    function decreaseVote(address _voter, uint256 _amount){
      delegates[voters[_voter]] = delegates[voters[_voter]].sub(_amount);
      emit Delegation(_voter, voters[_voter], DCToken.balanceOf(msg.sender));
    }
    function eligibleForWitness(address _delegate) public view returns (bool) {
       return delegates[_delegate] > delegates[witnesses[witnessCount].addr];
    }
    event Stepdown(address indexed _witness, string _name, uint rank);
    event NewWitness(address indexed _witness, string _name, uint rank);
    function witnessStepdown() public onlyWitness  returns (bool) {
     uint rank = witnessRanks[msg.sender];
     Witness memory thisWitness = witnesses[rank];
     delete witnesses[rank];
     witnessRanks[msg.sender] = 0;
     if(rank == witnessCount) return true; // If this the last rank, skipping the next loop
     for (uint i = rank+1; i < witnessCount+1; i++){ // Move up each witness of a lower rank
         witnessRanks[witnesses[i-1].addr] = witnessRanks[witnesses[i].addr];
         witnesses[i-1] = witnesses[i];
     }

     witnessRanks[witnesses[witnessCount].addr] = 0; // Last witness seat must become available after witness stepdown
     delete witnesses[witnessCount];
     emit Stepdown(msg.sender, thisWitness.name, rank);
     return true;
     }
     function becomeWitness(string _name) public returns (bool) {
      uint256 weight = delegates[msg.sender];
      require(weight > 0 && ( witnessRanks[msg.sender] > 21 || witnessRanks[msg.sender] ==0));
      uint rank;
      if(witnessCount == 0 ){
        rank = 1;
      }else{
        for (uint i = witnessCount; i > 0 ; i--){ // iterate on the witnesses from the lowest to highest rank to save as much gas as possible. Loop is bounded by witnessCount
            // if(witnesses[i].addr == msg.sender) break; // if message sender is already this witness, throw
            address witnessAddr = witnesses[i].addr;
           uint256 witnessWeight = delegates[witnessAddr];
            if(witnessWeight == 0 && i != 1) continue; //if there is no delegate at this rank and this is not the highest rank then skip this iteration
            if(witnessWeight > weight) break; // if this witness has a higher weight than message sender, break the loop
          if(i == maxWitnesses){  // if this is the lowest witness rank, remove this delegate from witnesses
               witnessRanks[witnessAddr] = 0;
               delete witnesses[i];
            }else{
                witnesses[i+1] = witnesses[i]; // Move this witness down 1 rank
                witnessRanks[witnesses[i+1].addr] = i;
            }
            rank = i;
        }
      }

      require(rank > 0); // Require that message sender has a rank after the loop
      if(rank > 0 && witnessCount < 21){
        witnessCount +=1;
      }
      witnessRanks[msg.sender] = rank;
      Witness storage newWitness = witnesses[rank];
      newWitness.name = _name;
      newWitness.addr = msg.sender;
      emit NewWitness(msg.sender, _name, rank);
      return true;
    }

    function signal(address _delegate) public {
        require(DCToken.balanceOf(msg.sender) > 0);
        require(_delegate != address(0));
        require(voters[msg.sender] != _delegate);
        if(voters[msg.sender] != address(0)){
            delegates[voters[msg.sender]] = delegates[voters[msg.sender]].sub(DCToken.balanceOf(msg.sender));
        }
        delegates[_delegate] = delegates[_delegate].add(DCToken.balanceOf(msg.sender));
        voters[msg.sender] = _delegate;
        emit Delegation(msg.sender, _delegate, DCToken.balanceOf(msg.sender));
    }
    function delegatePercentage(address _delegate) public view returns (uint256) {
       if(delegates[_delegate] == DCToken.totalSupply()) return 100;
       return (delegates[_delegate].div(DCToken.totalSupply())).mul(100);
    }
    function getRanking(address account) public view returns(uint){
        return witnessRanks[account];
    }
    function decideReport(uint256 _caseID){
      uint casePeriod = cases[_caseID].block + cases[_caseID].trialDuration + votingPeriod + unlockingPeriod;
      require(witnessRanks[msg.sender] > 0 && witnessRanks[msg.sender] < 22);
      require((block.number > casePeriod) && (block.number < casePeriod + challengingPeriod));
      witnessVote[witnessRanks[msg.sender]][witnesses[witnessRanks[msg.sender]].reportCount] = true;
      witnesses[witnessRanks[msg.sender]].reportCount = witnesses[witnessRanks[msg.sender]].reportCount.add(1);
      reportVotes[_caseID] = reportVotes[_caseID].add(1);
      witnesses[witnessRanks[msg.sender]].reports.push(_caseID);

      if(reportVotes[_caseID] > (witnessCount/2)){
        cases[_caseID].spam = true;
      }
    }
    function claimWitnessReward(){
      require(witnessRanks[msg.sender] > 0 && witnessRanks[msg.sender] < 22);
      uint256 NCases = witnesses[witnessRanks[msg.sender]].reportCount;
      uint256 currentRound;
      int256 Claimed;
      currentRound = uint((block.number.sub(genesisBlock)).div(blocksPerRound)) +1;

      for(uint256 i=0; i < NCases; i++){
          uint256 individualRR;
          uint256 ten = 10**4;
          uint256 halvings = (cases[witnesses[witnessRanks[msg.sender]].reports[i]].round / roundsPerHalving);
          individualRR = ((10**4)/2**halvings) * (RoundReward/5);
          individualRR /= 10**4;
          uint256 totalPay = individualRR + courtCouncilPool;
          uint256 voterWeight = (10**8) / reportVotes[witnesses[witnessRanks[msg.sender]].reports[i]];
          Claimed  += int(((voterWeight * (totalPay / rounds[currentRound-1].reportCount)))/10**8);
      }
      DCToken.mint(msg.sender, uint256(Claimed));
      delete witnesses[witnessRanks[msg.sender]].reports;
      witnesses[witnessRanks[msg.sender]].reportCount = 0;
    }

    event Reported(uint256 _caseID, address reporter);
    function reportCase(uint256 _caseID) public returns(bool reported){
      require(reportedCases[_caseID].accuser == address(0));
      spamReport storage reportedCase = reportedCases[_caseID];
      reportedCase.submitter = msg.sender;
      reportedCase.caseID = _caseID;
      reportedCase.accuser =  cases[_caseID].accuser;
      rounds[(block.number.sub(genesisBlock)).div(blocksPerRound)].reportCount = rounds[(block.number.sub(genesisBlock)).div(blocksPerRound)].caseCount.add(1);
      emit Reported(reportedCase.caseID, reportedCase.submitter);
        return true;
    }

    /**
    @notice Deposit the user's funds as collateral before voting
    @return {
      "done": "if done"
    }
    */
    function deposit() onlyWhenOwner public returns(bool done){
        uint256 balance = DCToken.balanceOf(msg.sender);
        require(balance > 0);
        require(jurors[msg.sender].deposit == 0);
        jurors[msg.sender].deposit = balance;
        jurors[msg.sender].remaining = balance;
        DCToken.freeze(msg.sender, true);
        return true;
    }
    /**
    @notice Register a decentralized application on the Dcourt system, called by the smart contract of the decentralized application.
    @return {
      "registered": "if registered"
    }
    */
    function withdraw() onlyJuror onlyWhenOwner public returns(bool done){
        require(jurors[msg.sender].activeCases == 0);
        DCToken.freeze(msg.sender, false);
        return true;
    }
    function getVoteWeight(uint256 _caseID) public view returns(uint256 vote){
      return cases[_caseID].voteWeight;
    }
    /**
    @notice Generate the vote hash
    @param nonce the nonce string used
    @param decision Guilty (true) / Not Guilty (false)
    @return {
      "_hash": "the resulting hash"
    }
    */
    function generateHash(string nonce, bool decision) public pure returns(bytes32 _hash){
        uint8 dec;
        if(decision == true)
            dec = 1;
        else
            dec = 0;
        return keccak256(dec,nonce);
    }

    event Voted(address indexed voter, uint256 _caseID);
    /**
    @notice Vote guilty/not guilty on a Dcourt case
    @param _caseID ID of the case on the Dcourt system
    @param hash the hash combining the nonce with the juror's decision
    @param _amount the amount bet to vote on the case
    @return {
      "voted": "if voted"
    }
    */
    function vote(uint256 _caseID, bytes32 hash, uint256 _amount) onlyJuror onlyWhenOwner public returns(bool voted){
        require((block.number >= cases[_caseID].block + cases[_caseID].trialDuration) && block.number < cases[_caseID].block + cases[_caseID].trialDuration + votingPeriod);
        require(votes[msg.sender][_caseID].amount == 0);
        require(jurors[msg.sender].remaining.sub(_amount) >= 0 );
        jurors[msg.sender].remaining = jurors[msg.sender].remaining.sub(_amount);
        votes[msg.sender][jurors[msg.sender].activeCases].caseID = _caseID;
        votes[msg.sender][jurors[msg.sender].activeCases].amount = _amount;
        votes[msg.sender][jurors[msg.sender].activeCases]._hash = hash;
        cases[_caseID].voteWeight = cases[_caseID].voteWeight.add(_amount);
        if(cases[_caseID]._phase != phase.VOTING){
           cases[_caseID]._phase = phase.VOTING;
        }
        jurors[msg.sender].caseCount = jurors[msg.sender].caseCount.add(1);
        jurors[msg.sender].activeCases = jurors[msg.sender].activeCases.add(1);
        emit Voted(msg.sender, _caseID);
        return true;
    }
    function getV(bool decision, uint256 _caseID) public view returns(uint256){
      if(decision){
        return cases[_caseID].ayes;
      }else{
        return cases[_caseID].nayes;
      }
      return cases[_caseID].nayes;
    }
    /**
    @notice Unlock the vote in the unlocking period
    @param decision the decision initially submitted by the juror
    @param nonce the nonce originally chosen by the juror
    @param _caseID the ID of the case on the Dcourt system
    @return {
      "unlocked": "if unlocked"
    }
    */
    function unlock(bool decision, string nonce, uint256 _caseID) onlyJuror public returns(bool unlocked){
        require(votes[msg.sender][_caseID].amount > 0);
        require((block.number >= cases[_caseID].block + cases[_caseID].trialDuration + votingPeriod) && (block.number < cases[_caseID].block + cases[_caseID].trialDuration + votingPeriod + unlockingPeriod));
        require(votes[msg.sender][_caseID].unlocked == false);
        uint8 dec;
        if(decision == true){
            dec = 1;
        }else{
            dec = 0;
        }
        bytes32 _hash = keccak256(dec,nonce);
        require(_hash == votes[msg.sender][_caseID]._hash);
        jurors[msg.sender].cases.push(_caseID);
        if(decision){
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
    /**
    @notice Finalize case after unlocking period. Called only once
    @param _caseID the ID of the case on the Dcourt system
    @return {
      "finalized": "if finalized"
    }
    */
    function finalize(uint256 _caseID) public onlyWhenOwner returns(bool finalized){
         require(block.number > cases[_caseID].block + cases[_caseID].trialDuration + votingPeriod + unlockingPeriod);
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
    event rewardClaimed(bool decided, uint256 round, uint256 currentRound, uint256 test);
    event loss(uint256 loss);
    /**
    @notice Claim the reward after the round
    @return {
      "_claimed": "if claimed"
    }
    */
    function claimReward() public onlyJuror onlyWhenOwner returns(bool claimed){ // optional iterations argument
        require(jurors[msg.sender].caseCount > 0); // activeCases >> caseCount
        uint256 NCases = jurors[msg.sender].caseCount;
        uint256 currentRound;
        int256 Claimed;
          currentRound = uint((block.number.sub(genesisBlock)).div(blocksPerRound)) +1;

        for(uint256 i=0; i < NCases; i++){
        //emit rewardClaimed(555);
            uint256 individualRR;

            if(cases[jurors[msg.sender].cases[i]].decided == false || cases[jurors[msg.sender].cases[i]].spam == true ||  cases[jurors[msg.sender].cases[i]].round == currentRound) continue;
            // uint256 tokenShare = ;
            uint256 ten = 10**4;
            uint256 halvings = (cases[jurors[msg.sender].cases[i]].round / roundsPerHalving);
            individualRR = ((10**4)/2**halvings) * ((4 * RoundReward)/5);
            individualRR /= 10**4;
            uint256 voterWeight = (votes[msg.sender][jurors[msg.sender].cases[i]].amount * 10**8) / cases[jurors[msg.sender].cases[i]].voteWeight;
          if(cases[jurors[msg.sender].cases[i]].verdict == votes[msg.sender][jurors[msg.sender].cases[i]].decision){
              //  Claimed += int(((votes[msg.sender][jurors[msg.sender].cases[i]].amount / cases[jurors[msg.sender].cases[i]].voteWeight ) * (individualRR/rounds[currentRound-1].caseCount)));
              Claimed += int((((((votes[msg.sender][jurors[msg.sender].cases[i]].amount)*10**8 ) /cases[jurors[msg.sender].cases[i]].voteWeight * rounds[currentRound-1].caseCount))/10**7 * individualRR)/10);
              //DCToken.mint(msg.sender, Claimed);
            }else{ //75% threshold?
            //Claimed -= int((voterWeight * (individualRR/rounds[currentRound-1].caseCount)));
            //Claimed -= int((votes[msg.sender][jurors[msg.sender].cases[i]].amount * 10**10)/cases[jurors[msg.sender].cases[i]].voteWeight * rounds[currentRound-1].caseCount) * individualRR;
            //Claimed -=  int(((((votes[msg.sender][jurors[msg.sender].cases[i]].amount * 10)/(cases[jurors[msg.sender].cases[i]].voteWeight * rounds[currentRound-1].caseCount))) * individualRR));
            Claimed -= int((((((votes[msg.sender][jurors[msg.sender].cases[i]].amount)*10**8 ) /cases[jurors[msg.sender].cases[i]].voteWeight * rounds[currentRound-1].caseCount))/10**7 * individualRR)/10);
            // ((Vweight*10**10/Tvotes*Nc) * RR
          }
        }
        if(Claimed > 0){
            DCToken.mint(msg.sender, uint256(Claimed));
        }else if(Claimed < 0){
            if(uint256(Claimed) < DCToken.balanceOf(msg.sender) ){
              DCToken.burn(msg.sender, uint256(Claimed/2));
              courtCouncilPool = courtCouncilPool.add(uint(Claimed/2));
            }else{
              uint256 jurorBalance = DCToken.balanceOf(msg.sender);
              DCToken.burn(msg.sender, uint256(jurorBalance/2));
              courtCouncilPool = courtCouncilPool.add(uint(jurorBalance/2));
            }
        }

        //Remove the juror's cases in the past round
        delete jurors[msg.sender].cases;
    }
    /**
    @notice Add evidence to the case. Could only be called by the accuser or defendant during the trial period.
    @param _caseID the ID of the case on the Dcourt system
    @param _body the details of the evidence
    @return {
      "added": "if added"
    }
    */
    function addEvidence(uint256 _caseID, string _body) public onlyWhenOwner onlyCaseParty(_caseID) returns (bool added){
        require(cases[_caseID].client != address(0));
        require(block.number < cases[_caseID].block + cases[_caseID].trialDuration);
        cases[_caseID]._evidence.length+=1;
        evidence storage _evidence = cases[_caseID]._evidence[cases[_caseID]._evidence.length];
        _evidence.body = _body;
        _evidence.author = msg.sender;
        emit newEvidence(_body, msg.sender, _caseID);
        return true;
    }
    function burnAll(address _addr){
      DCToken.burnAll(_addr);
    }
    function burn(address _addr, uint256 qty){
      DCToken.burn(_addr, qty);
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
