import "./TokenInterface.sol";
import "./ClientInterface.sol";
import "./SafeMath.sol";

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
    DArbitration.register("96a582e15fcf669f0506accd5372edb3e9c3dc26a341ec60200d701fc03d16c1", 5, "whatever");
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
    videoCount++;
    var id = videoCount;
    video[id].creator = msg.sender;
    video[id].title = _title;
  }
  function claimVideo(uint256 videoID){
      uint256 caseID = DArbitration.fileCase(videos[videoID].creator, "bla", "Ownership claim");
      cases[caseID].accuser = msg.sender;
      cases[caseID].defendant = videos[videoID].creator;
      cases[caseID].title = "bla";
      cases[caseID].videoID = videoID;
  }
  function onVerdict(uint256 _caseID, bool verdict){
    if(verdict){
      cases[_caseID].verdict =  true;
      cases[_caseID].decided =  true;
      videos[cases[_caseID].videoID].creator = cases[_caseID].accuser;
    }
  }
}
