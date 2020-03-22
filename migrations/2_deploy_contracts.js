const DGE = artifacts.require("dgE");
const OWNABLE = artifacts.require("Ownable");
const WHITELIST = artifacts.require("Whitelist");

module.exports = function(deployer) {
  deployer.deploy(DGE);
  deployer.deploy(OWNABLE);
  deployer.deploy(WHITELIST); 
};
