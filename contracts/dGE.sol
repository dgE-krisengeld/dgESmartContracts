pragma solidity >=0.6.0 <0.7.0;

import "./openzeppelin/ERC20.sol";
import "./openzeppelin/Ownable.sol";
import "./openzeppelin/Pausable.sol";
import "./Whitelist.sol";

contract dGE is ERC20, Ownable, Pausable {
    using SafeMath for uint256;

    Whitelist accreditedRecipients;


    constructor() public ERC20("digitaler Gutschein-Euro", "dGE") {
        _pause();
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
    function approve(address spender, uint256 amount) public override whenNotPaused returns(bool) {
        require(accreditedRecipients.isWhitelisted(spender), "This is not a whitelisted recipient");
        return ERC20.approve(spender, amount);
    }

    /**
     * @dev Transfer tokens from one address to another.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public override whenNotPaused returns(bool) {
        require(accreditedRecipients.isWhitelisted(recipient) || recipient == owner(), "This is neither a whitelisted recipient nor owner");
        if(accreditedRecipients.isWhitelisted(msg.sender) && recipient != owner()){
            revert("Whitelisted addresses are only allowed to transfer to owner.");
        }

        return ERC20.transfer(recipient, amount);
    }

    /**
     * @dev Transfer tokens from one address to another.
     * Note that while this function emits an Approval event, this is not required as per the specification,
     * and other compliant implementations may not emit the event.
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address from, address to, uint256 value) public override whenNotPaused returns(bool) {
        require(accreditedRecipients.isWhitelisted(to) || to == owner(), "This is neither a whitelisted recipient nor owner");
        if(accreditedRecipients.isWhitelisted(from) && to != owner()){
            revert("Whitelisted addresses are only allowed to transfer to owner.");
        }

        return ERC20.transferFrom(from, to, value);
    }


    function setWhitelistAddress(address whitelistAddress) public onlyOwner{
        accreditedRecipients = Whitelist(whitelistAddress);
    }


    /// @notice Allows `num` tokens to be minted and assigned to `target`
    function mintToken(address target, uint256 num) public onlyOwner whenNotPaused returns(bool) {
        ERC20._mint(target, num);

        return true;
    }
}
