// SPDX-License-Identifier: MIT
// Author: Atlas (atlas@cryptolink.tech)

pragma solidity ^0.8.9;

import "./ERC20Bridgeable.sol";

/**
 * @notice Example natively bridgeable ERC20 Token for use over TBaaS.
 * @author Atlas (atlas@cryptolink.tech)
 * 
 * All bridging functionality is handled inside the extension. This parent contract only needs to be 
 * concerned about the NFT itself and the minting to purchasers.
 * 
 * Deploying with 3 steps:
 *   - Modify and launch this contract on all desired chains, taking into account the _idStart constructor
 *   - Connect your wallet on https://tbaas.io dApp and enable this contract on every desired chain
 *   - Make sure contract has enough WETH for fees, or charges enough in WETH to bridgers
 * 
 */
contract ExampleBridgeToken is ERC20Bridgeable {
    constructor(address _tbaas) ERC20Bridgeable("Example ERC20Bridgeable Token", "EBT", _tbaas) {
        _mint(msg.sender, 100_000_000 * (10**18));
    }
}