//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract EventContract {
    struct Event {
        address organizer;
        string name;
        uint date;
        uint price;
        uint ticketCount;
        uint ticketRemain;
    }

    mapping(uint => Event) public events;
    mapping(address => mapping(uint => uint)) public tickets;
    uint public nextId;

    function createEvent(string memory _name, uint _date, uint _price, uint _ticketCount) external {
        require(_date > block.timestamp, "Enter correct date");
        require( _price> 0, "Price should be greater than 0");
        require( _ticketCount > 0, "Ticket count should be positive");

        events[nextId] = Event(msg.sender, _name, _date, _price, _ticketCount, _ticketCount);
        nextId++;
    }

    function buyTicket(uint eventId, uint ticketCount) external payable {
        require( ticketCount <= events[eventId].ticketRemain, "The ticket count is not enough");
        require( msg.value >= events[eventId].price * events[eventId].ticketCount, "The amount is not enough for buying tickets");

        Event storage _event = events[eventId];
        require(msg.value == (_event.price*ticketCount), " Amount not sufficient");
        require( _event.ticketRemain >= ticketCount, "Ticket count is not enough");
        _event.ticketRemain -= ticketCount;
        tickets[msg.sender][eventId] += ticketCount;
    }    

    function transferTickets( uint eventId, uint ticketsCount, address buyer) external {
        require(events[eventId].ticketRemain >= ticketsCount, "Please enter correct number of tickets");
        require(msg.sender != buyer, "You can't transfer tickets to yourself.");

        tickets[msg.sender][eventId] -= ticketsCount;
        tickets[buyer][eventId] += ticketsCount;
    }
}