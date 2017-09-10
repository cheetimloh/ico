/**
 * This smart contract code is Copyright 2017 TokenMarket Ltd. For more information see https://tokenmarket.net
 *
 * Licensed under the Apache License, version 2.0: https://github.com/TokenMarketNet/ico/blob/master/LICENSE.txt
 */

pragma solidity ^0.4.6;

import "./Crowdsale.sol";
import "./CrowdsaleToken.sol";
import "zeppelin/contracts/math/SafeMath.sol";

/**
 * At the end of the successful crowdsale allocate % bonus of tokens to the team.
 *
 * Unlock tokens.
 *
 * BonusAllocationFinal must be set as the minting agent for the MintableToken.
 *
 */
contract BonusFinalizeAgent is FinalizeAgent {

  using SafeMath for uint;

  CrowdsaleToken public token;
  Crowdsale public crowdsale;

  /** Total percent of tokens minted to the team at the end of the sale as base points (0.0001) */
  uint public bonusBasePoints;

  /** Where we move the tokens at the end of the sale. */
  address public teamMultisig;

  /* How much bonus tokens we allocated */
  uint public allocatedBonus;

  /* Divisor of the base points */
  uint private constant basePointsDivisor = 10000;

  function BonusFinalizeAgent(CrowdsaleToken _token, Crowdsale _crowdsale, uint _bonusBasePoints, address _teamMultisig) {
    require(address(_crowdsale) != 0 && address(_teamMultisig) != 0);
    token = _token;
    crowdsale = _crowdsale;
    teamMultisig = _teamMultisig;
    bonusBasePoints = _bonusBasePoints;
  }

  /* Can we run finalize properly */
  function isSane() public constant returns (bool) {
    return (token.mintAgents(address(this)) == true) && (token.releaseAgent() == address(this));
  }

  /** Called once by crowdsale finalize() if the sale was success. */
  function finalizeCrowdsale() {
    require(msg.sender == address(crowdsale));

    // How many % of tokens the founders and others get
    uint tokensSold = crowdsale.tokensSold();
    allocatedBonus = tokensSold.mul(bonusBasePoints).div(basePointsDivisor);

    // move tokens to the team multisig wallet
    token.mint(teamMultisig, allocatedBonus);

    // Make token transferable
    token.releaseTokenTransfer();
  }

}
