const SHA256 = require('crypto-js/sha256');
const TARGET_DIFFICULTY = BigInt('0x0fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff');
const MAX_TRANSACTIONS = 10;

const mempool = [];
const blocks = [];

function addTransaction(transaction) {
    mempool.push(transaction);
}

function mine() {
    let block = {
        id: blocks.length,
        nonce: 0,
        transactions: []
    };

    if (mempool.length > MAX_TRANSACTIONS) {
        block.transactions = mempool.splice(0, MAX_TRANSACTIONS);
    } else {
        block.transactions = mempool.splice(0, mempool.length);
    }

    let blockString;
    let intHash;
    
    // Increment nonce until hash is less than TARGET_DIFFICULTY
    do {
        block.nonce++;
        blockString = JSON.stringify(block);
        const hashedBlock = SHA256(blockString).toString();
        intHash = BigInt(`0x${hashedBlock}`);
    } while (intHash >= TARGET_DIFFICULTY);

    block.hash = SHA256(blockString).toString();
    blocks.push(block);
}

module.exports = {
    TARGET_DIFFICULTY,
    MAX_TRANSACTIONS,
    addTransaction,
    mine,
    blocks,
    mempool
};
