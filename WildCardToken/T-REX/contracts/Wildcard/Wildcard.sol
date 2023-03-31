// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '../token/Token.sol';

contract Wildcard is ERC20, ERC20Burnable, Ownable {
    // event logs for failed and successful Airdrops
    event failedAirdrop(address, uint256);
    event successfulAirdrop(address, uint256);
    event successfulTransfer(address, uint256);
    event propertTokenClaim(address, uint256);

    address private propertyToken;
    address private propertyTokensOwner;

    function setAddress(address _token) external {
        propertyToken = _token;
    }

    // deploying the contract by giving the token a name, a symbol,
    // and minting an initial amount to the owner's wallet
    constructor(
        uint256 _initialSupply,
        address _propertyTokensOwner,
        address _token
    ) ERC20('WildCard', 'WCD') {
        propertyToken = _token;
        _mint(msg.sender, _initialSupply);
        propertyTokensOwner = _propertyTokensOwner;
    }

    function claimPropertyTokens(uint256 _noOfPropertyTokens) external returns (bool) {
        //check if the user has the required number of Wild Card tokens or not
        require(balanceOf(msg.sender) >= _noOfPropertyTokens, 'Wild Card Tokens Insufficient!');
        //create an instance of Property Tokens SC
        Token property = Token(propertyToken);
        //burn the equivalent number of Wild Card tokens
        wildCardBurn(msg.sender, _noOfPropertyTokens);
        //transfer the Property Tokens
        bool success = property.transferFrom(propertyTokensOwner, msg.sender, _noOfPropertyTokens);
        emit propertTokenClaim(msg.sender, _noOfPropertyTokens);
        return success;
    }

    // function to mint more tokens when owner is out of balance
    function mint(uint256 _amount) public onlyOwner {
        _mint(msg.sender, _amount);
    }

    // function to airdrop a certain amount of tokens to an address

    function _singleAddressTransfer(address _address, uint256 _amount) public returns (bool) {
        uint256 totalAvailable = balanceOf(msg.sender);
        require(
            // total balance of owner's wallet must suffice
            // the required amount of tokens for the transfer
            totalAvailable >= _amount,
            'Transfer amount exceeds 100% of Available Tokens!'
        );
        transfer(_address, _amount);
        emit successfulTransfer(_address, _amount);
        return true;
    }

    // function to airdrop a certain amount of tokens to each address of an array

    function _airdrop(address[] calldata _addresses, uint256 _amount)
        public
        returns (
            /*onlyOwner*/
            bool
        )
    {
        // total required amount of tokens for a successful airdrop =
        // number of addresses * amount to be airdropped per address
        uint256 totalRequired = _addresses.length * _amount;
        uint256 totalAvailable = balanceOf(msg.sender);

        require(
            // total balance of owner's wallet must suffice
            // the required amount of tokens for the airdrop
            totalAvailable >= totalRequired,
            'Airdrop amount exceeds 100% of Available Tokens!'
        );

        // transferring the given amount of tokens to all the addresses
        for (uint256 i = 0; i < _addresses.length; i++) {
            // checking if a given address is valid/invalid
            if (_addresses[i] != address(0)) {
                // transferring the given amount of tokens to target address
                // transferFrom(msg.sender, _addresses[i], _amount);
                transfer(_addresses[i], _amount);

                // event log on successful airdrop
                emit successfulAirdrop(_addresses[i], _amount);
            }
            // event log on failed airdrop
            else emit failedAirdrop(_addresses[i], _amount);
        }

        // message at successful completion of airdrop
        return true;
    }

    function wildCardBurn(
        //takes address to burn from
        address _buyerAddress,
        //takes number of property tokens claimed
        uint256 _noOfPropertyTokens
    ) public {
        //check for valid inputs
        require(_noOfPropertyTokens != 0, 'Number < 0');
        require(_buyerAddress != address(0), 'Invalid Address');
        //burn the given number of tokens
        _burn(_buyerAddress, _noOfPropertyTokens);
    }
}
