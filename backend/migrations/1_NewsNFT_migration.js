var newsNFT_contract = artifacts.require("NewsNFT");

module.exports = function (deployer) {
    deployer.deploy(newsNFT_contract);
}
