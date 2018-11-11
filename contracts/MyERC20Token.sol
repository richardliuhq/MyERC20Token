pragma solidity ^0.4.21;

import "./IERC20.sol";
import "./SafeMath.sol";
import "./Ownable.sol";
import "./Pausable.sol";

contract MyERC20Token is IERC20, Pausable,Ownable {
    using SafeMath for uint256;
    
    string public constant SYMBOLNAME = "HQL";
    string public constant SYMBOLDESC = "Richard's fixed supply token";
    uint256 u256_TotalSupply = 1000000;
    
    //Specify map o keep the account balance  
    mapping (address => uint256) mp_balances;
    
    //Specify map to specify approved transfer address and amount
    mapping(address => mapping(address => uint256)) mp_allowed;
    
    constructor() public {
            mp_balances[msg.sender] = u256_TotalSupply; //set all suppled token to the owner account by default
    }
    
    //Get all suppled token
    function totalSupply() view public returns(uint256){
        return u256_TotalSupply;
    }
    
    //Get tokens for specifie account
    function balanceOf(address _account) view public returns(uint256){
       return mp_balances[_account];
    }
    
    //Transfer tokens from owner to the specified account
    function transfer(address _to, uint256 _amount) public whenNotPaused onlyOwner returns(bool success){
        _transfer(msg.sender, _to, _amount);
        return true;
    }
    
   /**
   * @dev Transfer tokens from one address to another
   * @param from address The address which you want to send tokens from
   * @param to address The address which you want to transfer to
   * @param value uint256 the amount of tokens to be transferred
   */
    function transferFrom(address from,address to,uint256 value) public whenNotPaused returns (bool) {
     mp_allowed[from][msg.sender] = mp_allowed[from][msg.sender].sub(value);
      _transfer(from, to, value);
      return true;
    }
    
    //specify accounts who can withdwae tokens from my account
    function approve(address _spender,uint _amount) public whenNotPaused returns(bool success){
        require(_spender != address(0));
        mp_allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender,_amount);
        return true;
    }
    
    //get alllowed remaining amount
    function allowance(address _owner, address _spender) view public returns (uint256 remaining){
        return mp_allowed[_owner][_spender];
    }
    
    
      /**
  * @dev Transfer token for a specified addresses
  * @param from The address to transfer from.
  * @param to The address to transfer to.
  * @param value The amount to be transferred.
  */
  function _transfer(address from, address to, uint256 value) internal {
    require(to != address(0));

    mp_balances[from] = mp_balances[from].sub(value);
    mp_balances[to] = mp_balances[to].add(value);
    emit Transfer(from, to, value);
  }
}
