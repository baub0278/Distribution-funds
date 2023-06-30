// The startup funding contract
contract StartupFunding {
  struct Startup {
    address payable founder;
    string name;
    uint balance;
    uint votes;
    bool active;
  }

  mapping(address => Startup) public startups;
  address[] public startupList;

  address public admin;
  uint public totalFunds;
  uint public votePrice;
  uint public voteThreshold;
  uint public voteDuration;
  mapping(address => mapping(uint => bool)) votes;

  event StartupRegistered(address founder, string name);
  event FundsAllocated(address startup, uint amount);
  event VoteCasted(address voter, address startup, uint votes);

  constructor(uint _votePrice, uint _voteThreshold, uint _voteDuration) {
    admin = msg.sender;
    votePrice = _votePrice;
    voteThreshold = _voteThreshold;
    voteDuration = _voteDuration;
  }

  function registerStartup(string memory _name) public {
    require(startups[msg.sender].active == false);
    Startup memory newStartup = Startup({
      founder: msg.sender,
      name: _name,
      balance: 0,
      votes: 0,
      active: true
    });
    startups[msg.sender] = newStartup;
    startupList.push(msg.sender);
    emit StartupRegistered(msg.sender, _name);
  }

  function deposit() public payable {
    totalFunds += msg.value;
  }

  function allocateFunds() public {
    address payable winner = address(0);
    uint maxVotes = 0;
    for (uint i = 0; i < startupList.length; i++) {
      Startup storage startup = startups[startupList[i]];
      if (startup.votes >= voteThreshold && startup.active) {
        if (startup.votes > maxVotes) {
          maxVotes = startup.votes;
          winner = startup.founder;
        }
      }
    }
    require(winner != address(0));
    uint amount = totalFunds / 2;
    totalFunds -= amount;
    startups[winner].balance += amount;
    emit FundsAllocated(winner, amount);
  }

  function vote(address _startup, uint _votes) public payable {
    require(msg.value == _votes * votePrice);
    Startup storage startup = startups[_startup];
    require(startup.active == true && msg.sender != _startup && votes[msg.sender[_startup][_votes] == false);
startup.votes += _votes;
votes[msg.sender][_votes] = true;
emit VoteCasted(msg.sender, _startup, _votes);
}

function withdrawFunds() public {
Startup storage startup = startups[msg.sender];
require(startup.active == true && startup.balance > 0);
uint amount = startup.balance;
startup.balance = 0;
payable(startup.founder).transfer(amount);
}

function disableStartup() public {
Startup storage startup = startups[msg.sender];
require(startup.active == true);
startup.active = false;
}

function changeVotePrice(uint _votePrice) public {
require(msg.sender == admin);
votePrice = _votePrice;
}

function changeVoteThreshold(uint _voteThreshold) public {
require(msg.sender == admin);
voteThreshold = _voteThreshold;
}

function changeVoteDuration(uint _voteDuration) public {
require(msg.sender == admin);
voteDuration = _voteDuration;
}
}

