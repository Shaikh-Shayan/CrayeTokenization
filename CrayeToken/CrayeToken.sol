//SPDX-License-Identifier: MIT

pragma solidity >= 0.7.0 < 0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CrayeToken is ERC20 {
    constructor(uint256 _initialSupply) ERC20("Craye", "CRY"){
        _mint(msg.sender, _initialSupply);
    }

}
