pragma solidity ^0.4.18;

import "./SafeMath.sol";
import "./DCTInterface.sol";

contract DCTPresale {
    using SafeMath for uint256;

    /*
      Ownable
    */
        address public owner;

        event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

        function Ownable() public {
            owner = msg.sender;
        }

        modifier onlyOwner() {
            require(msg.sender == owner);
            _;
        }

        function transferOwnership(address newOwner) public onlyOwner {
            require(newOwner != address(0));
            emit OwnershipTransferred(owner, newOwner);
            owner = newOwner;
        }


    /*
      Pausable
    */
      event Pause();
      event Unpause();

      bool public paused = true;

      modifier whenNotPaused() {
        require(!paused);
        _;
      }

      modifier whenPaused() {
        require(paused);
        _;
      }

      function pause() onlyOwner public {
        require(!paused);
        paused = true;
        emit Pause();
      }

      function unpause() onlyOwner whenPaused public {
        paused = false;
        emit Unpause();
      }

    DCT public token;

    uint256 public rate;
    uint256 public weiRaised;
    uint256 public cap;
    address public wallet;

    mapping(address => bool) public whitelist;

    modifier isWhitelisted(address _beneficiary) {
        require(whitelist[_beneficiary]);
        _;
    }

    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    function DCTPresale(uint256 _rate, DCT _token, uint256 _cap) public {
        require(_rate > 0);
        require(_token != address(0));
        require(_cap > 0);
        cap = _cap;
        rate = _rate;
        token = _token;
        wallet = msg.sender;
    }

    function () external whenNotPaused payable {
        buyTokens(msg.sender);
    }

    function buyTokens(address _beneficiary) whenNotPaused isWhitelisted(_beneficiary) public payable {

        uint256 weiAmount = msg.value;
        require(weiRaised.add(weiAmount) <= cap);
        require(_beneficiary != address(0));
        require(weiAmount != 0);

        uint256 tokens = weiAmount.mul(rate);

        require(DCT(token).mint(_beneficiary, tokens));

        weiRaised = weiRaised.add(weiAmount);

        emit TokenPurchase(msg.sender, _beneficiary, weiAmount, tokens);

        wallet.transfer(msg.value);
    }

    function setRate(uint256 _newRate) public onlyOwner returns (bool) {
        require(_newRate > 0);
        rate = _newRate;
    }

    function setCap(uint256 _newCap) public onlyOwner returns (bool) {
        require(_newCap > 0);
        cap = _newCap;
    }

    function setWallet(address _newWallet) public onlyOwner returns (bool) {
        require(_newWallet != address (0));
        wallet = _newWallet;
    }

    function capReached() public view returns (bool) {
        return weiRaised >= cap;
    }

    function addToWhitelist(address _beneficiary) external onlyOwner {
        whitelist[_beneficiary] = true;
    }


    function addManyToWhitelist(address[] _beneficiaries) external onlyOwner {
        for (uint256 i = 0; i < _beneficiaries.length; i++) {
            whitelist[_beneficiaries[i]] = true;
        }
    }

    function removeFromWhitelist(address _beneficiary) external onlyOwner {
        whitelist[_beneficiary] = false;
    }

}
