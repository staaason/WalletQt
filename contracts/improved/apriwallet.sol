//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.7;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./ApritokenRegistry.sol";

contract ApriWallet {

    using SafeMath for uint256;

    ApriToken private _tokenRegistry;
    
    address private _admin;
    uint256 private _transactionsPerHour;
    uint256 private _exchangeRate;

    mapping(address => uint256) _nonces;
    mapping(address => uint256[]) _transactionTimestamps;

    constructor(uint256 totalSupply_, uint256 transactionsPerHour_, uint256 exchangeRate_) {
        _admin = msg.sender;
        _tokenRegistry = new ApriToken(totalSupply_, _admin);
        _transactionsPerHour = transactionsPerHour_;
        _exchangeRate = exchangeRate_;
    }

    function sendTokens (
        address from, 
        address to, 
        uint256 value, 
        uint256 deadline,
        uint8 v, 
        bytes32 r, 
        bytes32 s
    ) public returns (bool success){
        require(msg.sender == _admin, "Access denied.");
        require(from != to, "This has no sense.");
        //require(from != _admin && getTransactionsPastHour(from) < _transactionsPerHour, "Sorry, try again in an hour.");
        bytes32 hash = _tokenRegistry.getDigest(from, to, value, deadline);
        address signer = ecrecover(hash, v, r, s);
        require(signer == from, "Invalid signature.");

        bool allowanceSuccessful = _tokenRegistry.permit(from, to, value, deadline, v, r, s);
        require(allowanceSuccessful == true, "Allowance failed.");

        bool transferSuccessful = _tokenRegistry.transferFrom(from, to, value);
        require(transferSuccessful == true, "Transfer failed.");

        if(from != _admin) {
            addNewTransactionTimestamp(from, block.timestamp);
        }
        
        return true;
    }

    function buyTokens(uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public payable returns (bool success) {
        address buyer = msg.sender;
        require(buyer != _admin, "This has no sense.");
        require(getTransactionsPastHour(buyer) < _transactionsPerHour, "Sorry, try again in an hour.");
        require(msg.value == amount.mul(_exchangeRate), "Insufficient amount of ETH.");

        bool allowanceSuccessful = _tokenRegistry.permit(_admin, buyer, amount, deadline, v, r, s);
        require(allowanceSuccessful == true, "Allowance failed.");

        bool transferSuccessful = _tokenRegistry.transferFrom(_admin, buyer, amount);
        require(transferSuccessful == true, "Transfer failed.");

        
        addNewTransactionTimestamp(buyer, block.timestamp);
        
        return true;
    }

    function sellTokens(address payable seller, uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public returns (bool success) {
        require(msg.sender == _admin, "Access denied.");
        require(seller != _admin, "This has no sense.");
        require(getTransactionsPastHour(seller) < _transactionsPerHour, "Sorry, try again in an hour.");

        bool allowanceSuccessful = _tokenRegistry.permit(seller, _admin, amount, deadline, v, r, s);
        require(allowanceSuccessful == true, "Allowance failed.");

        bool transferSuccessful = _tokenRegistry.transferFrom(_admin, seller, amount);
        require(transferSuccessful == true, "Transfer failed.");

        bool etherSent = seller.send(amount.mul(_exchangeRate));
        require(etherSent == true, "ETH transfer failed.");

        addNewTransactionTimestamp(seller, block.timestamp);
        return true;
    }

    function balanceOf(address user) public view returns (uint256 balance) {
        return _tokenRegistry.balanceOf(user);
    }

    function nonceOf(address user) public view returns(uint256 nonce) {
        return _tokenRegistry.nonces(user);
    } 

    function getExchangeRate() public view returns (uint256 rate) {
        return _exchangeRate;
    }

    function setExchangeRate(uint256 rate) public returns(bool success) {
        require(msg.sender == _admin, "Access denied.");
        _exchangeRate = rate;
        return success;
    }

    function getPermitTypehash() public view returns(bytes32 hash) {
        return _tokenRegistry.getPermitTypehash();
    }

    function getDomainSeparator() public view returns (bytes32 hash) {
        return _tokenRegistry.getDomainSeparator();
    }

    function getTransactionsPastHour(address user) private view returns(uint256 count) {
        uint256 hourAgo = block.timestamp - 3600;
        uint256[] memory userTimestamps = _transactionTimestamps[user];
        uint256 result = 0;
        for(uint i = 0; i<userTimestamps.length; i++) {
            if(userTimestamps[i] >= hourAgo) {
                result++;
            }
        }
        return result;
    }
    
    function getLastTransactions(address user) public view returns (uint256[] memory array) {
        return _transactionTimestamps[user];
    }

    function setLastTransactions(address user, uint256[] calldata array) public {
        require(msg.sender == _admin, "Access denied.");
        _transactionTimestamps[user] = array;
    }

    function addNewTransactionTimestamp(address user, uint256 timestamp) private {
        _transactionTimestamps[user].push(timestamp);
    }

}
