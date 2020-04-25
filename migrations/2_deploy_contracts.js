const dGE = artifacts.require("dGE");
// const OWNABLE = artifacts.require("Ownable");
// const WHITELIST = artifacts.require("Whitelist");

module.exports = function(deployer) {
  deployer.deploy(dGE);
  // deployer.deploy(OWNABLE);
  // deployer.deploy(WHITELIST);
};