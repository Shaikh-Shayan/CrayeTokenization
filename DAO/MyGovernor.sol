// SPDX-License-Identifier: MIT
pragma solidity >0.7.0 <= 0.9.0;

import "@openzeppelin/contracts/governance/Governor.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorSettings.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorCountingSimple.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotes.sol";
import "@openzeppelin/contracts/governance/extensions/GovernorVotesQuorumFraction.sol";
import "@openzeppelin/contracts/utils/Timers.sol";
import "../token/Token.sol";


contract MyGovernor is Governor, GovernorSettings, GovernorCountingSimple, GovernorVotes, GovernorVotesQuorumFraction {
    Token public propertyToken;

    constructor(address _token, uint256 _votingDelay, uint256 _votingPeriod, uint256 _quorumPercentage)
        Governor("MyGovernor")
        GovernorSettings( _votingDelay, _votingPeriod, 0)
        GovernorVotes(IVotes(_token))
        GovernorVotesQuorumFraction(_quorumPercentage)
    {
        propertyToken = Token(_token);
    }


    /**
    * @dev Create a new proposal. Vote start {MyGovernor-votingDelay} blocks after the proposal is created and ends
    * {MyGovernor-votingPeriod} blocks after the voting starts.
    *
    * Only stakeholders can create a proposal
    */
    function propose(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        string memory description
    ) public override returns (uint256) {

        require(propertyToken.balanceOf(msg.sender)>0,"Only stakeholders can create a proposal");
        uint256 proposalId = super.propose(targets, values, calldatas, description);
        return proposalId;
    }


    /**
    * @dev Execute a successful proposal. This requires the quorum to be reached, the vote to be successful, and the
    * deadline to be reached.
    *
    * Only stakeholders can execute a proposal
    */
    function execute(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) public payable virtual override returns (uint256){

        require(propertyToken.balanceOf(msg.sender)>0,"Only stakeholders can execute a proposal");
        uint256 proposalId = super.execute(targets, values, calldatas, descriptionHash);
        return proposalId;
    }


    // The following functions are overrides required by Solidity.
    function votingDelay()
        public
        view
        override(IGovernor, GovernorSettings)
        returns (uint256)
    {
        return super.votingDelay();
    }

    function votingPeriod()
        public
        view
        override(IGovernor, GovernorSettings)
        returns (uint256)
    {
        return super.votingPeriod();
    }

    function quorum(uint256 blockNumber)
        public
        view
        override(IGovernor, GovernorVotesQuorumFraction)
        returns (uint256)
    {
        return super.quorum(blockNumber);
    }
    
    function proposalThreshold()
        public
        view
        override(Governor, GovernorSettings)
        returns (uint256)
    {
        return super.proposalThreshold();
    }

}
