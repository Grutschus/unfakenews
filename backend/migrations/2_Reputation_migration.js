var reputation_contract = artifacts.require("Reputation");

module.exports = function (deployer) {
    deployer.deploy(reputation_contract);
}
