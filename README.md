# ERC20 Natively Bridgeable Token


## Overview

By using the ERC20Bridgeable token extension, a project can enable their token to be fully and natively cross chain just as easily as launching a standard non-bridgeable token. Developers are still free to add in their own tokenomics and features. 


## Security

We use multiple layers of security to ensure that messages being delivered are truely correct and validated by multiple sources, including by leveraging our decentralized transaction mining pools run by the community. 

The ERC20Bridgeable extension contract has been designed to be as lightweight as possible, easily auditable, with no hidden or complicated mechanisms. 

Projects/Developers have the ability to run validation miners themselves, and require that a minimum number of their own validators that they control _also_ approve the transaction. This prevents the Bridge from the possibility of creating invalid transaction messages, and failure of all of our community miners and industry validators, as they will be immediately rejected by the Project validators. Projects are not required to run their own validators as we have many layers of security that must pass before a transaction is approved, but does add an extra layer of peace of mind if desired.


## TBaaS Project Setup
- Modify and deploy the Example Bridgeable Token contract.
- Connect your Wallet to https://tbaas.io dApp assign contract to your Wallet address.
- (optional) Select security parameter overrides.
- (optional) Enable Project miners.
- (Repeat for every desired chain)


## Implementation

Implementation of the ERC20Bridgeable token extension is no different than using the standard ERC20 extension. There has only been one addition on the implementing contract side, which is the requirement to add in the address of the TBaaS bridge in the constructor when deploying.

```c
contract ExampleBridgeToken is ERC20Bridgeable {
    constructor(address _tbaas) ERC20Bridgeable("Example ERC20Bridgeable Token", "EBT", _tbaas) {
        _mint(msg.sender, 100_000_000 * (10**18));
    }
}
```

THATS IT!
