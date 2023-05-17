var mintNFT_Contract = artifacts.require("mintNFT");

module.exports = function (deployer) {
    deployer.deploy(mintNFT_Contract);
}
