// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

import "hardhat/console.sol";

contract InvertBST {
    struct Node {
        uint256 value;
        uint256 leftIdx;
        uint256 rightIdx;
    }   
   
    uint256 public immutable rootIdx;

    Node[] public nodes;

    constructor () {
        // Define root node @nodes[0]
        nodes.push(Node(10, 0, 0));
        rootIdx = 0;

        // Set up demo
        insert(0, 9);
        insert(0, 13);
        insert(0, 11);
        insert(0, 14);
        insert(0, 12);
    }

    function invertBST(uint256 _idx) public {

        assembly{
            mstore(0x00, 0x00)
            let currentLeftPtr := add(keccak256(0x00, 0x20), add(mul(0x03, _idx), 0x01))

            mstore(0x00, 0x00)
            let currentRightPtr := add(keccak256(0x00, 0x20), add(mul(0x03, _idx), 0x02))

            let currentLeftVal := sload(currentLeftPtr)
            let currentRightVal := sload(currentRightPtr)

            let isLeaf := and(iszero(currentLeftVal), iszero(currentRightVal))

            if isLeaf {
                return(0,0)
            }

            sstore(currentRightPtr, currentLeftVal)
            sstore(currentLeftPtr, currentRightVal)

            // Function selector
            mstore(0x00, 0x30e8364d00000000000000000000000000000000000000000000000000000000)
            
            if currentLeftVal {
                mstore(0x04, currentLeftVal)
                pop(call(gas(), address(), 0, 0x00, 0x24, 0, 0))
            }

            if currentRightVal {
                mstore(0x04, currentRightVal)
                pop(call(gas(), address(), 0, 0x00, 0x24, 0, 0))
            }
        }   
    }

    /**
    * @dev Call this function w/ root note. Will call recursively (DFS) while
    *      traversing tree until 
    *
    */
    function insert(uint256 _idx, uint256 _value) public {
        uint256 _currentNodeIdx = _idx;
        if(_value < nodes[_currentNodeIdx].value) {
            if(nodes[_idx].leftIdx == 0) {
                nodes.push(Node(_value, 0, 0));
                nodes[_currentNodeIdx].leftIdx = nodes.length-1;
            } else {
                insert(nodes[_currentNodeIdx].leftIdx, _value);
            }
        } else {
            if(nodes[_currentNodeIdx].rightIdx == 0) {
                nodes.push(Node(_value, 0, 0));
                nodes[_currentNodeIdx].rightIdx = nodes.length-1;
            } else {
                insert(nodes[_currentNodeIdx].rightIdx, _value);
            }
        }
    }

    function displayInOrder(uint256 _rootIdx) public {
        Node memory currentNode = nodes[_rootIdx];

        if (currentNode.leftIdx != 0) {
            displayInOrder(currentNode.leftIdx);
        }
        console.log(currentNode.value);
        if (currentNode.rightIdx != 0) {
            displayInOrder(currentNode.rightIdx);
        }
    }  
}