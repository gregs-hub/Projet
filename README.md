# alyra-projet01-voting

**⚡️ Projet 01 - Voting system** <br />
This project aims at creating a voting smart contract for a small organization. The voters, all known by the organization, are registered by the administrator on a whitelist with their wallet address. Voters can submit proposals to the vote during the Proposal Registration phase. Voters can vote on propositions during the Voting Session.

👉 Details:
- Votes are public
- Each voter can see each others votes
- Winning proposal is the one with the majority of votes
    
👉 Full administrative process :
- The administrator register authorized voters' address on a whitelist during the first step.
- The administrator starts the proposal registration phase.
- During this phase, voters can each register zero to several proposals, submited to vote.
- The administrator ends the proposal registration phase.
- The administrator starts the voting phase.
- During this phase, voters can each vote on their favorite proposals.
- The administrator ends the voting phase.
- The administrator tallies votes.
- The administrator reveals the winning proposal.
- Everyone (entire organization) can see the winning proposal.