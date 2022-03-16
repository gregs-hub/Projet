// Voting.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

/**
 * @title Voting contract for a small organization
 * @author Grégory Seiller
 */

contract Voting is Ownable {

    // STATE VARIABLES
    struct Voter {
        bool isRegistered;
        bool hasVoted;
        uint votedProposalId;
    }

    struct Proposal {
        string description;
        uint voteCount;
    }
    Proposal[] proposals;
    uint proposalId;

    enum WorkflowStatus {
        RegisteringVoters,
        ProposalsRegistrationStarted,
        ProposalsRegistrationEnded,
        VotingSessionStarted,
        VotingSessionEnded,
        VotesTallied
    }
    WorkflowStatus status = WorkflowStatus.RegisteringVoters;

    mapping(address => bool) public whitelist;
    mapping(address => Voter) public voters;

    uint public nbVoters;
    uint public nbVotes;
    uint maxVotesCount;
    uint[] maxVotesId;

    // EVENTS
    event VoterRegistered(address voterAddress);
    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);
    event ProposalRegistered(uint proposalId);
    event Voted (address voter, uint proposalId);

    // MODIFIERS
    // onlyOwner herited from Ownable.sol
    modifier isWhitelisted() {
        require(whitelist[msg.sender] == true, "You are not in the whitelist, cannot proceed");
        _;
    }

    modifier withStatus(uint _status) {
        require(uint(status) == _status, "Impossible during this phase");
        _;
    }

    // FUNCTIONS
    // constructor() {}

    // At any time, whitelisted voters can view all listed proposals
    function showProposals() external view isWhitelisted returns(Proposal[] memory)  {
        return proposals;
    }

    // At any time, whitelisted voters can view current status
    function showStatus() external view isWhitelisted returns(WorkflowStatus) {
        return status;
    }

    // Owner can add a new voter to the whitelist. Current status must be RegisteringVoters
    function addVoter(address _address) external onlyOwner withStatus(0) {
        require(!whitelist[_address], "This voter already exists");
        whitelist[_address] = true;
        voters[_address] = Voter(true, false, 0);
        nbVoters++;
        emit VoterRegistered(_address);
    }

    // Owner starts the proposal registration phase. Current status must be RegisteringVoters
    function startProposalRegistration() external onlyOwner withStatus(0) {
        require(nbVoters >= 1, "No voter found in your whitelist registry");
        status = WorkflowStatus.ProposalsRegistrationStarted;
        emit WorkflowStatusChange(WorkflowStatus.RegisteringVoters, status);
    }

    // Whitelisted voters can add a new proposal. Current status must be ProposalsRegistrationStarted
    function addProposal(string memory _description) external isWhitelisted withStatus(1) {
        require(bytes(_description).length > 0, "Cannot accept an empty proposal description");
        Proposal memory proposal = Proposal(_description, 0);
        proposals.push(proposal);
        proposalId++;
        emit ProposalRegistered(proposalId);
    }

    // Owner ends the proposal registration phase. Current status must be ProposalsRegistrationStarted
    function endProposalRegistration() external onlyOwner withStatus(1) {
        require(proposalId >= 1, "There is no submitted proposal for now, cannot end this phase");
        status = WorkflowStatus.ProposalsRegistrationEnded;
        emit WorkflowStatusChange(WorkflowStatus.ProposalsRegistrationStarted, status);
    }

    // Owner starts the voting phase. Current status must be ProposalsRegistrationEnded
    function startVotingSession() external onlyOwner withStatus(2) {
        status = WorkflowStatus.VotingSessionStarted;
        emit WorkflowStatusChange(WorkflowStatus.ProposalsRegistrationStarted, status);
    }

    // Whitelisted voters can vote for a unique proposal. Current status must be VotingSessionStarted
    function doVote(uint _proposalId) external isWhitelisted withStatus(3) {
        require(!voters[msg.sender].hasVoted, "Already voted");
        require(_proposalId < proposalId, "No proposal with this Id");
        voters[msg.sender].hasVoted = true;
        voters[msg.sender].votedProposalId = _proposalId;
        proposals[_proposalId].voteCount++;
        nbVotes++;
        emit Voted (msg.sender, _proposalId);
    }

    // Owner ends the voting phase. Current status must be VotingSessionStarted
    function endVotingSession() external onlyOwner withStatus(3) {
        require(nbVotes >= 1, "There is no vote for now, cannot end this phase");
        status = WorkflowStatus.VotingSessionEnded;
        emit WorkflowStatusChange(WorkflowStatus.VotingSessionStarted, status);
    }

    // Owner tallies the final votes. Current status must be VotingSessionEnded
    function tallyVotes() external onlyOwner withStatus(4) {
        for (uint i = 0; i < proposals.length ; i++) {
            if (proposals[i].voteCount > maxVotesCount) {
                maxVotesCount = proposals[i].voteCount;
                delete maxVotesId;
                maxVotesId.push(i);
            }
            else if (proposals[i].voteCount == maxVotesCount) {
                maxVotesId.push(i);
            }
        }
        status = WorkflowStatus.VotesTallied;
        emit WorkflowStatusChange(WorkflowStatus.VotingSessionEnded, status);
    }

    // Owner publishes the final winner proposal, or an error if no majority. Current status must be VotesTallied
    function getWinner() external view withStatus(5) returns(uint winningProposalId, string memory) {
        require(maxVotesId.length == 1, "No majority found");
        winningProposalId = maxVotesId[0];
        return (winningProposalId, proposals[winningProposalId].description);
    }
}