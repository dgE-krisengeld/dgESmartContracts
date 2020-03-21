pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";

contract dgE is ERC20 {
    string public name;
    string public symbol;
    uint8 public decimals;

    uint256 public _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;

    constructor() public {
        name = "Dezentraler gemeinschaftsEuro";
        symbol = "dgE";
        decimals = 9;
    }
}

contract Whitelist {

  mapping(address => bool) whitelistBusinesses;
  mapping(address => bool) whiteListCitizens;
  private address controllerInstance;

  constructor() public {
    require(msg.sender == controllerInstance);

  }

  function addToBusinesses(address payable _newBusiness) {

  }

  function addToCirizens(address _newCitizen) {

  }


}

contract ControllerInstance {+


}
