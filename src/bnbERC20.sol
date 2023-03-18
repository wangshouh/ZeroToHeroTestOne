// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "solmate/tokens/ERC20.sol";

contract BnBCoin is ERC20 {
	uint256 public constant MAX_SUPPLY = 1_000_000 ether;

	constructor (
		string memory _name,
		string memory _symbol,
		uint8 _decimals
	) ERC20 (_name, _symbol, _decimals) {
		_mint(msg.sender, MAX_SUPPLY);
	}
}