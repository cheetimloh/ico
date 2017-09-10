/**
 * This smart contract code is Copyright 2017 TokenMarket Ltd. For more information see https://tokenmarket.net
 *
 * Licensed under the Apache License, version 2.0: https://github.com/TokenMarketNet/ico/blob/master/LICENSE.txt
 */

import "zeppelin/contracts/ownership/Ownable.sol";
import "./ICOStandardToken.sol";

pragma solidity ^0.4.6;

/**
 * A token that can increase its supply by another contract.
 *
 * This allows uncapped crowdsale by dynamically increasing the supply when money pours in.
 * Only mint agents, contracts whitelisted by owner, can mint new tokens.
 *
 */
contract MintableToken is ICOStandardToken, Ownable {

  /* Token supply got increased and a new owner received these tokens */
  event Minted(address receiver, uint256 amount);

  bool public mintingFinished = false;

  /** List of agents that are allowed to create new tokens */
  mapping (address => bool) public mintAgents;

  event MintingAgentChanged(address addr, bool state  );

  function MintableToken(address _receiver, uint256 _initialSupply, bool _mintable) internal {
    require(_receiver != address(0));
    // Cannot create a token without supply and no minting
    require(_mintable || _initialSupply != 0);
    if (_initialSupply > 0) {
      mintInternal(_receiver, _initialSupply);
    }
    mintingFinished = !_mintable;
  }

  /**
   * Create new tokens and allocate them to an address..
   *
   * Only callably by a crowdsale contract (mint agent).
   */
  function mint(address receiver, uint amount) onlyMintAgent public {
    mintInternal(receiver, amount);
  }

  function mintInternal(address receiver, uint amount) canMint private {
    totalSupply = totalSupply.add(amount);
    balances[receiver] = balances[receiver].add(amount);

    Minted(receiver, amount);

    // This will make the mint transaction apper in EtherScan.io
    // We can remove this after there is a standardized minting event
    Transfer(0, receiver, amount);
  }

  /**
   * Owner can allow a crowdsale contract to mint new tokens.
   */
  function setMintAgent(address addr, bool state) onlyOwner canMint public {
    mintAgents[addr] = state;
    MintingAgentChanged(addr, state);
  }

  modifier onlyMintAgent() {
    // Only crowdsale contracts are allowed to mint new tokens
    require(mintAgents[msg.sender]);
    _;
  }

  /** Make sure we are not done yet. */
  modifier canMint() {
    require(!mintingFinished);
    _;
  }
}
