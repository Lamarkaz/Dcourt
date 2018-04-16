pragma solidity ^0.4.18;

contract DCTInterface {
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
