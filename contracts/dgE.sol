pragma solidity >=0.4.21 <0.7.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "./Whitelist.sol";

contract dgE is ERC20 {

    using SafeMath for uint256;

    string public name;
    string public symbol;
    uint8 public decimals;

    uint256 private _totalSupply;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowed;

    Whitelist allowed_recipients;

    /*
     * Events
     */
    event Minted(address indexed _to, uint256 indexed _num);

    constructor() public {
        name = "Dezentraler gemeinschaftsEuro";
        symbol = "dgE";
        decimals = 18;
    }

    /**
     * @dev Total number of tokens in existence
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev Gets the balance of the specified address.
     * @param owner The address to query the balance of.
     * @return An uint256 representing the amount owned by the passed address.
     */
    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param owner address The address which owns the funds.
     * @param spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowed[owner][spender];
    }

    /**
     * @dev Transfer token for a specified address
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     */
    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev Transfer tokens from one address to another.
     * Note that while this function emits an Approval event, this is not required as per the specification,
     * and other compliant implementations may not emit the event.
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(allowed_recipients.isWhitelisted(to), "This is not a whitelisted recipient to send to");
        _transfer(from, to, value);
        _approve(from, msg.sender, _allowed[from][msg.sender].sub(value));
        return true;
    }

    function setWhitelistAddress(address whitelistAddress) public{
        allowed_recipients = Whitelist(whitelistAddress);
    }

    /// @notice Allows `num` tokens to be minted and assigned to `target`
    function mintFor(uint256 num, address target) public {
        _balances[target] += num;
        _totalSupply += num;

        emit Minted(target, num);

        require(_balances[target] >= num, "Balance should be greater or equal the amount minted");
        assert(_totalSupply >= num);
    }
}
