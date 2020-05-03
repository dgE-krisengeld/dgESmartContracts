pragma solidity >=0.6.0 <0.7.0;

import "./openzeppelin/Ownable.sol";
import "./openzeppelin/Pausable.sol";
import "./openzeppelin/ECDSA.sol";


/**
 * @title dGE-Paperwallet
 *  dGE- "digitaler Gutschein-Euro"
 *  A blockchain-based voucher system to help citizens to help their local SME
 */
contract dGEpaperVouchers is Ownable, Pausable {
    using ECDSA for bytes32;

    uint private reservationDurationBlocks = 0; //this value needs to be adjusted

    struct dGEowner{
        bytes32 hashedPassword;
        uint16 lastVoucherNumber;
    }
    mapping (address => dGEowner) private dGEowners;

    struct Voucher{
        bool isValid;
        address recipient;
        uint reservationblockHeight;
        bytes32 hashedClaim;
    }
    mapping (bytes32 => Voucher) private vouchers;

    //Step0: Set initial passwords for citizens (by government)
    function setOwnerPasswords(address tokenOwner, bytes32 hashedPassword) public virtual onlyOwner whenNotPaused returns(bool success) {
        //Check input
        require(hashedPassword != "", "hashedPassword was not inserted.");

        //Creating voucher
         dGEowners[tokenOwner].hashedPassword = hashedPassword;

        return true;
    }

    //Step1: Create voucher (by government)
    function createVoucher(bytes32 hashedSignature) public virtual onlyOwner whenNotPaused returns(bool success) {
        //Check input
        require(hashedSignature != "", "hashedSignature was not inserted.");

        //Creating voucher
        vouchers[hashedSignature].isValid = true;

        return true;
    }

    //Step2: Reserve voucher (by whitelisted shop owner)
    function reservePaperVoucher(address tokenOwner, uint16 voucherNumber, bytes32 hashedSignature, bytes32 hashedClaim) public virtual whenNotPaused returns(uint reservationblockHeight){
        //Do some checks
        require(vouchers[hashedSignature].isValid == true, "Voucher does not exist or was  already redeemed!");
        require(voucherNumber > dGEowners[tokenOwner].lastVoucherNumber, "Voucher with higher number has already been used!");
        require(vouchers[hashedSignature].reservationblockHeight <= (block.number+reservationDurationBlocks), "Voucher still reserved!");

        //Perform reservation
        vouchers[hashedSignature].recipient = msg.sender;
        vouchers[hashedSignature].reservationblockHeight = block.number;
        vouchers[hashedSignature].hashedClaim = hashedClaim;

        return block.number;
    }

    //Step3: Redeem voucher by revealing clear signature (by whitelisted shop owner)
    function redeemPaperVoucher(address tokenOwner, uint16 voucherNumber, bytes memory clearSignature, bytes32 hashedPassword) public virtual whenNotPaused returns(bool success) {
        //Check for correct password
        require(hashedPassword == dGEowners[tokenOwner].hashedPassword);

        //Check if tokenOwner and signature match
        bytes32 messageHash = keccak256(abi.encodePacked(tokenOwner, voucherNumber, address(this)));
        address recoveredTokenOwnerAddress = recover(messageHash, clearSignature);
        require(tokenOwner == recoveredTokenOwnerAddress, "Given tokenOwner and signature mismatch!");

        //Check if voucher is claimable and valid
        bytes32 hashedSignature = createHashedSignature(recoveredTokenOwnerAddress, clearSignature);
        require(vouchers[hashedSignature].isValid == true, "Voucher does not exist or was  already redeemed!");
        require(vouchers[hashedSignature].recipient == msg.sender, "Voucher was not reserved by sender!");

        //There should be no way to come this far without knowing the clearSignature one transaction before this one
        assert(vouchers[hashedSignature].hashedClaim == createHashedClaim(clearSignature));

        //Optimistic accounting
        vouchers[hashedSignature].isValid = false;

        //DO ACCOUNTING

        return true;
    }


    /**
     * @dev Support functions
     */
    function createHashedPassword(address tokenOwner, string memory clearPassword) public view returns(bytes32 hashedPassword) {
        return keccak256(abi.encodePacked(tokenOwner, clearPassword, address(this)));
    }

    function createHashedSignature(address tokenOwner, bytes memory clearSignature) public view returns(bytes32 hashedSignature) {
        return keccak256(abi.encodePacked(tokenOwner, clearSignature, address(this)));
    }

    function createHashedClaim(bytes memory clearSignature) public view returns(bytes32 hashedClaim) {
        return keccak256(abi.encodePacked(clearSignature, msg.sender, address(this)));
    }

    function changeReservationDuration(uint newDurationBlocks) public virtual onlyOwner returns(bool success){
        reservationDurationBlocks = newDurationBlocks;
        return true;
    }

    function ethSignedHash(bytes32 messageHash) public pure returns(bytes32) {
        return messageHash.toEthSignedMessageHash();
    }

    function recover(bytes32 hash, bytes memory signature) public pure returns(address) {
        return hash.recover(signature);
    }
}