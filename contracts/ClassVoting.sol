// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

    error IT_IS_NOT_A_VALID_ID();
    error ADDRESS_ZERO_NOT_ALLOWED();
    error YOU_HAVE_VOTED();
    error ELECTION_IS_YET_TO_COMMENCE();
    error ONLY_OWNER();

contract ClassVoting {

    address private owner;

    address[] public candidates;
    AllCandidate[] public allCandidates;
    uint256 public  totalVotes;
    string public  electionType;
    uint256 public electionTime;

    mapping(uint256 => address) private eachCandidates;
    mapping(address => uint256) private candidateId;
    mapping(address => uint256) private voteCount;
    mapping(address => bool) private hasVoted;

    struct AllCandidate {
        address candidate;
        uint256 voteCount;
    }

    event Voted(address voter, address candidate, uint256 candidateId);

    constructor(address _owner, address[] memory _candidates, string memory _electionType, uint256 _electionTime) {
        owner = _owner;
        electionType = _electionType;
        //this is not the best practice
        electionTime = _electionTime + block.timestamp;

        /*instead of running the loop everytime a voter wants to vote
           the loop run once and add the candidates to a map*/
        for (uint16 i = 0; i < _candidates.length; i++) {
            if (_candidates[i] == address(0)) continue;
            uint id = i + 1;
            eachCandidates[id] = _candidates[i];
            candidateId[_candidates[i]] = id;
        }
    }

    function getCandidateId(address _candidate) external view returns (uint256 id){
        id = candidateId[_candidate];
    }

    function vote(uint256 _candidateId) external {
        if (electionTime > block.timestamp) revert ELECTION_IS_YET_TO_COMMENCE();
        if (_candidateId <= 0) revert IT_IS_NOT_A_VALID_ID();
        if (msg.sender == address(0)) revert ADDRESS_ZERO_NOT_ALLOWED();
        if (hasVoted[msg.sender]) revert YOU_HAVE_VOTED();

        hasVoted[msg.sender] = true;
        address _cand = eachCandidates[_candidateId];
        voteCount[_cand] = voteCount[_cand] + 1;
        totalVotes = totalVotes + 1;

        emit Voted(msg.sender, _cand, _candidateId);
    }


    function calculateSCore() external returns (address _cand, uint _max){
        if (msg.sender != owner) revert ONLY_OWNER();

        for (uint256 i = 0; i < candidates.length; i++) {
            address _eachCandidate = candidates[i];
            uint256 _voteScore = voteCount[_eachCandidate];


            allCandidates.push(AllCandidate(_eachCandidate, _voteScore));

            if (_voteScore > _max) {
                _max = _voteScore;
                _cand = _eachCandidate;
            }
        }
        return (_cand, _max);
    }

    function getAllResults() external view returns (AllCandidate[] memory) {

        return allCandidates;
    }
}

// ["0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2", "0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db", "0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB", "0x617F2E2fD72FD9D5503197092aC168c91465E7f2"]