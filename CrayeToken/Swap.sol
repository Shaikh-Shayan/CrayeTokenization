//SPDX-License-Identifier: MIT

pragma solidity >= 0.7.0 < 0.9.0;

import "./CrayeToken.sol";
import "../WildCardTokenAirdrop.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Swap is Ownable {
  
  CrayeToken public crayeToken;
  WildCardTokenAirdrop public wildcardToken;
  address[] public AllowedCrypto;

  event TokenTransfered(
    address account,
    uint crayeTokens,
    uint rate,
    uint wildcardtokens
  );

  event PaymentDone(
    address account,
    uint256 amount,
    uint256 tokenId
  );

  constructor(CrayeToken _crayeToken, WildCardTokenAirdrop _wildcardToken) {
    crayeToken = _crayeToken;
    wildcardToken = _wildcardToken;
  }


  function addCurrency(address _payToken) public onlyOwner{
    AllowedCrypto.push(_payToken);
  }

  function buyToken(uint256 _amountInvested, uint256 _tokenId) public payable returns(bool){
    require(_tokenId< AllowedCrypto.length, "Sorry this payment method is not accepted");
    IERC20 payToken = IERC20(AllowedCrypto[_tokenId]);

    require(payToken.balanceOf(msg.sender)>= _amountInvested, "Insufficient funds!");

    payToken.transferFrom(msg.sender,address(this), _amountInvested);
    emit PaymentDone(msg.sender, _amountInvested, _tokenId);

    //price of a token is decided on the basis of amount invested
    uint256 tokenPrice;
    if(_amountInvested >= 1 * 1e18  && _amountInvested < 100 * 1e18 ){
      tokenPrice = 100;
    }else if(_amountInvested >= 100 * 1e18) {
      tokenPrice = 25;
    }else{
      //since the user cannot invest less than 10000
      return false;
    }

    uint256 numOfCryTokens = (_amountInvested * 100) / tokenPrice ; //amountInvested is multiplied by 100 because tokenPrice has 2 decimals
    uint256 numOfBonusTokens = (numOfCryTokens * 25) / 100; // 25%  of tokens received
    uint256 totalCrayeToken = numOfCryTokens + numOfBonusTokens; 

    uint256 numOfWildTokens = (_amountInvested * 2) / 1000; // 0.2% of amountInvested
    
    // Require that Contract has enough token allowance
    require(crayeToken.allowance(crayeToken.owner(), address(this)) >= totalCrayeToken, "Insufficient craye tokens allowance in the contract");
    require(wildcardToken.allowance(wildcardToken.owner(), address(this)) >= numOfWildTokens, "Insufficient wild card tokens allowance in the contract");
    
    // Transfer tokens to the user
    bool transferSuccess = crayeToken.transferFrom(crayeToken.owner(), msg.sender, totalCrayeToken);

    //airdrop function from WildCardTokenAirdrop smart contract called
    bool airdropSuccess = wildcardToken._singleAddressTransfer(msg.sender, numOfWildTokens);
    
    if(transferSuccess && airdropSuccess){
        emit TokenTransfered(msg.sender, totalCrayeToken, tokenPrice, numOfWildTokens);
        return true;
    }

    return false;
  } 

  //Only the owner can withdraw the funds deposited in the contract by investors
  function withdraw(uint256 _tokenId) public payable onlyOwner() {
    IERC20 payToken = IERC20(AllowedCrypto[_tokenId]);
    payToken.transfer(msg.sender, payToken.balanceOf(address(this)));
  }

}
