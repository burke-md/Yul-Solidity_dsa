// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.17;

contract LinkedList {

    struct Node {
        uint256 data;
        uint256 next;      
        uint256 prev;
    }


    /**
    * @dev 'nodes' is a dynamically sized array to track Nodes. As there are no
    *      pointers available, we will reference their index.
    */
    Node[] public nodes;

    uint256 public headIdx;
    uint256 public tailIdx;

    constructor() {
        nodes.push(Node(0, 0, 0));
        headIdx = 0;
        tailIdx = 0;

        insertAtTail(1);
        insertAtTail(2);
        insertAtTail(3);
    }


    function insertAtTail(uint256 _data) public {
        nodes.push(Node(_data, 0, nodes.length-1));
        nodes[tailIdx].next = tailIdx+1; 
        ++tailIdx;
        nodes[headIdx].prev = tailIdx;
    }

    function reverseLinkedList() external {
        
        assembly{
            let leftIdx := sload(tailIdx.slot)
            let currentIdx := sload(headIdx.slot)
            let rightIdx := 0

            let len := sload(nodes.slot)

            for { let i := 0 } lt(i, len) { i := add(i, 1) }
            {

                // Set 'rightIdx' pointer
                mstore(0x00, 0x00)
                let rightIdxKey := add(keccak256(0x00, 0x20), add(mul(currentIdx, 0x03), 0x01))
                rightIdx := sload(rightIdxKey)
                
                // Update current node's next pointer
                sstore(rightIdxKey, leftIdx)
                
                // Update current node's prev pointer
                let currentPrevKey := add(keccak256(0x00, 0x20), add(mul(currentIdx, 0x03), 0x02))
                sstore(currentPrevKey, rightIdx)

                //Update: left pointer equals current pointer
                leftIdx := currentIdx

                //Update: current pointer equals right pointer
                currentIdx := rightIdx    
            }

            // Update headIdx and tailIdx
            sstore(0x02, sload(0x01))
            sstore(0x01, leftIdx)
        }
    }
}