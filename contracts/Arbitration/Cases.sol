pragma solidity ^0.4.18;
import "./Arbitration.sol"
contract DCArbitration {
  function isContract(address addr) private view returns (bool);
}
contract Cases{
  address public ArbitrationAddr;
  DCArbitration DCA;
  function Cases(address _Arbitration){
    DCA = DCArbitration(_Arbitration);
  }
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
      require(trialDuration >= DCA.minTrialPeriod);
      DCA.caseCounter++;
      Case storage filedCase = DCA.cases[caseCounter];
      filedCase.client = msg.sender;
      filedCase.accuser = tx.origin;
      filedCase.defendant = _defendant;
      filedCase.block = block.number;
      filedCase.trialDuration = DCA.trialDuration;
      //  evidence storage _evidence = filedCase._evidence[0];
      //  _evidence.body = _statement;
      //  _evidence.author = tx.origin;
      filedCase.title = _title;
      filedCase._phase = phase.TRIAL;
      filedCase.collateral = DCA.collateral;
      emit DCA.newCase(tx.origin,
      _defendant,
      msg.sender,
      block.number,
      _title,
      _statement
      );
      DCA.frozenBalance[tx.origin] = DCA.frozenBalance[tx.origin].add(collateral);
      DCToken.burn(tx.origin, collateral);
      return caseCounter;

  }

  /**
  @notice Finalize case after unlocking period. Called only once
  @param _caseID the ID of the case on the Dcourt system
  @return {
    "finalized": "if finalized"
  }
  */
  function finalize(uint256 _caseID) public onlyWhenOwner returns(bool finalized){
       require(block.number > DCA.cases[_caseID].block + DCA.cases[_caseID].trialDuration + DCA.votingPeriod + DCA.unlockingPeriod);
       require(DCA.cases[_caseID].decided == false);
       bool verdict = DCA.cases[_caseID].ayes > DCA.cases[_caseID].nayes;
       ClientContract cc = ClientContract(cases[_caseID].client);
       cc.onVerdict(_caseID, verdict);
       DCA.cases[_caseID].decided = true;
       DCA.cases[_caseID].verdict = verdict;
       DCA.rounds[(block.number.sub(DCA.genesisBlock)).div(DCA.blocksPerRound)].roundWeight = DCA.rounds[(block.number.sub(DCA.genesisBlock)).div(DCA.blocksPerRound)].roundWeight.add(DCA.cases[_caseID].voteWeight);
       DCA.rounds[(block.number.sub(DCA.genesisBlock)).div(DCA.blocksPerRound)].caseCount = DCA.rounds[(block.number.sub(DCA.genesisBlock)).div(DCA.blocksPerRound)].caseCount.add(1);
      //  rounds[(block.number.sub(genesisBlock)).div(blocksPerRound)].roundWeight = roundWeights[(block.number.sub(genesisBlock)).roundWeight.div(blocksPerRound)].add(cases[_caseID].voteWeight);
       DCA.cases[_caseID].round = (block.number.sub(DCA.genesisBlock)).div(DCA.blocksPerRound);
       return verdict;
  }
  /**
  @notice Report a case as spam. Can only be called once on every case.
  @param _caseID the ID of the case on the Dcourt system
  @return {
    "reported": "if reported"
  }
  */
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
  function unfreezeCollateral(uint256 _caseID){
   require(block.number > cases[_caseID].block + clients[cases[_caseID].client].trialDuration + votingPeriod + unlockingPeriod + challengingPeriod && cases[_caseID].spam == false);
    DCToken.mint(cases[_caseID].accuser, (cases[_caseID].collateral/2));
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
}
