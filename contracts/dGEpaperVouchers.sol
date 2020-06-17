pragma solidity >=0.6.0 <0.7.0;

import "./openzeppelin/Ownable.sol";
import "./openzeppelin/Pausable.sol";
import "./openzeppelin/ECDSA.sol";
import "./openzeppelin/ERC20.sol";

/**
 * @title dGEpaperVouchers
 *  dGE- "digitaler Gutschein-Euro"
 *  A blockchain-based voucher system to help citizens to help their local SME
 */
abstract contract dGEpaperVouchers is ERC20, Ownable, Pausable {
    using ECDSA for bytes32;

    /* Time in blocks the voucher is reserved by vendor until it can be reclaimed (preconfigured: ~1h) */
    uint private reservationDurationBlocks = 260;

    /* Storage struct of vouchers */
    struct Voucher{
        bool isValid;                   //True if voucher exists and was redeemed yet
        uint256 reservationBlockHeight; //Voucher is reserved for vendor up to block height (race attack protection)
        bytes32 hashedClaim;            //Unrevealed evidence that vendor knows the clear signature
    }
    mapping (bytes32 => Voucher) public vouchers;

    /* Mapping vendors for reedeming vouchers */
    mapping(address => bool) public pendingRedemption;    //allow only one redemption at a time

    /* Events */
    event LogPaperVoucherCreated(address indexed issuer, bytes32 indexed hashedSignature);
    event LogPaperVoucherReserved(address indexed vendor, bytes32 indexed hashedSignature, bytes32 hashedClaim, uint256 reservationBlockHeight);
    event LogPaperVoucherRedeemed(address indexed vendor, address indexed recoveredTokenOwnerAddress, bytes32 indexed hashedSignature, uint256 amount);

    /**
     * @dev Step 1: Store off-chain created vouchers/signatures on-chain (by issuer)
     *
     * @param hashedSignature The signature is kept secret by using its hash generated via a call (see support function below)
     */
    function createPaperVoucher(bytes32 hashedSignature) public virtual onlyOwner returns(bool success) {
        require(hashedSignature != "", "hashedSignature was not inserted.");

        vouchers[hashedSignature].isValid = true;

        emit LogPaperVoucherCreated(msg.sender, hashedSignature);
        return true;
    }

    /**
     * @dev Step 2: Reserve voucher
     *
     * @param hashedSignature The signature is kept secret by using its hash generated via a call (see support function below)
     * @param hashedClaim Unrevealed evidence that vendor knows the clear signature (see support function below)
     */
    function reservePaperVoucher(bytes32 hashedSignature, bytes32 hashedClaim) public virtual whenNotPaused returns(bool success) {
        require(hashedSignature != "", "hashedSignature was not inserted.");
        require(hashedClaim != "", "hashedClaim was not inserted.");

        require(pendingRedemption[msg.sender] == false, "Vendor has already a pending redemption!");
        require(vouchers[hashedSignature].isValid == true, "Voucher does not exist or was  already redeemed!");
        require(vouchers[hashedSignature].reservationBlockHeight < block.number, "Voucher still reserved!");

        pendingRedemption[msg.sender] = true;

        uint256 reservationBlockHeight = block.number + reservationDurationBlocks;
        vouchers[hashedSignature].reservationBlockHeight = reservationBlockHeight;
        vouchers[hashedSignature].hashedClaim = hashedClaim;

        emit LogPaperVoucherReserved(msg.sender, hashedSignature, hashedClaim, reservationBlockHeight);
        return true;
    }

    /**
     * @dev Step 3: Redeem voucher by revealing clear signature
     *
     * @param tokenOwner The address of the token owner
     * @param voucherNumber The numerical order of the voucher
     * @param clearSignature The clear signature implying access to the voucher
     */
    function redeemPaperVoucher(address tokenOwner, uint8 voucherNumber, bytes memory clearSignature, uint256 amount) public virtual whenNotPaused returns(bool success) {
        bytes32 messageHash = keccak256(abi.encodePacked(tokenOwner, voucherNumber, address(this)));
        address recoveredTokenOwnerAddress = recover(messageHash, clearSignature);
        require(tokenOwner == recoveredTokenOwnerAddress, "Given tokenOwner and clearSignature mismatch!");

        bytes32 hashedSignature = createHashedSignature(clearSignature);
        require(vouchers[hashedSignature].isValid == true, "Voucher does not exist or was  already redeemed!");
        require(vouchers[hashedSignature].hashedClaim == createHashedClaim(clearSignature), "Reservation and claim are not consistent.");

        vouchers[hashedSignature].isValid = false;

        this.transferByPaperVoucher(recoveredTokenOwnerAddress, msg.sender, amount);

        pendingRedemption[msg.sender] = false;

        emit LogPaperVoucherRedeemed(msg.sender, recoveredTokenOwnerAddress, hashedSignature, amount);
        return true;
    }

    /**
     * @dev dGEs are transferred by contract to the vendor's address
     *
     * @param sender The address of the vendor
     * @param recipient The address of the dGE spender
     * @param amount The amout of dGEs to be transferred
     */
    function transferByPaperVoucher(address sender, address recipient, uint256 amount) external virtual whenNotPaused returns(bool success){
        require(msg.sender == address(this), "Only the contract itself is allowed to invoke this function!");

        ERC20.transferFrom(sender, recipient, amount);

        return true;
    }

    /**
     * @dev Support call functions to enable the contract functions
     */
    function createHashedSignature(bytes memory clearSignature) public view returns(bytes32 hashedSignature) {
        return keccak256(abi.encodePacked(clearSignature, address(this)));
    }

    function createHashedClaim(bytes memory clearSignature) public view returns(bytes32 hashedClaim) {
        return keccak256(abi.encodePacked(clearSignature, msg.sender, address(this)));
    }

    function changeReservationDuration(uint newDurationBlocks) public virtual onlyOwner returns(bool success){
        reservationDurationBlocks = newDurationBlocks;
        return true;
    }

    function recover(bytes32 hash, bytes memory signature) internal pure returns(address) {
        return hash.recover(signature);
    }
}