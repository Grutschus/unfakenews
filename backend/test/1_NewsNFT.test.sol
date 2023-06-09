// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/NewsNFT.sol";
import "./NewsNFTOwner.sol";

contract TestNewsNFT {
    NewsNFT newsNFT;
    NewsNFTOwner owner1;
    NewsNFTOwner owner2;
    address add_owner1;
    address add_owner2;

    function beforeEach() public {
        newsNFT = NewsNFT(DeployedAddresses.NewsNFT());
        owner1 = new NewsNFTOwner(newsNFT);
        add_owner1 = address(owner1);
        owner2 = new NewsNFTOwner(newsNFT);
        add_owner2 = address(owner2);
    }

    /**
     * Anyone can read the VerificationState of a NewsNFT.
     * Default must be Unverified.
     */
    function testDefaultVerificationState() public {
        uint256 tokenID = owner1.tokenID();

        uint256 expected = uint256(NewsNFT.VerificationState.Unverified);
        uint256 actual = uint256(newsNFT.getVerificationState(tokenID));
        Assert.equal(
            expected,
            actual,
            "NewsNFT should be unverified by default"
        );
    }

    // function testSetVerificationState() public {
    //     NewsNFT newsNFT = new NewsNFT();
    //     newsNFT.setVerificationState(true);
    //     Assert.equal(
    //         newsNFT.getVerificationState(),
    //         true,
    //         "NewsNFT should be verified"
    //     );
    // }

    // // write a test to check that the verification state of a
    // // NewsNFT can be set to 0 (unverified)
    // function testUnsetVerificationState() public {
    //     NewsNFT newsNFT = new NewsNFT();
    //     newsNFT.setVerificationState(false);
    //     Assert.equal(
    //         newsNFT.getVerificationState(),
    //         false,
    //         "NewsNFT should be unverified"
    //     );
    // }

    // // write a test to check that the verification state of a
    // // NewsNFT can be set to 1 (verified)
    // function testSetVerificationStateWithAddress() public {
    //     NewsNFT newsNFT = new NewsNFT();
    //     newsNFT.setVerificationStateWithAddress(address(this), true);
    //     Assert.equal(
    //         newsNFT.getVerificationStateWithAddress(address(this)),
    //         true,
    //         "NewsNFT should be verified"
    //     );
    // }

    // // write a test to check that the verification state of a
    // // NewsNFT can be set to 0 (unverified)
    // function testUnsetVerificationStateWithAddress() public {
    //     NewsNFT newsNFT = new NewsNFT();
    //     newsNFT.setVerificationStateWithAddress(address(this), false);
    //     Assert.equal(
    //         newsNFT.getVerificationStateWithAddress(address(this)),
    //         false,
    //         "NewsNFT should be unverified"
    //     );
    // }
}
