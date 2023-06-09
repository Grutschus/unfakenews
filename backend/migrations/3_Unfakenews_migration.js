var unfakenews_contract = artifacts.require("Unfakenews");
var reputation_contract = artifacts.require("Reputation");

module.exports = function (deployer) {
    deployer.deploy(unfakenews_contract, reputation_contract.address);
}
