pragma solidity ^0.4.8;

import "zeppelin/contracts/math/SafeMath.sol";
import "../UpgradeableToken.sol";

/**
 * A sample token that is used as a migration testing target.
 *
 * This is not an actual token, but just a stub used in testing.
 */
contract TestMigrationTarget is ICOStandardToken, UpgradeAgent {

  using SafeMath for uint;

  UpgradeableToken public oldToken;

  uint public originalSupply;

  function TestMigrationTarget(UpgradeableToken _oldToken) {

    oldToken = _oldToken;

    // Let's not set bad old token
    require(address(oldToken) != 0);

    // Let's make sure we have something to migrate
    originalSupply = _oldToken.totalSupply();
    require(originalSupply != 0);
  }

  function upgradeFrom(address _from, uint256 _value) public {
    require(msg.sender == address(oldToken)); // only upgrade from oldToken

    // Mint new tokens to the migrator
    totalSupply = totalSupply.add(_value);
    balances[_from] = balances[_from].add(_value);
    Transfer(0, _from, _value);
  }

  function() public payable {
    require(false);
  }

}
