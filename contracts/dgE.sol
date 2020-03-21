pragma solidity >=0.4.21 <0.7.0;


import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract dgE is ERC20, SafeMath {
    string public name;
    string public symbol;
    uint8 public decimals;

    uint256 public _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    constructor() public {
        name = "Dezentraler gemeinschaftsEuro";
        symbol = "dgE";
        decimals = 18;
    }

    // determine total number of tokens floating around
    function totalSupply() public view returns (uint) {
      return _totalSupply - balances[address(0)];
    }

    // returns number of token from specific address
    function balanceOf(address _address) public view returns (uint balance) {
      return balances[_address];
    }

    // checks if transaction is allowed
    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
      return allowed[tokenOwner][spender];
    }

    // approve checked transaction
    function approve(address spender, uint tokens) public returns (bool success) {
      allowed[msg.sender][spender] = tokens;
      emit Approval(msg.sender, spender, tokens);
      return true;
    }

    // basic transfer function
    // needs to be modified to only send to whitelisted business accounts
    function transfer(address to, uint tokens) public returns (bool success) {
      balances[msg.sender] = add(balances[to], tokens);
      emit Transfer(msg.sender, to, tokens);
      return true;
    }

    // automates transfer function to specific account
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
      balances[from] = sub(balances[from][msg.sender], tokens);
      balances[to] = add(balances[to], tokens);
      emit Transfer(from, to, tokens);
      return true;
    }

}
