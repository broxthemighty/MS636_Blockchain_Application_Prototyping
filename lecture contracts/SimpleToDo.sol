// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;  // Ensure using a Cancun-compatible Solidity version

contract SimpleToDo {

    address public user;

    // events
    event toDoCreated(string text);
    event toDoUpdated(uint256 index, string text);
    event toDoDeleted(uint256 index);
    event allToDoDeleted();

    // error
    error invalidUser();

    // modifiers
    modifier validUser() {
        if(msg.sender != user) {
            revert invalidUser();
        }
        _;
    }

    modifier outOfBounds(uint256 _index) {
        require(_index < todos.length, "Index out of bounds");
        _;
    }

    constructor() {
        user = msg.sender;
    }

    struct ToDo {
        string text;
        bool completed;
    }

    ToDo[] public todos;

    function create(string calldata _text) external validUser {
        todos.push(ToDo({text: _text, completed: false}));
        emit toDoCreated(_text);
    }

    function updateText(uint256 _index, string calldata _text) external validUser outOfBounds(_index) {
        todos[_index].text = _text;
    }

    function get(uint _index) external view outOfBounds(_index) returns (string memory, bool) {
        ToDo memory todo = todos[_index];
        return (todo.text, todo.completed);
    }
    
    function toggleCompleted(uint _index) external validUser outOfBounds(_index) {
        todos[_index].completed = !todos[_index].completed;
    }

    function deleteToDo(uint _index) external validUser outOfBounds(_index) {
        todos[_index] = todos[todos.length - 1];
        todos.pop();
        emit toDoDeleted(_index);
    }

    function lengthOfToDo() external view returns(uint256) {
        return todos.length;
    }
}