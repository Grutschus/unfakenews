# unfakenews

## Description

This project introduce a way to validate news articles using Blockchain technology.
The Green Paper was written after completion of the seminar to formulate a hypothetical implementation in practice.

## Setup
Using VSCode is recommended. If you are using VSCode, you can start immediately by opening the project folder in VSCode, installing Remote Development extension, and launchin the devcontainer in this workspace.


## Class Diagram

```mermaid
classDiagram
    class Individual {
        address
    }

    class ERC20 {

    }

    class AccessControl {

    }

    class ERC721 {

    }

    class Governor {
        + call_vote(address news)
        + vote(address news, bool vote)
    }

    class ReputationToken {
        + bytes32 MINTER_ROLE // governor
        + bytes32 BURNER_ROLE // governor

        + mint(address to, uint256 amount)
        + burn(address from, uint256 amount)
    }

    class NewsNFT {
        + Counter _tokenIds
        + Address _creator
        + bytes32 ADMIN_ROLE // governor
    }

    ERC20 --|> ReputationToken
    ERC721 --|> NewsNFT
    AccessControl --|> NewsNFT
    AccessControl --|> ReputationToken
    Individual --> Governor : uses
    Individual --> NewsNFT : creates
    Governor --> NewsNFT: owns
    Governor --> ReputationToken: owns
    

```
