pragma solidity >=0.4.21 <0.7.0;

import "@openzeppelin/contracts/token/ERC20/ERC20Mintable.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "./Whitelist.sol";

contract dgE is ERC20Mintable, Ownable {

    using SafeMath for uint256;

    string public name;
    string public symbol;
    uint8 public decimals;


    Whitelist allowed_recipients;
    bool initialized;

    /*
     * Events
     */
    event Minted(address indexed _to, uint256 indexed _num);

    constructor() public {
        name = "Dezentraler gemeinschaftsEuro";
        symbol = "dgE";
        decimals = 18;
    }

    modifier isInitialized() {
        require(initialized, "Whitelist not set yet");
        _;
    }

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     *
     * @param spender spender who is allowed to spend amount. Cannot be the zero address.
     * @param amount amount allowed to be spend.
     */
    function approve(address spender, uint256 amount) public isInitialized returns (bool) {
        require(allowed_recipients.isWhitelisted(spender), "This is not a whitelisted recipient");
        return super.approve(spender, amount);
    }

    /**
     * @dev Transfer tokens from one address to another.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public isInitialized returns (bool) {
        require(allowed_recipients.isWhitelisted(recipient) || recipient == owner(), "This is not a whitelisted recipient to send to");
        if(allowed_recipients.isWhitelisted(_msgSender()) && recipient != owner()){
            revert("Whitelisted addresses are only allowed to transfer to owner.");
        }
        return super.transfer(recipient, amount);
    }

    /**
     * @dev Transfer tokens from one address to another.
     * Note that while this function emits an Approval event, this is not required as per the specification,
     * and other compliant implementations may not emit the event.
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address from, address to, uint256 value) public isInitialized returns (bool) {
        require(allowed_recipients.isWhitelisted(to) || to == owner(), "This is not a whitelisted recipient to send to");
        if(allowed_recipients.isWhitelisted(from) && to != owner()){
            revert("Whitelisted addresses are only allowed to transfer to owner.");
        }
        return super.transferFrom(from, to, value);
    }

    function setWhitelistAddress(address whitelistAddress) public onlyMinter{
        allowed_recipients = Whitelist(whitelistAddress);
        initialized = true;
    }

    /// @notice Allows `num` tokens to be minted and assigned to `target`
    function mintFor(address target, uint256 num) public onlyMinter {
        mint(target, num);
    }
}
