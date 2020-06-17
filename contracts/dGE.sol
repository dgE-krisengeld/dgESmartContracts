pragma solidity >=0.6.0 <0.7.0;

import "./openzeppelin/ERC20.sol";
import "./openzeppelin/Ownable.sol";
import "./openzeppelin/Pausable.sol";
import "./openzeppelin/ECDSA.sol";
import "./Allowlist.sol";
import "./dGEpaperVouchers.sol";


/**
 * @title dge - "digitaler Gutschein-Euro"
 *  A blockchain-based voucher system to help citizens to help their local SME
 */
contract dGE is ERC20, Ownable, Pausable, dGEpaperVouchers {
    using SafeMath for uint256;

    /* Contract of allowlisted vendors */
    Allowlist accreditedRecipients;

    constructor() public ERC20("digitaler Gutschein-Euro", "dGE") {
        pause();
    }

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * @param spender The address who is allowed to spend `amount`. Cannot be the zero address and needs to be allowlisted
     * @param amount The amount allowed to be spend by spender
     */
    function approve(address spender, uint256 amount) public override whenNotPaused returns(bool) {
        require(accreditedRecipients.isAllowlisted(spender), "This is not a allowlisted recipient");

        return ERC20.approve(spender, amount);
    }

    /**
     * @dev Transfer tokens from one address to another.
     *
     * @param recipient The recipient cannot be the zero address and needs to be allowlisted or owner
     * @param amount The caller must have a balance of at least 'amount'
     */
    function transfer(address recipient, uint256 amount) public override whenNotPaused returns(bool) {
        require(accreditedRecipients.isAllowlisted(recipient) || recipient == owner(), "This is neither a allowlisted recipient nor owner");
        if(accreditedRecipients.isAllowlisted(msg.sender) && recipient != owner()){
            revert("Allowlisted addresses are only allowed to transfer to owner.");
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
        require(accreditedRecipients.isAllowlisted(to) || to == owner(), "This is neither a allowlisted recipient nor owner");
        if(accreditedRecipients.isAllowlisted(from) && to != owner()){
            revert("Allowlisted addresses are only allowed to transfer to owner.");
        }

        return ERC20.transferFrom(from, to, value);
    }

    /**
     * @dev Set contract address of deployed allowlist
     *
     * @param allowlistAddress The contract address of the deployed allowlist
     */
    function setAllowlistAddress(address allowlistAddress) public onlyOwner whenPaused returns(bool) {
        accreditedRecipients = Allowlist(allowlistAddress);

        return true;
    }

    /**
     * @dev Creates `amount` tokens and assigns them to `account`, increasing the total supply.
     *
     * @param account The address which token should assigned to
     * @param amount The amount of tokens that should be assigned to account
     */
    function mintToken(address account, uint256 amount) public onlyOwner returns(bool) {
        ERC20._mint(account, amount);

        return true;
    }


    /**
     * @dev Destroys `amount` tokens from `account`, reducing the total supply.
     *
     * @param account The address which token should burned from
     * @param amount The amount of tokens that should be taken from account
     */
    function burnToken(address account, uint256 amount) public onlyOwner returns(bool) {
        ERC20._burn(account, amount);

        return true;
    }

    /**
     * @dev Reserve voucher (by allowlisted vendor)
     *
     * @param hashedSignature The signature is kept secret by using its hash generated via a call (see support function below)
     * @param hashedClaim Unrevealed evidence that vendor knows the clear signature (see support function below)
     */
    function reservePaperVoucher(bytes32 hashedSignature, bytes32 hashedClaim) public override whenNotPaused returns(bool) {
        require(accreditedRecipients.isAllowlisted(msg.sender), "Msg.sender is not allowlisted!");
        dGEpaperVouchers.reservePaperVoucher(hashedSignature, hashedClaim);

        return true;
    }

    /**
     * @dev Redeem voucher by revealing clear signature (by allowlisted vendor)
     *
     * @param tokenOwner The address of the token owner
     * @param voucherNumber The numerical order of the voucher
     * @param clearSignature The clear signature implying access to the voucher
     */
    function redeemPaperVoucher(address tokenOwner, uint8 voucherNumber, bytes memory clearSignature, uint256 amount) public override whenNotPaused returns(bool) {
        require(accreditedRecipients.isAllowlisted(msg.sender), "Msg.sender is not allowlisted!");
        dGEpaperVouchers.redeemPaperVoucher(tokenOwner, voucherNumber, clearSignature, amount);

        return true;
    }
}