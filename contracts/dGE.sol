pragma solidity >=0.6.0 <0.7.0;

import "./openzeppelin/ERC20.sol";
import "./openzeppelin/Ownable.sol";
import "./openzeppelin/Pausable.sol";
import "./openzeppelin/ECDSA.sol";
import "./Whitelist.sol";
import "./dGEpaperVouchers.sol";


/**
 * @title dge - "digitaler Gutschein-Euro"
 *  A blockchain-based voucher system to help citizens to help their local SME
 */
contract dGE is ERC20, Ownable, Pausable, dGEpaperVouchers {
    using SafeMath for uint256;

    Whitelist accreditedRecipients;


    constructor() public ERC20("digitaler Gutschein-Euro", "dGE") {
        pause();
    }

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * @param spender The address who is allowed to spend `amount`. Cannot be the zero address and needs to be whitelisted
     * @param amount The amount allowed to be spend by spender
     */
    function approve(address spender, uint256 amount) public override whenNotPaused returns(bool) {
        require(accreditedRecipients.isWhitelisted(spender), "This is not a whitelisted recipient");
        return ERC20.approve(spender, amount);
    }

    /**
     * @dev Transfer tokens from one address to another.
     *
     * @param recipient The recipient cannot be the zero address and needs to be whitelisted or owner
     * @param amount The caller must have a balance of at least 'amount'
     */
    function transfer(address recipient, uint256 amount) public override whenNotPaused returns(bool) {
        require(accreditedRecipients.isWhitelisted(recipient) || recipient == owner(), "This is neither a whitelisted recipient nor owner");
        if(accreditedRecipients.isWhitelisted(msg.sender) && recipient != owner()){
            revert("Whitelisted addresses are only allowed to transfer to owner.");
        }

        return ERC20.transfer(recipient, amount);
    }

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's allowance.
     *
     * @param from The address which you want to send tokens from
     * @param to The address which you want to transfer to
     * @param value The amount of tokens to be transferred
     */
    function transferFrom(address from, address to, uint256 value) public override whenNotPaused returns(bool) {
        require(accreditedRecipients.isWhitelisted(to) || to == owner(), "This is neither a whitelisted recipient nor owner");
        if(accreditedRecipients.isWhitelisted(from) && to != owner()){
            revert("Whitelisted addresses are only allowed to transfer to owner.");
        }

        return ERC20.transferFrom(from, to, value);
    }

    /**
     * @dev Set contract address of deployed whitelist
     *
     * @param whitelistAddress The contract address of the deployed whitelist
     */
    function setWhitelistAddress(address whitelistAddress) public onlyOwner whenPaused returns(bool) {
        accreditedRecipients = Whitelist(whitelistAddress);

        return true;
    }

    /**
     * @dev Creates `amount` tokens and assigns them to `account`, increasing the total supply.
     *
     * @param account The address which token should assigned to
     * @param amount The amount of tokens that should be assigned to account
     */
    function mintToken(address account, uint256 amount) public onlyOwner whenNotPaused returns(bool) {
        ERC20._mint(account, amount);

        return true;
    }
}
