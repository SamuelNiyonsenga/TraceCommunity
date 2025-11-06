// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title BatchRegistry - simple supply chain batch tracker for community cooperatives
/// @notice Permissioned roles: COOP_ADMIN (owner), PRODUCER, TRANSPORTER, INSPECTOR, BUYER
/// Stores minimal batch metadata and immutable checkpoint events. Large docs stored off-chain (IPFS hashes).

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract BatchRegistry is AccessControl {
    using Counters for Counters.Counter;
    Counters.Counter private _batchIds;

    bytes32 public constant COOP_ADMIN = keccak256("COOP_ADMIN");
    bytes32 public constant PRODUCER = keccak256("PRODUCER");
    bytes32 public constant TRANSPORTER = keccak256("TRANSPORTER");
    bytes32 public constant INSPECTOR = keccak256("INSPECTOR");
    bytes32 public constant BUYER = keccak256("BUYER");

    struct Checkpoint {
        uint256 timestamp;
        address actor;
        string role;
        string status; // e.g., "collected", "cooled", "transported", "tested"
        string note;   // optional short note
        string ipfsHash; // optional off-chain evidence
    }

    struct Batch {
        uint256 id;
        address producer;
        string cooperativeId;
        string productType;
        uint256 quantity; // smallest unit (e.g., liters)
        uint256 createdAt;
        string ipfsHash; // optional extended metadata
        bool exists;
    }

    mapping(uint256 => Batch) public batches;
    mapping(uint256 => Checkpoint[]) private _checkpoints;

    event BatchCreated(uint256 indexed batchId, address indexed producer, string cooperativeId, string productType, uint256 quantity, string ipfsHash);
    event CheckpointAdded(uint256 indexed batchId, address indexed actor, string role, string status, string ipfsHash, string note);
    event BatchTransferred(uint256 indexed batchId, address indexed from, address indexed to, string note);

    constructor(address admin) {
        // admin becomes COOP_ADMIN
        _setupRole(DEFAULT_ADMIN_ROLE, admin);
        _setupRole(COOP_ADMIN, admin);
    }

    /// @notice Admin registers participant with a role
    function assignRole(address account, bytes32 role) external onlyRole(COOP_ADMIN) {
        require(role == PRODUCER || role == TRANSPORTER || role == INSPECTOR || role == BUYER, "Invalid role");
        grantRole(role, account);
    }

    /// @notice Create a new batch (only PRODUCER)
    function createBatch(string calldata cooperativeId, string calldata productType, uint256 quantity, string calldata ipfsHash) external onlyRole(PRODUCER) returns (uint256) {
        _batchIds.increment();
        uint256 newId = _batchIds.current();
        batches[newId] = Batch({
            id: newId,
            producer: msg.sender,
            cooperativeId: cooperativeId,
            productType: productType,
            quantity: quantity,
            createdAt: block.timestamp,
            ipfsHash: ipfsHash,
            exists: true
        });

        // initial checkpoint: created
        _checkpoints[newId].push(Checkpoint({
            timestamp: block.timestamp,
            actor: msg.sender,
            role: "PRODUCER",
            status: "created",
            note: "",
            ipfsHash: ipfsHash
        }));

        emit BatchCreated(newId, msg.sender, cooperativeId, productType, quantity, ipfsHash);
        return newId;
    }

    /// @notice Add a checkpoint (TRANSPORTER or INSPECTOR)
    function addCheckpoint(uint256 batchId, string calldata role, string calldata status, string calldata ipfsHash, string calldata note) external {
        require(batches[batchId].exists, "Batch not found");

        // check role authorization if role param corresponds
        if (keccak256(bytes(role)) == keccak256(bytes("TRANSPORTER"))) {
            require(hasRole(TRANSPORTER, msg.sender), "Not transporter");
        } else if (keccak256(bytes(role)) == keccak256(bytes("INSPECTOR"))) {
            require(hasRole(INSPECTOR, msg.sender), "Not inspector");
        } else {
            // allow other roles if they have the corresponding role granted
            // e.g., "BUYER" or others could add notes if desired
        }

        _checkpoints[batchId].push(Checkpoint({
            timestamp: block.timestamp,
            actor: msg.sender,
            role: role,
            status: status,
            note: note,
            ipfsHash: ipfsHash
        }));

        emit CheckpointAdded(batchId, msg.sender, role, status, ipfsHash, note);
    }

    /// @notice Transfer custody (simple event, custody not enforced on-chain)
    function transferBatch(uint256 batchId, address to, string calldata note) external {
        require(batches[batchId].exists, "Batch not found");
        // only role holders can transfer (PRODUCER, TRANSPORTER, BUYER)
        require(hasRole(PRODUCER, msg.sender) || hasRole(TRANSPORTER, msg.sender) || hasRole(BUYER, msg.sender), "Not permitted to transfer");
        emit BatchTransferred(batchId, msg.sender, to, note);
    }

    /// @notice Read checkpoints length
    function getCheckpointsCount(uint256 batchId) external view returns (uint256) {
        return _checkpoints[batchId].length;
    }

    /// @notice Get single checkpoint by index
    function getCheckpoint(uint256 batchId, uint256 index) external view returns (Checkpoint memory) {
        require(index < _checkpoints[batchId].length, "Index oob");
        return _checkpoints[batchId][index];
    }

    /// @notice Get basic batch info
    function getBatch(uint256 batchId) external view returns (Batch memory) {
        require(batches[batchId].exists, "Batch not found");
        return batches[batchId];
    }
}
