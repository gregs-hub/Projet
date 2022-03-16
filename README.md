# alyra-projet01-voting

**⚡️ Projet 01 - Voting system**
This project aims at créating a voting smart contract for a small organization. The voters, all known by the organization, are registered by the administrator on a whitelist thanks to there Ethereum wallet address. Voters can submit proposals to vote during the proposal registration phase. Voters can vote on propositions during the Voting Session.

👉 Provided details:
- Votes are public
- Each voter can see others votes
- Winner proposal is the one with majority of votes
    
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