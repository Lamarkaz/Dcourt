pragma solidity ^0.4.18;

library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract ERC20 {
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Ownable {
    address public owner;
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    function Ownable() public {
    owner = msg.sender;
    }
    
    modifier onlyOwner() {
    require(msg.sender == owner);
    _;
    }
    
    modifier onlyOwnerContract() {
        require(msg.sender == owner && isContract(owner));
        _;
    }
    
    function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
    }
  
    function isContract(address addr) private view returns (bool) {
        uint size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

}

contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = true;
  
  modifier whenNotPaused() {
    require(!paused || msg.sender == owner);
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
}

contract DCT is ERC20, Ownable, Pausable {
    using SafeMath for uint256;

    /*
        Token
    */
    
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;

    uint256 constant private MAX_UINT256 = 2**256 - 1;
    string public name = "Dcourt";
    uint8 public decimals = 18;
    string public symbol = "DCT";
    uint256 public totalSupply;
    
    function totalSupply() public view returns (uint256) {
        return totalSupply;
    }

    function getOwner() public view returns(address){
        return owner;   
    }
    function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
        require(frozen[msg.sender] == false);
        require(_to != address(0));
        require(_value <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        decreaseVote(msg.sender, _value);
        balances[_to] = balances[_to].add(_value);
        increaseVote(_to, _value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
        require(frozen[_from] == false);
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
        balances[_from] = balances[_from].sub(_value);
        decreaseVote(_from, _value);
        balances[_to] = balances[_to].add(_value);
        increaseVote(_to, _value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }
    
    /*
        Minting
    */
    
    address public saleContract;
    
    function setSaleContract(address _contract) public onlyOwner {
        require(isContract(_contract));
        saleContract = _contract;
    }
    
    function removeSaleContract() public onlyOwner {
        saleContract = address(0);
    }
    
    event Mint(address indexed to, uint256 amount);
    
    function mint(address _to, uint256 _amount) public returns (bool) {
    require(msg.sender == owner || msg.sender == saleContract);
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    increaseVote(_to, _amount);
    emit Mint(_to, _amount);
    emit Transfer(address(0), _to, _amount);
    return true;
    }
    
    /*
        Governance
    */
    
    mapping (address => uint256) public owners;
    mapping (address => address) public voters;
    event Signal(address _voter, address _owner, uint256 _amount);
    event ElectedOwner(address _owner, uint256 _votes);
    
    function signal(address _owner) whenNotPaused public {
        require(isContract(_owner));
        require(balances[msg.sender] > 0);
        require(_owner != address(0) && _owner != owner);
        require(voters[msg.sender] != _owner);
        
        if(voters[msg.sender] != address(0)){
            owners[voters[msg.sender]].sub(balances[msg.sender]);
        }
        owners[_owner] = owners[_owner].add(balances[msg.sender]);
        voters[msg.sender] = _owner;
        emit Signal(msg.sender, _owner, balances[msg.sender]);
        if(owners[_owner] > (totalSupply.div(2))){
            owner = _owner;
            emit ElectedOwner(_owner, owners[_owner]);
        }
    }
    
    function ownerPercentage(address _owner) public view returns (uint256) {
        return (owners[_owner].div(totalSupply)).mul(100);
    }
    
    function decreaseVote(address _voter, uint256 _amount) private {
        if(voters[_voter] != address(0)){
            emit Signal(_voter, voters[_voter], balances[msg.sender].sub(_amount));
            owners[voters[_voter]] = owners[voters[_voter]].sub(_amount);
        }
        
    }
    
    function increaseVote(address _voter, uint256 _amount) private {
        if(voters[_voter] != address(0)){
            emit Signal(_voter, voters[_voter], balances[msg.sender].add(_amount));
            owners[voters[_voter]] = owners[voters[_voter]].add(_amount);
        }

    }
    
    /*
        Bounty
    */
    
    uint256 private nonce;
    
    function bounty(address _recipient, uint256 _amount, uint256 _nonce, bytes sig) public returns (bool) {
        require(_nonce == nonce.add(1));
        bytes32 _hash = keccak256(_recipient, _amount, _nonce);
        require(recover(_hash, sig) == owner);
        mint(_recipient, _amount);
        nonce = nonce.add(1);
    }
    
    /* 
        Dispute Arbitration Hooks
    */
    
    function relayFee(address _from, address _relay, uint256 _fee) public onlyOwnerContract returns(bool){
        require(balances[_from] >= _fee);
        balances[_from] = balances[_from].sub(_fee);
        decreaseVote(_from, _fee);
        balances[_relay] = balances[_relay].add(_fee);
        increaseVote(_relay, _fee);
        emit Transfer(_from, _relay, _fee);
        return true;
    }
    
    mapping (address => bool) public frozen;
    
    function freeze(address _account, bool _value) public onlyOwnerContract returns (uint256) {
        frozen[_account] = _value;
        return balances[_account];
    }
    
    function burn(address _account, uint256 _amount) public onlyOwnerContract returns (uint256) {
        balances[_account] = balances[_account].sub(_amount);
        decreaseVote(_account, _amount);
        emit Transfer(_account, address(0), _amount);
        return balances[_account];
    }
    
    function burnAll(address _account) public onlyOwnerContract returns(bool){
        decreaseVote(_account, balances[_account]);
        emit Transfer(_account, address(0), balances[_account]);
        balances[_account] = 0;
        return true;
    }
    
    /*
        Relayed Transactions
    */
    
    mapping (bytes32 => bool) public relayed;
    function relayTransfer(address _from, address _to, uint256 _value, uint256 _fee, uint256 _timeout, bytes sig) public whenNotPaused returns (bool) {
        require(frozen[_from] == false);
        require(balances[_from] >= (_value + _fee) && now < _timeout);
        bytes32 hash = keccak256(_from, _to, _value, _fee, _timeout);
        require(relayed[hash] != true);
        require(recover(hash, sig) == _from);
        balances[_from] = balances[_from].sub(_value + _fee);
        decreaseVote(_from, (_value + _fee));
        balances[_to] = balances[_to].add(_value);
        increaseVote(_to, _value);
        balances[msg.sender] = balances[msg.sender].add(_fee);
        increaseVote(msg.sender, _fee);
        emit Transfer(_from, _to, _value);
        emit Transfer(_from, msg.sender, _fee);
        relayed[hash] = true;
        return true;
    }
    
    /*
        Utils
    */
    
    function recover(bytes32 hash, bytes sig) private pure returns (address) {
        bytes32 r;
        bytes32 s;
        uint8 v;
        if (sig.length != 65) {
          return (address(0));
        }
        assembly {
          r := mload(add(sig, 32))
          s := mload(add(sig, 64))
          v := byte(0, mload(add(sig, 96)))
        }
        if (v < 27) {
          v += 27;
        }
        if (v != 27 && v != 28) {
          return (address(0));
        } else {
          return ecrecover(hash, v, r, s);
        }
    }
    
        function isContract(address addr) private view returns (bool) {
        uint size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }
}
