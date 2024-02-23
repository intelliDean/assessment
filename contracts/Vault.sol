// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

error ADDRESS_ZERO_NOT_ALLOWED();
error ONLY_OWNER_ALLOWED();
error CANNOT_SEND_ZERO();
error TIME_IS_IN_THE_PAST();
error YOU_DO_NOT_QUALIFY();
error NOT_YET_TIME();


contract Vault {

    address private owner;
    uint256 private linkCount;

    struct Grant {
        address giver;
        address beneficiary;
        uint256 amount;
        uint256 time;
    }

    mapping (uint256 => Grant) private grants;
    mapping(address => mapping (address => uint256)) private links;

    constructor () {
        owner = msg.sender;
    }

    function viewGrant(address _ben, address _giv)  external view returns(Grant memory) {
        return grants[links[_ben][_giv]];
    }

    function createGrant(address _beneficiary, uint _time) external payable {
        if (msg.value <= 0) revert CANNOT_SEND_ZERO();
        if (_beneficiary == address(0) || msg.sender == address(0)) revert ADDRESS_ZERO_NOT_ALLOWED();
        //in real life scenario, the time will be handled differently
        uint _grantTime = _time + block.timestamp;
        if ((_grantTime) < block.timestamp) revert TIME_IS_IN_THE_PAST();

        uint _link = linkCount + 1;
        links[_beneficiary][msg.sender] = _link;

        payable (address(this)).transfer(msg.value);

        Grant storage _grant = grants[_link];
        _grant.giver = msg.sender;
        _grant.beneficiary = _beneficiary;
        _grant.amount = msg.value;
        _grant.time = _grantTime;


        linkCount = linkCount + 1;
    }

    function claimGrant(address _giver) external  {
        uint256 _link = links[msg.sender][_giver];
        if (_link > 0) {
               Grant storage _grant = grants[_link];
             if (_grant.time > block.timestamp) {
                uint newAmount = _grant.amount ;
                  _grant.amount = 0;
                  _grant.time = 0;
                   links[msg.sender][_giver] = 0;
             payable (_grant.beneficiary).transfer(newAmount);
            } revert NOT_YET_TIME();
        } else revert YOU_DO_NOT_QUALIFY();
    }

    receive() external payable { }

    fallback() external payable { }
}