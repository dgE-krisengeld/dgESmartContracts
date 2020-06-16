pragma solidity >=0.4.21 <0.7.0;

import "./openzeppelin/Ownable.sol";

/**
 * @title Allowlist
 * @dev The Allowlist contract has a allowlist of addresses, and provides basic authorization control functions.
 * @dev This simplifies the implementation of "user permissions".
 */
contract Allowlist is Ownable {

  mapping(address => bool) internal allowlist;


  event AllowlistedAddressAdded(address addr);
  event AllowlistedAddressRemoved(address addr);

  /**
   * @dev Throws if called by any account that's not allowlisted.
   */
  modifier onlyAllowlisted() {
    require(allowlist[msg.sender], "The sender is not allowlisted");
    _;
  }


  /**
   * @dev add an address to the allowlist
   * @param addr address
   * @return success true if the address was added to the allowlist, false if the address was already in the allowlist
   */
  function addAddressToAllowlist(address addr) public onlyOwner returns(bool success) {
    if (!allowlist[addr]) {
      allowlist[addr] = true;
      emit AllowlistedAddressAdded(addr);
      return true;
    }
  }

  /**
   * @dev add addresses to the allowlist
   * @param addrs addresses
   * @return success true if at least one address was added to the allowlist,
   * false if all addresses were already in the allowlist
   */
  function addAddressesToAllowlist(address[] memory addrs) public onlyOwner returns(bool success) {
    for (uint256 i = 0; i < addrs.length; i++) {
      if (addAddressToAllowlist(addrs[i])) {
        success = true;
      }
    }
  }

  /**
   * @dev remove an address from the allowlist
   * @param addr address
   * @return success true if the address was removed from the allowlist,
   * false if the address wasn't in the allowlist in the first place
   */
  function removeAddressFromAllowlist(address addr) public onlyOwner returns(bool success) {
    if (allowlist[addr]) {
      allowlist[addr] = false;
      emit AllowlistedAddressRemoved(addr);
      return true;
    }
  }

  /**
   * @dev remove addresses from the allowlist
   * @param addrs addresses
   * @return success true if at least one address was removed from the allowlist,
   * false if all addresses weren't in the allowlist in the first place
   */
  function removeAddressesFromAllowlist(address[] memory addrs) public onlyOwner returns(bool success) {
    for (uint256 i = 0; i < addrs.length; i++) {
      if (removeAddressFromAllowlist(addrs[i])) {
        return true;
      }
    }
  }

  function isAllowlisted(address addr) public view returns(bool){
    return allowlist[addr];
  }
}