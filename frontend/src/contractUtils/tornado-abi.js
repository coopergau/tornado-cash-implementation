const TORNADO_ABI = [
    {
      "type": "constructor",
      "inputs": [
        {
          "name": "_levels",
          "type": "uint8",
          "internalType": "uint8"
        },
        {
          "name": "_denomination",
          "type": "uint256",
          "internalType": "uint256"
        },
        {
          "name": "_mimc",
          "type": "address",
          "internalType": "address"
        },
        {
          "name": "_verifier",
          "type": "address",
          "internalType": "address"
        }
      ],
      "stateMutability": "nonpayable"
    },
    {
      "type": "function",
      "name": "deposit",
      "inputs": [
        {
          "name": "_commitment",
          "type": "bytes32",
          "internalType": "bytes32"
        }
      ],
      "outputs": [],
      "stateMutability": "payable"
    },
    {
      "type": "function",
      "name": "getCommitmentUsed",
      "inputs": [
        {
          "name": "_commitment",
          "type": "bytes32",
          "internalType": "bytes32"
        }
      ],
      "outputs": [
        {
          "name": "",
          "type": "bool",
          "internalType": "bool"
        }
      ],
      "stateMutability": "view"
    },
    {
      "type": "function",
      "name": "getInitNodeValue",
      "inputs": [
        {
          "name": "i",
          "type": "uint256",
          "internalType": "uint256"
        }
      ],
      "outputs": [
        {
          "name": "",
          "type": "bytes32",
          "internalType": "bytes32"
        }
      ],
      "stateMutability": "view"
    },
    {
      "type": "function",
      "name": "getLastThirtyRoots",
      "inputs": [],
      "outputs": [
        {
          "name": "",
          "type": "bytes32[30]",
          "internalType": "bytes32[30]"
        }
      ],
      "stateMutability": "view"
    },
    {
      "type": "function",
      "name": "getLastTreePath",
      "inputs": [],
      "outputs": [
        {
          "name": "",
          "type": "bytes32[]",
          "internalType": "bytes32[]"
        }
      ],
      "stateMutability": "view"
    },
    {
      "type": "function",
      "name": "getNextDepositIndex",
      "inputs": [],
      "outputs": [
        {
          "name": "",
          "type": "uint16",
          "internalType": "uint16"
        }
      ],
      "stateMutability": "view"
    },
    {
      "type": "function",
      "name": "getNullHashUsed",
      "inputs": [
        {
          "name": "_nullHash",
          "type": "bytes32",
          "internalType": "bytes32"
        }
      ],
      "outputs": [
        {
          "name": "",
          "type": "bool",
          "internalType": "bool"
        }
      ],
      "stateMutability": "view"
    },
    {
      "type": "function",
      "name": "getNumOfPrevRoots",
      "inputs": [],
      "outputs": [
        {
          "name": "",
          "type": "uint8",
          "internalType": "uint8"
        }
      ],
      "stateMutability": "pure"
    },
    {
      "type": "function",
      "name": "withdraw",
      "inputs": [
        {
          "name": "_pA",
          "type": "uint256[2]",
          "internalType": "uint256[2]"
        },
        {
          "name": "_pB",
          "type": "uint256[2][2]",
          "internalType": "uint256[2][2]"
        },
        {
          "name": "_pC",
          "type": "uint256[2]",
          "internalType": "uint256[2]"
        },
        {
          "name": "_root",
          "type": "bytes32",
          "internalType": "bytes32"
        },
        {
          "name": "_nullifierHash",
          "type": "bytes32",
          "internalType": "bytes32"
        }
      ],
      "outputs": [],
      "stateMutability": "nonpayable"
    },
    {
      "type": "event",
      "name": "Deposit",
      "inputs": [
        {
          "name": "commitment",
          "type": "bytes32",
          "indexed": false,
          "internalType": "bytes32"
        },
        {
          "name": "treePath",
          "type": "bytes32[]",
          "indexed": false,
          "internalType": "bytes32[]"
        },
        {
          "name": "hashDirections",
          "type": "uint8[]",
          "indexed": false,
          "internalType": "uint8[]"
        }
      ],
      "anonymous": false
    },
    {
      "type": "event",
      "name": "Withdraw",
      "inputs": [
        {
          "name": "nullifierHash",
          "type": "bytes32",
          "indexed": false,
          "internalType": "bytes32"
        }
      ],
      "anonymous": false
    },
    {
      "type": "error",
      "name": "ReentrancyGuardReentrantCall",
      "inputs": []
    },
    {
      "type": "error",
      "name": "Tornado__CommitmentAlreadyHasADeposit",
      "inputs": []
    },
    {
      "type": "error",
      "name": "Tornado__DepositAmountIsNotProperDenomination",
      "inputs": []
    },
    {
      "type": "error",
      "name": "Tornado__HashElementNotInField",
      "inputs": []
    },
    {
      "type": "error",
      "name": "Tornado__InvalidWithdrawProof",
      "inputs": []
    },
    {
      "type": "error",
      "name": "Tornado__MaxDepositsReached",
      "inputs": []
    },
    {
      "type": "error",
      "name": "Tornado__NotACurrentRoot",
      "inputs": []
    },
    {
      "type": "error",
      "name": "Tornado__NullifierAlreadyUsed",
      "inputs": []
    },
    {
      "type": "error",
      "name": "Tornado__TreeLevelsExceedsTen",
      "inputs": []
    },
    {
      "type": "error",
      "name": "Tornado__WithdrawFailed",
      "inputs": []
    }
  ]