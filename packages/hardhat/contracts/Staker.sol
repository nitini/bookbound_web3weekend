pragma solidity >=0.6.0 <0.7.0;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol"; //https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol

contract Staker {
    ExampleExternalContract public exampleExternalContract;

    constructor(address exampleExternalContractAddress) public {
        exampleExternalContract = ExampleExternalContract(
            exampleExternalContractAddress
        );
    }

    modifier notCompleted {
        require(
            exampleExternalContract.completed() == false,
            "Contract has completed"
        );
        _;
    }

    mapping(address => uint256) public balances;
    uint256 public constant threshold = 1 ether;
    uint256 public deadline = now + 50 seconds;

    event Stake(address, uint256);

    // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
    //  ( make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
    function stake() public payable {
        balances[msg.sender] += msg.value;
        emit Stake(msg.sender, msg.value);
        if (address(this).balance >= threshold && now < deadline) {
            exampleExternalContract.complete{value: address(this).balance}();
        }
    }

    // After some `deadline` allow anyone to call an `execute()` function
    //  It should either call `exampleExternalContract.complete{value: address(this).balance}()` to send all the value

    function execute() public notCompleted {
        if (now >= deadline && address(this).balance >= threshold) {
            exampleExternalContract.complete{value: address(this).balance}();
        }
    }

    function withdraw(address withdrawer) public notCompleted {
        uint256 amount = balances[msg.sender];
        balances[msg.sender] = 0;
        msg.sender.transfer(amount);
    }

    // if the `threshold` was not met, allow everyone to call a `withdraw()` function

    // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
    function timeLeft() public view returns (uint256) {
        if (now >= deadline) {
            return 0;
        } else {
            return (deadline - now);
        }
    }
}
