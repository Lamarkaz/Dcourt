import "./Arbitration/TokenInterface.sol";
import "./Arbitration/ClientInterface.sol";
import "./Arbitration/SafeMath.sol";

contract client{
  ClientContract DArbitration;
  address DCourtAddress;
  struct Case{
      address accuser;
      address defendant;
      string title;
      bool decided;
      uint256 videoID;
      bool verdict;
  }
   mapping (uint256 => Case) cases;
  uint256 videoCount;
  function client(address _DCourtAddress) public{
    DArbitration = ClientContract(_DCourtAddress);
    DCourtAddress = _DCourtAddress;
    DArbitration.register(0x96a582e15fcf669f0506accd5372edb3e9c3dc26a341ec60200d701fc03d16c1, 11, "whatever");
  }
  modifier onlyDCourt{
    require(msg.sender == DCourtAddress );
    _;
  }
  struct video{
    address creator;
    string title;
  }
  mapping (uint256 => video) videos;
  function createVideo(string _title){
    videoCount+=1;
    uint256 id = videoCount;
    videos[id].creator = msg.sender;
    videos[id].title = _title;
  }
  function claimVideo(uint256 videoID){
      uint256 caseID = DArbitration.fileCase(videos[videoID].creator, "bla", "Ownership claim");
      cases[caseID].accuser = msg.sender;
      cases[caseID].defendant = videos[videoID].creator;
      cases[caseID].title = "bla";
      cases[caseID].videoID = videoID;
  }
  function getVideoOwner(uint256 videoID) public view returns(address){
      return videos[videoID].creator;
  }
  function onVerdict(uint256 _caseID, bool verdict){
    if(verdict){
      cases[_caseID].verdict =  true;
      cases[_caseID].decided =  true;
      videos[cases[_caseID].videoID].creator = cases[_caseID].accuser;
    }
  }
}

contract BlockMiner {
  event MinedBlock(uint256 number);

  function getBlockNumber() public view returns(uint256){
    return block.number;
  }
  uint256 blocksMined =  0;
  function mine() public {
     blocksMined += 1;
     emit MinedBlock(block.number);
  }
}
