// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Guestbook {
    struct Entry {
        address user;
        string message;
        uint timestamp;
    }

    Entry[] public entries;

    event EntryAdded(address indexed user, string message, uint timestamp);

    function addEntry(string calldata _message) external {
        entries.push(Entry({
            user: msg.sender,
            message: _message,
            timestamp: block.timestamp
        }));
        emit EntryAdded(msg.sender, _message, block.timestamp);
    }

    function getEntries(uint _startIndex, uint _limit) external view returns (Entry[] memory) {
        require(_startIndex < entries.length, "Start index out of bounds");

        uint endIndex = _startIndex + _limit > entries.length ? entries.length : _startIndex + _limit;
        uint numEntries = endIndex - _startIndex;
        Entry[] memory paginatedEntries = new Entry[](numEntries);

        for (uint i = 0; i < numEntries; i++) {
            paginatedEntries[i] = entries[_startIndex + i];
        }

        return paginatedEntries;
    }
}
