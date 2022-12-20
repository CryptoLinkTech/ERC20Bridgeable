// Author: Atlas (atlas@cryptolink.tech)

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

interface ITBaaS {
    function sourceChainRequestTokenBridge(uint toChainId, address recipient, uint amount) external returns(uint txId);
    function sourceChainRequestNFTBridge(uint toChainId, address recipient, uint nftId, string calldata tokenURI) external returns(uint txId);
    function isDestinationChainEnabledForProject(address project, uint chainId) external view returns (bool enabled);
    function getPaymentToken(address project) external view returns(address paymentToken);
    function getRequestFee(uint destChainId, address project) external view returns (uint feeAmount);
    function pay(uint paymentamount) external returns (bool paid);
    function getCurrentAddress() external view returns(address tbaas);
}

/**
 * @title Base class for creating natively bridgeable ERC20 tokens
 * @author Atlas (atlas@cryptolink.tech)
 * 
 * Overview:
 *   This extention enables developers to create a cross chain native bridgeable ERC20 token. All
 *   required functionality is included in this extension, and does not require any additional code
 *   on the parent contract. Developers are free to design their token as they wish. 
 * 
 * Security:
 *   This extension provides two new functions, bridgeRequest() and bridgeProcess().
 * 
 *   bridgeRequest() is public, anyone can have their tokens burned in exchange for a valid
 *   bridge request event. The bridge handels delivery on the desination chain by calling 
 *   the bridgeProcess() function on the destination chain contract.
 *   
 *   bridgeProcess() is restricted to calls only from the Bridge. We can rely on only valid messages
 *   reaching this function. All calls coming from the bridge have ran through all the layers of
 *   security and have been found to pass. The security of this message is auditable by viewing the
 *   corresponding function in the bridge code.
 * 
 *   TBAAS Address is updated automatically by the Bridge for upgrades. TBAAS is only able to upgrade
 *   the address when deploying revisions and only during a secure timeout-period and events are sent
 *   to prevent mallicious actions to allow inspection of the change before becoming active.
 * 
 */
contract ERC20Bridgeable is ERC20, ERC20Burnable {
    address private TBAAS;

    event BridgeProcess(uint txId, uint sourceChainId, address recipient, uint tokenAmount, uint gasAmount);
    event BridgeRequest(uint toChainId, address recipient, uint amount);

    /**
     * @param _tbaas Address of the TBaaS contract
     */
    constructor(string memory _name, string memory _symbol, address _tbaas) ERC20(_name, _symbol) {
        TBAAS = _tbaas;
    }

    /**
     * @param _toChainId ID of the destination chain
     * @param _recipient Address of the recipient
     * @param _amount Amount of tokens to send
     */
    function bridgeRequest(uint _toChainId, address _recipient, uint _amount) external {
        // make sure that the project has enabled the destination chain, and that the destination
        // chain is working correctly and active before attempting the bridge request.
        require(ITBaaS(TBAAS).isDestinationChainEnabledForProject(address(this), _toChainId) == true, "ERC20Bridgeable: destination chain not enabled for project");

        // handle TBaaS upgrades
        if(ITBaaS(TBAAS).getCurrentAddress() != address(TBAAS)) TBAAS = ITBaaS(TBAAS).getCurrentAddress();

        // transfer tokens from the sender from this source chain and burn them
        transferFrom(msg.sender, address(this), _amount);
        burnFrom(address(this), _amount);

        // notify the bridge that the tokens have been burned and request delivery
        // which runs bridgeProcess() in this contract on the destination chain
        ITBaaS(TBAAS).sourceChainRequestTokenBridge(_toChainId, _recipient, _amount);

        emit BridgeRequest(_toChainId, _recipient, _amount);
    }

    /**
     * @dev This must only be ran by TBAAS as the checks are all done upstream
     * @dev Parent contract should make sure available WETH exists in contract to pay gas
     */
    function bridgeProcess(uint _txId, uint _sourceChainId, address _recipient, uint _tokenAmount, uint _paymentRequired) internal {
        // we restrict this function only to accept messages from TBAAS as we can be sure that the
        // message has been validated correctly on all layers when delivered directly from TBAAS
        require(msg.sender == address(TBAAS), "ERC20Bridgeable: not authorized");

        // mint tokens to the recipient
        _mint(_recipient, _tokenAmount);

        if(_paymentRequired > 0) {
            // if the required minimum payment is not sent, the entire transaction will be reverted
            IERC20(ITBaaS(TBAAS).getPaymentToken(address(this))).approve(address(TBAAS), _paymentRequired);
            ITBaaS(TBAAS).pay(_paymentRequired);
        }

        emit BridgeProcess(_txId, _sourceChainId, _recipient, _tokenAmount, _paymentRequired);
    }
}