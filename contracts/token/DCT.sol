pragma solidity ^0.4.24;

import "./ERC20.sol";
import "./ERC20Detailed.sol";
import "../utils/Ownable.sol";

contract DCT is ERC20, ERC20Detailed("Dcourt", "DCT", 18), Ownable {

    // Mappings

    mapping (address => bool) private _frozen;

    // Setters

    /**
    * @dev Allows only the owner to (un)freeze an account.
    * Used by the Dcourt core to freeze accounts in order to make them eligible for dividends and unfreeze them after they opt out.
    * @param account The address to be checked
    */
    function freeze(address account, bool value) public onlyOwner {
        require(_frozen[account] != value);
        _frozen[account] = value;
    }

    /**
    * @dev Transfer token for a specified address
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    */
    function transfer(address to, uint256 value) public returns (bool) {
        require(_frozen[msg.sender] == false);
        return super.transfer(to, value);
    }

    /**
    * @dev Transfer tokens from one address to another
    * @param from address The address which you want to send tokens from
    * @param to address The address which you want to transfer to
    * @param value uint256 the amount of tokens to be transferred
    */
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(_frozen[from] == false);
        return super.transferFrom(from, to, value);
    }

    /**
    * @dev Allows only the owner to mint an amount of tokens and assign it to
    * an account. This encapsulates the modification of balances such that the
    * proper events are emitted.
    * @param account The account that will receive the created tokens.
    * @param amount The amount that will be created.
    */
    function mint(address account, uint256 amount) public onlyOwner {
        _mint(account, amount);
    }

    // Getters

    /**
    * @dev Checks whether or not an account is frozen by owner
    * Used by the Dcourt core to check whether or not this address is eligible for dividends.
    * @param account The address to be checked
    */
    function isFrozen(address account) public view returns (bool) {
        return _frozen[account];
    }
    

}