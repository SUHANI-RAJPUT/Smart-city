// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title SmartCity
 * @dev A smart contract for managing city resources and citizen services
 */
contract Project {
    // State variables
    address public mayor;
    uint256 public totalCitizens;
    uint256 public cityBudget;
    
    // Structs
    struct Citizen {
        uint256 id;
        address walletAddress;
        string name;
        bool isRegistered;
        uint256 registrationDate;
    }
    
    struct ServiceRequest {
        uint256 requestId;
        address citizen;
        string serviceType;
        string description;
        bool isCompleted;
        uint256 requestDate;
    }
    
    // Mappings
    mapping(address => Citizen) public citizens;
    mapping(uint256 => ServiceRequest) public serviceRequests;
    mapping(address => bool) public authorizedOfficials;
    
    // Arrays
    address[] public citizenAddresses;
    uint256[] public requestIds;
    
    // Events
    event CitizenRegistered(address indexed citizen, uint256 citizenId, string name);
    event ServiceRequested(uint256 indexed requestId, address indexed citizen, string serviceType);
    event ServiceCompleted(uint256 indexed requestId, address indexed official);
    event BudgetUpdated(uint256 newBudget, address indexed updatedBy);
    
    // Modifiers
    modifier onlyMayor() {
        require(msg.sender == mayor, "Only mayor can perform this action");
        _;
    }
    
    modifier onlyAuthorized() {
        require(authorizedOfficials[msg.sender] || msg.sender == mayor, "Not authorized");
        _;
    }
    
    modifier onlyRegisteredCitizen() {
        require(citizens[msg.sender].isRegistered, "Citizen not registered");
        _;
    }
    
    // Constructor
    constructor() {
        mayor = msg.sender;
        cityBudget = 0;
        totalCitizens = 0;
    }
    
    /**
     * @dev Core Function 1: Register a new citizen
     * @param _name Name of the citizen
     */
    function registerCitizen(string memory _name) public {
        require(!citizens[msg.sender].isRegistered, "Citizen already registered");
        require(bytes(_name).length > 0, "Name cannot be empty");
        
        totalCitizens++;
        
        citizens[msg.sender] = Citizen({
            id: totalCitizens,
            walletAddress: msg.sender,
            name: _name,
            isRegistered: true,
            registrationDate: block.timestamp
        });
        
        citizenAddresses.push(msg.sender);
        
        emit CitizenRegistered(msg.sender, totalCitizens, _name);
    }
    
    /**
     * @dev Core Function 2: Submit a service request
     * @param _serviceType Type of service requested
     * @param _description Description of the service needed
     */
    function requestService(string memory _serviceType, string memory _description) public onlyRegisteredCitizen {
        require(bytes(_serviceType).length > 0, "Service type cannot be empty");
        require(bytes(_description).length > 0, "Description cannot be empty");
        
        uint256 requestId = block.timestamp + uint256(keccak256(abi.encodePacked(msg.sender))) % 10000;
        
        serviceRequests[requestId] = ServiceRequest({
            requestId: requestId,
            citizen: msg.sender,
            serviceType: _serviceType,
            description: _description,
            isCompleted: false,
            requestDate: block.timestamp
        });
        
        requestIds.push(requestId);
        
        emit ServiceRequested(requestId, msg.sender, _serviceType);
    }
    
    /**
     * @dev Core Function 3: Complete a service request
     * @param _requestId ID of the service request to complete
     */
    function completeService(uint256 _requestId) public onlyAuthorized {
        require(serviceRequests[_requestId].requestId != 0, "Service request does not exist");
        require(!serviceRequests[_requestId].isCompleted, "Service already completed");
        
        serviceRequests[_requestId].isCompleted = true;
        
        emit ServiceCompleted(_requestId, msg.sender);
    }
    
    // Additional utility functions
    
    /**
     * @dev Add authorized official
     * @param _official Address of the official to authorize
     */
    function addAuthorizedOfficial(address _official) public onlyMayor {
        require(_official != address(0), "Invalid address");
        authorizedOfficials[_official] = true;
    }
    
    /**
     * @dev Update city budget
     * @param _newBudget New budget amount
     */
    function updateBudget(uint256 _newBudget) public onlyMayor {
        cityBudget = _newBudget;
        emit BudgetUpdated(_newBudget, msg.sender);
    }
    
    /**
     * @dev Get citizen information
     * @param _citizenAddress Address of the citizen
     */
    function getCitizenInfo(address _citizenAddress) public view returns (
        uint256 id,
        string memory name,
        bool isRegistered,
        uint256 registrationDate
    ) {
        Citizen memory citizen = citizens[_citizenAddress];
        return (citizen.id, citizen.name, citizen.isRegistered, citizen.registrationDate);
    }
    
    /**
     * @dev Get service request details
     * @param _requestId ID of the service request
     */
    function getServiceRequest(uint256 _requestId) public view returns (
        address citizen,
        string memory serviceType,
        string memory description,
        bool isCompleted,
        uint256 requestDate
    ) {
        ServiceRequest memory request = serviceRequests[_requestId];
        return (request.citizen, request.serviceType, request.description, request.isCompleted, request.requestDate);
    }
    
    /**
     * @dev Get total number of service requests
     */
    function getTotalRequests() public view returns (uint256) {
        return requestIds.length;
    }
    
    /**
     * @dev Get all citizen addresses
     */
    function getAllCitizens() public view returns (address[] memory) {
        return citizenAddresses;
    }
}

address : 0xd9145CCE52D386f254917e481eB44e9943F39138

screenShot: ![image](https://user-images.githubusercontent.com/your-image-url.png)
