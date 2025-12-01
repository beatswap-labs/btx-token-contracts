// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title TokenVestingLock
 * This contract allows BeatSwap payments to be split among a group of accounts.
 * The sender does not need to be aware that the BeatSwap tokens will be split in this way,
 * since it is handled transparently by the contract.
 * Additionally, this contract handles the vesting of BeatSwap tokens for a given payee and
 * release the tokens to the payee following a given vesting schedule.
 *
 * The split can be in equal parts or in any other arbitrary proportion.
 * The way this is specified is by assigning each account to a number of shares.
 * Of all the BeatSwap tokens that this contract receives, each account will then be able
 * to claim an amount proportional to the percentage of total shares they were assigned.
 * The distribution of shares is set at the time of contract deployment and can't be updated thereafter.
 * Additionally, any token transferred to this contract will follow the vesting schedule as if they were locked from the beginning.
 * Consequently, if the vesting has already started, any amount of tokens sent to this contract will (at least partly)
 * be immediately releasable.
 *
 * 'TokenVestingLock' follows a _pull payment_ model. This means that payments are not automatically forwarded to the
 * accounts but kept in this contract, and the actual transfer is triggered as a separate step by calling the {release} function.
*/

contract TokenVestingLock {
    using SafeERC20 for IERC20;
    IERC20 public immutable token;

    // Payee struct represents a participant who is eligible to receive tokens from a smart contract.
    struct Payee {
        address account;  // The address of the payee's Ethereum account
        uint256 shares;  // The corresponding list of shares (in percentage) that each payee is entitled to receive.
        uint256 tokensPerRoundPerPayee;  // The number of tokens the payee will receive per round of token distribution
        uint256 releaseTokens;  // The total number of tokens the payee is eligible to receive over the course of the contract
    }

    uint256 public immutable durationSeconds;  // The duration of the vesting period in seconds.
    uint256 public immutable intervalSeconds;  // The time interval between token releases in seconds.
    uint256 public immutable totalReleaseTokens;  // The total number of tokens to be released over the vesting period.
    uint256 public immutable startTime;  // The timestamp when the vesting period starts.
    uint256 public immutable totalRounds;  // The total number of token release rounds.
    uint256 public immutable totalAccounts;  // The total number of payees.
    uint256 public totalReleasedTokens;  // The total number of tokens already released.
    uint256 public totalFundedTokens;

    Payee[] public payees;  // An array of Payee structs representing the payees.
    mapping(address => uint256) public releasedAmount;  // A mapping of released token amounts for each payee address.

    constructor(
        IERC20 _token,
        uint256 _startDelay,
        uint256 _durationSeconds,
        uint256 _intervalSeconds,
        uint256 _totalReleaseTokens,
        address[] memory _accounts,
        uint256[] memory _shares
    ) {
        require(_accounts.length == _shares.length, "TokenVestingLock: accounts and shares length mismatch");
        require(_accounts.length > 0, "TokenVestingLock: no payees");

        for (uint256 i = 0; i < _accounts.length - 1; i++) {
            for (uint256 j = i + 1; j < _accounts.length; j++) {
                require(_accounts[i] != _accounts[j], "TokenVestingLock: duplicate addresses");
            }
        }

        uint256 totalShares = 0;
        for (uint256 i = 0; i < _shares.length; i++) {
            totalShares += _shares[i];
        }
        require(totalShares == 100, "Shares must sum up to 100");

        token = _token;
        durationSeconds = _durationSeconds;
        startTime = block.timestamp + _startDelay;
        intervalSeconds = _intervalSeconds;
        totalReleaseTokens = _totalReleaseTokens;
        totalRounds = durationSeconds / intervalSeconds;
        totalAccounts = _accounts.length;
        require(durationSeconds % intervalSeconds == 0, "error durationSeconds value");
        uint256 sumReleaseTokens = 0;    // Sum of releaseTokens across all payees

        for (uint256 i = 0; i < _accounts.length; i++) {
            uint256 tokensPerRoundPerBeneficiary =
                (totalReleaseTokens * _shares[i] * intervalSeconds) / durationSeconds / 100;
            uint256 releaseTokens = tokensPerRoundPerBeneficiary * totalRounds;
            sumReleaseTokens += releaseTokens;
            payees.push(Payee(_accounts[i], _shares[i], tokensPerRoundPerBeneficiary, releaseTokens));
        }
        // Ensure the sum of releaseTokens equals totalReleaseTokens to avoid rounding discrepancies
        require(sumReleaseTokens == totalReleaseTokens, "TokenVestingLock: invalid totalReleaseTokens");        
    }

    function fund(uint256 amount) external {
        require(amount > 0, "TokenVestingLock: amount is zero");
        totalFundedTokens += amount;
        require(totalFundedTokens <= totalReleaseTokens, "TokenVestingLock: overfunding");

        token.safeTransferFrom(msg.sender, address(this), amount);
        emit funded(msg.sender, amount);
    }

    function remainingToFund() external view returns (uint256) {
        if (totalFundedTokens >= totalReleaseTokens) {
            return 0;
        }
        return totalReleaseTokens - totalFundedTokens;
    }

    /**
     * Releases tokens to payees based on the vesting schedule.
     */
    function release() public {
        uint256 currentTime = block.timestamp;
        require(currentTime >= startTime, "Vesting not started yet");

        uint256 numIntervals = (currentTime - startTime) / intervalSeconds;
        uint256 totalVestedTokens = (totalReleaseTokens * numIntervals) / (durationSeconds / intervalSeconds);
        if (totalVestedTokens > totalReleaseTokens) {
            totalVestedTokens = totalReleaseTokens;
        }

        if (totalVestedTokens <= totalReleasedTokens) {
            revert("TokenVestingLock: no tokens to release");
        }
        uint256 totalReleasable = totalVestedTokens - totalReleasedTokens;

        // Single aggregate balance check; if insufficient, the whole release reverts
        uint256 contractBalance = token.balanceOf(address(this));
        require(totalReleasable <= contractBalance, "TokenVestingLock: insufficient balance for release");

        for (uint256 i = 0; i < payees.length; i++) {
            uint256 payeeShare = (payees[i].shares * totalVestedTokens) / 100;
            uint256 releasable = payeeShare - releasedAmount[payees[i].account];

            if (releasable > 0) {
                releasedAmount[payees[i].account] += releasable;
                totalReleasedTokens += releasable;
                token.safeTransfer(payees[i].account, releasable);
                emit released(payees[i].account, releasable);
            }
        }
    }

    function getPayee(address _account) public view returns (Payee memory) {
        for (uint256 i = 0; i < payees.length; i++) {
            if (payees[i].account == _account) {
                return payees[i];
            }
        }
        revert("missing account");
    }

    function releasedRounds() public view returns (uint256) {
        address account = payees[0].account;
        if (releasedAmount[account] == 0) {
            return 0;
        } else {
            return releasedAmount[account] / payees[0].tokensPerRoundPerPayee;
        }
    }

    function remainingRounds() public view returns (uint256) {
        if (startTime > block.timestamp) {
            return totalRounds;
        } else {
            if (block.timestamp >= startTime + durationSeconds) {
                return 0;
            } else {
                return 1 + (startTime + durationSeconds - block.timestamp) / intervalSeconds;
            }
        }
    }

    function remainingTokens() public view returns (uint256) {
        uint256 tokensPerRound = 0;
        uint256 remaining = totalRounds - releasedRounds();
        for (uint256 i = 0; i < payees.length; i++) {
            tokensPerRound += payees[i].tokensPerRoundPerPayee;
        }
        return tokensPerRound * remaining;
    }

    event released(address indexed account, uint256 amount);
    event funded(address indexed sender, uint256 amount);
}
