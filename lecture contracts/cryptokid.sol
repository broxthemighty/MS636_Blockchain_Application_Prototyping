//SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;  

contract CryptoKid {
    address public owner;
    error OnlyOwner();
    error ValidAddress();
    event Deposit(address sender, uint amount, uint time);
    event Withdrawal(address receiver, uint amount, uint time);

    struct Kid {
        address payable walletAddress;
        string firstName;
        string lastName;
        uint releaseDate;
        uint amount;
        bool withdrawn;
    }

    Kid[] public kids;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        if(msg.sender != owner) {
            revert OnlyOwner();
        }
        _;
    }

    modifier validAddress(address _walletAddress) {
        if(_walletAddress == address(0)) {
            revert ValidAddress();
        }
        _;
    }

    function addKid(address payable _walletAddress, string memory _firstName, string memory _lastName) public onlyOwner validAddress(_walletAddress) {
        require(_walletAddress != owner, "Owner can't be a kid");
        
        for(uint i; i < kids.length; i++) {
            require(kids[i].walletAddress != _walletAddress, "Address is already used");
        }

        bytes32 firstNameHash = keccak256(abi.encodePacked(_firstName));
        bytes32 lastNameHash = keccak256(abi.encodePacked(_lastName));

        bytes32 emptyStringHash = keccak256(abi.encodePacked(""));

        require(firstNameHash != emptyStringHash, "First Name cannot be empty");
        require(lastNameHash != emptyStringHash, "Last Name cannot be empty");

        Kid memory kid;
        kid.walletAddress = _walletAddress;
        kid.firstName = _firstName;
        kid.lastName = _lastName;
        kid.releaseDate = block.timestamp + (16 * (356 * 1 days)); //released at 16 years
        kids.push(kid);
    }

    function getIndex(address _walletAddress) public view returns (uint) {
        for (uint i; i < kids.length; i++) {
            if(kids[i].walletAddress == _walletAddress) {
                return i;
            }
        }
        return 409;
    }

    function deposit(address _walletAddress) payable public validAddress(_walletAddress) {
        require(_walletAddress != owner, "Owner cannot be a child");
        require(msg.value > 0, "Insufficient balance");
        uint i = getIndex(_walletAddress);
        require(kids[i].walletAddress == _walletAddress, "Address is not in kids array");
        kids[i].amount += msg.value;
        emit Deposit(msg.sender, msg.value, block.timestamp);
    }

    function balance() public view returns(uint) {
        uint i = getIndex(msg.sender);
        if(msg.sender != kids[i].walletAddress) {
            revert ValidAddress();
        }
        return kids[i].amount;
    }

    function availableToWithdraw(address _walletAddress) view public returns (bool) {
        uint i = getIndex(_walletAddress);
        if(block.timestamp > kids[i].releaseDate) {
            return true;
        }
        else {
            return false;
        }
    }

    function withdraw(address payable _walletAddress) public payable validAddress(_walletAddress) {
        uint i = getIndex(_walletAddress);
        require(kids[i].amount > 0, "Insufficient balance");
        require(msg.sender == kids[i].walletAddress, "Only owner of the account");
        require(block.timestamp > kids[i].releaseDate, "Wait for the release time");
        require(!kids[i].withdrawn, "Funds already withdrawn");
        kids[i].amount = 0;
        _walletAddress.transfer(kids[i].amount);
        emit Withdrawal(_walletAddress, msg.value, block.timestamp);
        kids[i].withdrawn = true;
    }
}