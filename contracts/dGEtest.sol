pragma solidity >=0.6.0 <0.7.0;

//import "./openzeppelin/Ownable.sol";
//import "./openzeppelin/Pausable.sol";
import "./openzeppelin/ECDSA.sol";


/**
 * @title dGEpaperVouchers
 *  dGE- "digitaler Gutschein-Euro"
 *  A blockchain-based voucher system to help citizens to help their local SME
 */
contract dGEpaperVouchers {
    using ECDSA for bytes32;

    uint private reservationDurationBlocks = 0; //Time in blocks the voucher is reserved by vendor until it can be reclaimed

    /* Storage struct of token owners */
    struct dGEowner{
        uint8 lastVoucherNumber;        //Vouchers are used in numerical order
        bytes32[] hashedPasswords;         //Vouchers are protected by password
        bytes32[] vouchers;             //Voucher hashes are collected for each token owner
    }
    mapping (address => dGEowner) public dGEowners;

    /* Storage struct of vouchers */
    struct Voucher{
        bool isValid;                   //True if voucher exists and was redeemed yet
        uint8 voucherNumber;            //Each voucher has a number printed on for numerical order (and can be found in the token owner voucher array)
        uint reservationBlockHeight;    //Voucher is reserved for vendor up to block height (race attack protection)
        address vendor;                 //Vendor's address who claimed the voucher
        bytes32 hashedClaim;            //Unrevealed evidence that vendor knows the clear signature
    }
    mapping (bytes32 => Voucher) public vouchers;


    /**
     * @dev Step 0: Set initial passwords for token owner (by issuer)
     *
     * @param tokenOwner The recipient address of dGE token
     * @param hashedPassword The password hash that is generated via a call (see support function below)
     */
    function setOwnerPasswords(address tokenOwner, bytes32 hashedPassword) public returns(bool success) {
        require(tokenOwner != address(0x0), "tokenOwner was not set.");
        require(hashedPassword != "", "hashedPassword was not inserted.");

        dGEowners[tokenOwner].hashedPasswords = hashedPassword;

        return true;
    }

    /**
     * @dev Step 1: Store off-chain created vouchers/signatures on-chain (by issuer)
     *
     * @param hashedSignature The signature is kept secret by using its hash generated via a call (see support function below)
     */
    function createVoucher(address tokenOwner, uint8 voucherNumber, bytes32 hashedPassword, bytes32 hashedSignature) public returns(bool success) {
        require(tokenOwner != address(0x0), "tokenOwner was not set.");
        require(hashedSignature != "", "hashedSignature was not inserted.");

        dGEowners[tokenOwner].vouchers.push(hashedSignature);
        vouchers[hashedSignature].isValid = true;
        vouchers[hashedSignature].voucherNumber = voucherNumber;

        return true;
    }

    /**
     * @dev Step 2: Reserve voucher (by whitelisted vendor)
     *
     * @param tokenOwner The token owners address
     * @param voucherNumber Number of voucher that was created for this token owner
     * @param hashedPassword Vouchers are protected by password thats known by the token owner and can be hash via a call (see support function below)
     * @param hashedSignature The signature is kept secret by using its hash generated via a call (see support function below)
     * @param hashedClaim Unrevealed evidence that vendor knows the clear signature (see support function below)
     */
    function reservePaperVoucher(address tokenOwner, uint8 voucherNumber, bytes32 hashedSignature, bytes32 hashedPassword, bytes32 hashedClaim) public returns(bool success) {
        require(vouchers[hashedSignature].isValid == true, "Voucher does not exist or was  already redeemed!");

        require(hashedPassword == dGEowners[tokenOwner].hashedPassword, "Password is not correct!");
        require(voucherNumber > dGEowners[tokenOwner].lastVoucherNumber, "Voucher with higher number has already been used!");
        require(vouchers[hashedSignature].reservationBlockHeight < block.number, "Voucher still reserved!");

        //Mark the voucher as used for token owner
        dGEowners[tokenOwner].lastVoucherNumber = voucherNumber;

        //Mark vendor as pending

        //Perform reservation
        vouchers[hashedSignature].reservationBlockHeight = (block.number + reservationDurationBlocks);
        vouchers[hashedSignature].vendor = msg.sender;
        vouchers[hashedSignature].hashedClaim = hashedClaim;

        return true;
    }

    /**
     * @dev Step 3: Redeem voucher by revealing clear signature (by whitelisted vendor)
     *
     */
    function redeemPaperVoucher(address tokenOwner, uint8 voucherNumber, bytes memory clearSignature) public returns(bool success) {
        bytes32 messageHash = keccak256(abi.encodePacked(tokenOwner, voucherNumber, address(this)));
        address recoveredTokenOwnerAddress = recover(messageHash, clearSignature);

        bytes32 hashedSignature = createHashedSignature(clearSignature);
        require(vouchers[hashedSignature].isValid == true, "Voucher does not exist or was  already redeemed!");
        require(vouchers[hashedSignature].vendor == msg.sender, "Voucher was not reserved by sender!");

        //There should be no way to come this far without knowing the clearSignature and corresponding token owner address
        assert(vouchers[hashedSignature].hashedClaim == createHashedClaim(recoveredTokenOwnerAddress, clearSignature));

        //Optimistic accounting
        vouchers[hashedSignature].isValid = false;

        //Mark vendor as available
        //DO ACCOUNTING

        return true;
    }


    function testRecoverAddress(address tokenOwner, uint8 voucherNumber, bytes memory clearSignature) public view returns(address){

        //bytes32 messageHash = keccak256(abi.encodePacked(tokenOwner, voucherNumber, address(this)));
        bytes32 messageHash = keccak256(abi.encodePacked(tokenOwner, voucherNumber));
        address recoveredTokenOwnerAddress = recover(messageHash, clearSignature);

        return recoveredTokenOwnerAddress;
    }

    /**
     * @dev Support call functions to enable the contract functions
     */
    function createHashedPassword(address tokenOwner, string memory clearPassword) public view returns(bytes32 hashedPassword) {
        return keccak256(abi.encodePacked(tokenOwner, clearPassword));
        //return keccak256(abi.encodePacked(tokenOwner, clearPassword, address(this)));
    }

    function createHashedSignature(bytes memory clearSignature) public view returns(bytes32 hashedSignature) {
        return keccak256(abi.encodePacked(clearSignature));
        //return keccak256(abi.encodePacked(clearSignature, address(this)));
    }

    function createHashedClaim(address tokenOwner, bytes memory clearSignature) public view returns(bytes32 hashedClaim) {
        return keccak256(abi.encodePacked(tokenOwner, clearSignature, msg.sender));
        //return keccak256(abi.encodePacked(clearSignature, msg.sender, address(this)));
    }

    function recover(bytes32 hash, bytes memory signature) internal pure returns(address) {
        return hash.recover(signature);
    }
}