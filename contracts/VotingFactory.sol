// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./ClassVoting.sol";

contract VotingFactory {

    address[] private votingDApps;
    uint private noOfContract;

    mapping (uint => address) private eachApps;

    function createVotingContract(
        address _owner,
        address[] memory _candidates,
        string memory _electionType,
        uint256 _electionTime
        ) public {
        ClassVoting  _classVoting = new ClassVoting(_owner, _candidates, _electionType, _electionTime);

        uint256 num = noOfContract + 1;

        eachApps[num] = address(_classVoting);
        votingDApps.push(address(_classVoting));
        noOfContract = num;
    }
}