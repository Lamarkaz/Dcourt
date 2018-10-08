pragma solidity ^0.4.24;

import "../token/DCT.sol";
import "../utils/Address.sol";
import "./IClient.sol";

contract Dcourt {
    
    // Global Variables

    uint public minFee;
    uint public minCaseDuration;
    uint public numCases;
    uint public commitDuration;
    uint public revealDuration;
    uint public juryJoinDuration;
    uint public dividend;
    DCT token;

    // Mappings

    mapping (uint => Case) private cases;
    mapping (address => Juror) private jurors;

    // Event Definitions
    event Motion(address indexed clientContract, uint caseId, uint fee, string allegation, string agreement, address indexed requester, address indexed defendant, uint duration, uint timestamp, uint appeal);
    event BumpFee(address indexed account, uint caseId, uint fee, uint timestamp);
    event EvidenceSubmission(address indexed submitter, uint caseId, uint evidenceId, string body, uint timestamp);
    event JuryJoin(address indexed account, uint weight, uint timestamp);
    event JuryLeave(address indexed account, uint timestamp);
    event Commit(address indexed account, uint indexed caseId, uint weight, uint timestamp);
    event Reveal(address indexed account, uint indexed caseId, bool vote);
    event Verdict(uint caseId, uint8 verdict, uint8 percentage);

    // Structs & Enums

    struct Evidence {
        uint id;
        string body;
        address submitter;
        uint timestamp;
    }

    struct Case {
        address client; // Contract
        address requester;
        address defendant; // Optional: address(0) means no defendant
        string agreement; // Provided by the contract and used by jurors as rules
        string allegation; // Used as title of the case
        bool finalized;
        mapping (uint => Evidence) evidence; // Key is evidence id
        mapping (uint => address) jurors; // Used as an array of jurors. Useful to iterate through Jurors to do work
        uint numEvidence;
        uint numJurors;
        uint fee;
        uint timestamp; // Time the case was created
        uint duration; // Provided by the contract
        uint appeal; // ID of appealed case. 0 means not an appeal.
        uint weight;
        uint yes;
        uint no;
    }

    struct Vote {
        bool opinion;
        bytes32 commit; // Hash
        string salt;
        uint weight;
    }

    struct Juror {
        address account;
        uint weight;
        uint timestamp;
        uint activeVotes;
        mapping (uint => Vote) cases; // Key is case id;
    }


    // Modifiers

    modifier onlyJuror() {
        require(jurors[msg.sender].account != address(0));
        require(now > (jurors[msg.sender].timestamp + juryJoinDuration));
        _;
    }

    modifier ifCaseStatus(uint id, string status) {
        require(stringEqual(caseStatus(id), status));
        _;
    }

    // Constructor
    constructor(address tokenContract, uint _minFee, uint _minCaseDuration, uint _commitDuration, uint _revealDuration, uint _juryJoinDuration) public {
        token = DCT(tokenContract);
        minFee = _minFee;
        minCaseDuration = _minCaseDuration;
        commitDuration = _commitDuration;
        revealDuration = _revealDuration;
        juryJoinDuration = _juryJoinDuration;
    }

    // Setters

    /**
    * @dev Called by client smart contract to file a new case.
    * Must include a payment bigger or equal to minFee
    * Throws if sender is not a contract, fee is smaller than minFee or duration is smaller than minCaseDuration.
    * @param allegation String usually defined by the requester and used as a case title.
    * @param firstEvidence Opening statement submitted by the requester; treated as first evidence.
    * @param agreement Agreement provided by the client contract. Jurors take their decision based on the agreement text.
    * @param defendant Defendant of the case. If there is no defendant, defendant can be replaced with address(0).
    * @param duration Duration of the trial period in seconds. Must not be smaller than minCaseDuration.
    */
    function motion(string allegation, string firstEvidence, string agreement, address defendant, uint duration, uint appeal) public payable returns (uint) {
        require(Address.isContract(msg.sender));
        require(msg.value >= minFee);
        require(duration >= minCaseDuration);
        numCases++;
        Case storage _case = cases[numCases];
        _case.client = msg.sender;
        _case.requester = tx.origin;
        _case.defendant = defendant;
        _case.agreement = agreement;
        _case.allegation = allegation;
        _case.appeal = appeal;
        (_case.fee, ) = divide(msg.value, 2);
        _case.timestamp = now;
        _case.duration = duration;
        _case.numEvidence = 1;
        Evidence storage _evidence =_case.evidence[1];
        _evidence.id = 1;
        _evidence.body = firstEvidence;
        _evidence.submitter = tx.origin;
        _evidence.timestamp = now;
        // Give 50% of fee + remainder to dividends
        (, uint r) = divide(msg.value, 2);
        dividend = dividend + _case.fee + r;
        emit Motion(msg.sender, numCases, _case.fee, allegation, agreement, tx.origin, defendant, duration, now, appeal);
        emit EvidenceSubmission(tx.origin, numCases, 1, firstEvidence, now);
        return numCases;
    }

    function bumpFee(uint id) public payable ifCaseStatus(id, "trial") {
        require(msg.value > 0);
        (uint q, uint r) = divide(msg.value, 2);
        Case storage _case = cases[id];
        _case.fee = _case.fee + q;
        dividend = dividend + q + r;
        emit BumpFee(msg.sender, id, q, now);
    }

    function submitEvidence(uint id, string body) public payable ifCaseStatus(id, "trial") returns (uint evidenceId) {
        Case storage _case = cases[id];
        if(_case.requester != msg.sender && _case.defendant != msg.sender) {
            require(msg.value >= minFee); // Evidence submission is open to anyone but requires minimum fee for non-involved people to prevent spam.
        }
        if(msg.value > 0) {
            bumpFee(id);
        }
        _case.numEvidence++;
        evidenceId = _case.numEvidence;
        Evidence storage _evidence = _case.evidence[evidenceId];
        _evidence.id = evidenceId;
        _evidence.body = body;
        _evidence.submitter = msg.sender;
        _evidence.timestamp = now;
        emit EvidenceSubmission(msg.sender, id, evidenceId, body, now);
    }

    function joinJury() public payable {
        require(jurors[msg.sender].account == address(0));
        require(msg.value > 0);
        Juror storage _juror = jurors[msg.sender];
        _juror.account = msg.sender;
        _juror.timestamp = now;
        _juror.weight = msg.value;
        emit JuryJoin(msg.sender, msg.value, now);
    }

    function leaveJury() public onlyJuror {
        require(jurors[msg.sender].activeVotes == 0);
        delete jurors[msg.sender];
        emit JuryLeave(msg.sender, now);
        msg.sender.transfer(jurors[msg.sender].weight);
    }

    function commit(uint id, uint weight, bytes32 h) public onlyJuror ifCaseStatus(id, "commit") {
        Juror storage _juror = jurors[msg.sender];
        Vote storage _vote = _juror.cases[id];
        require(_vote.commit == bytes32(0));
        require(_juror.weight >= weight);
        _juror.weight = _juror.weight - weight;
        _juror.activeVotes++;
        _vote.weight = weight;
        _vote.commit = h;
        Case storage _case = cases[id];
        _case.weight = _case.weight + weight;
        _case.numJurors++;
        _case.jurors[_case.numJurors] = msg.sender;
        emit Commit(msg.sender, id, weight, now);
    }

    function reveal(uint id, string salt, bool vote) public ifCaseStatus(id, "reveal") {
        require(bytes(salt).length > 0);
        Vote storage _vote = jurors[msg.sender].cases[id];
        require(_vote.commit != bytes32(0));
        require(bytes(_vote.salt).length == 0);
        require(generateCommit(salt, vote) == _vote.commit);
        _vote.salt = salt;
        _vote.opinion = vote;
        Case storage _case = cases[id];
        if(vote == true) {
            _case.yes = _case.yes + _vote.weight;
        }else{
            _case.no = _case.no + _vote.weight;
        }
        emit Reveal(msg.sender, id, vote);
    }

    function finalize(uint id) public ifCaseStatus(id, "unfinalized") {
        Case storage _case = cases[id];
        _case.finalized = true;
        string memory status = caseStatus(id);
        uint totalWeight = _case.no + _case.yes;
        uint8 verdict;
        uint8 percentage;
        uint verdictWeight;
        if(stringEqual(status, "no")) {
            percentage = percent(_case.no, totalWeight);
            verdictWeight = _case.no;
        }else if(stringEqual(status, "yes")){
            verdict = 1;
            percentage = percent(_case.yes, totalWeight);
            verdictWeight = _case.yes;
        }else if(stringEqual(status, "undecided")) {
            verdict = 2;
            percentage = 50;
            verdictWeight = _case.yes; // Both yes and no are equal in this case
        } else {
            revert();
        }
        emit Verdict(id, verdict, percentage);
        IClient client;
        if(_case.yes == 0 && _case.no == 0) {
            client.onVerdict.value(_case.fee)(id, verdict, percentage, totalWeight, verdictWeight); // If not one juror votes, return case fee to client contract (half original fee).
        }else{
            client.onVerdict(id, verdict, percentage, totalWeight, verdictWeight);
        }
    }

    // Getters

    /**
    * @dev Returns a string indicating the current status of a case.
    * Possible return values are: trial, commit, reveal, unfinalized, yes, no and undecided.
    * Throws if case does not exist.
    * @param id The ID of the queried case.
    */
    function caseStatus(uint id) public view returns (string) {
        Case memory _case = cases[id];
        require(_case.client != address(0)); // Require that the queried case already exists
        if(now < _case.timestamp + _case.duration) {
            return "trial";
        }else if(now < (_case.timestamp + _case.duration + commitDuration)) {
            return "commit";
        }else if(now < (_case.timestamp + _case.duration + commitDuration + revealDuration) && (_case.no + _case.yes) < _case.weight) {
            return "reveal";
        }else if(!_case.finalized) {
            return "unfinalized";
        } else {
            if(_case.yes > _case.no) {
                return "yes";
            }else if(_case.yes < _case.no) {
                return "no";
            } else {
                return "undecided"; // If no one votes or if votes are even
            }
        }
    }

    function generateCommit(string salt, bool vote) public pure returns (bytes32) {
        return keccak256(abi.encode(vote, salt));
    }

    /**
    * @dev Returns the evidence body, the address of the submitter and the evidence submission timestamp in seconds.
    * Throws if evidence does not exist.
    * @param caseId The ID of the queried case.
    * @param evidenceId The ID of the queried evidence.
    */
    function caseEvidence(uint caseId, uint evidenceId) public view returns (string body, address submitter, uint timestamp) {
        Evidence memory _evidence = cases[caseId].evidence[evidenceId];
        require(_evidence.submitter != address(0));
        body = _evidence.body;
        submitter = _evidence.submitter;
        timestamp = _evidence.timestamp;
    }

    function jurorShare(uint caseId, address account) public view returns (uint share) {
        require(stringEqual(caseStatus(caseId), "yes") || stringEqual(caseStatus(caseId), "no") || stringEqual(caseStatus(caseId), "undecided"));
        Case memory _case = cases[caseId];
        Juror storage _juror = jurors[account];
        Vote memory _vote = _juror.cases[caseId];
        uint jurorWeight = _vote.weight;
        bool unrevealed = (bytes(_vote.salt).length == 0);
        if(_case.yes == _case.no) { //If undecided
            if(unrevealed) { // If Juror did not reveal vote
                share = jurorWeight / 2; // Only return half of original weight, the rest is burned.
            }else {
                share = jurorWeight; // Return full weight;
            }
        }else{ // If decided
            uint teamWeight;
            if(_vote.opinion) {
                teamWeight = _case.yes;
            } else {
                teamWeight = _case.no;
            }
            uint totalWeight = (_case.yes + _case.no);
            uint teamShare = ((teamWeight / totalWeight) * (totalWeight - teamWeight)) + teamWeight; // WRONG, percentage not share
            //if()
            share = teamShare / jurorWeight; //WRONG
            if(unrevealed) {
                share = share / 2; // Halve share as a penalty for unrevealing
            }else if((_case.yes > _case.no && _vote.opinion) || (_case.no > _case.yes && !_vote.opinion)) { // If winner; 'else if' because winner cannot be unrevealed, saves gas.
                // Add fee share
                // Add unrevealed share
            }
        }
    }

    // Internal

    function divide(uint numerator, uint denominator) internal pure returns(uint quotient, uint remainder) {
        quotient  = numerator / denominator;
        remainder = numerator - denominator * quotient;
    }

    function percent(uint numerator, uint denominator) internal pure returns(uint8 quotient) {
            // caution, check safe-to-multiply here
            uint _numerator  = numerator * 10 ** 3;
            // with rounding of last digit
            uint _quotient =  ((_numerator / denominator) + 5) / 10;
            return uint8( _quotient);
    }

    function stringEqual(string a, string b) internal pure returns (bool) {
    if(bytes(a).length != bytes(b).length) {
        return false;
    } else {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }
}

}