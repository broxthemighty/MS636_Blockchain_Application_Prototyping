// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title General API Marketplace Token
 * @dev Marketplace where users can buy API access with tokens
 */
 
contract GeneralApiMarketplaceToken is ReentrancyGuard, AccessControl {
    using SafeERC20 for IERC20;

    IERC20 public immutable token;
    address public owner;
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    struct APIAccess {
        string name;
        uint256 pricePerRequest;
        uint256 totalPurchases;
        bool isActive;
    }

    struct UserUsage {
        mapping(uint256 => uint256) remainingRequests;
        mapping(uint256 => uint256) subscriptionExpiry;
    }

    uint256 public apiIdCounter;
    mapping(uint256 => APIAccess) public apis;
    mapping(address => UserUsage) private userUsages;

    event APIRegistered(uint256 indexed apiId, string name, uint256 pricePerRequest);
    event APIAccessPurchased(address indexed user, uint256 indexed apiId, uint256 requests);
    event APICallMade(address indexed user, uint256 indexed apiId);
    event TokensWithdrawn(address indexed owner, uint256 amount);
    event APIStatusUpdated(uint256 indexed apiId, bool isActive);
    event SubscriptionPurchased(address indexed user, uint256 indexed apiId, uint256 duration);
    event RefundIssued(address indexed user, uint256 indexed apiId, uint256 amount);

    constructor(IERC20 _token) {
    require(address(_token) != address(0), "Invalid token address");
    token = _token;
    owner = msg.sender;

    _grantRole(DEFAULT_ADMIN_ROLE, msg.sender); 
    _grantRole(ADMIN_ROLE, msg.sender);        
}


    modifier onlyOwner() {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Caller is not the owner");
        _;
    }

    modifier onlyAdmin() {
        require(hasRole(ADMIN_ROLE, msg.sender), "Caller is not an admin");
        _;
    }

    function addAdmin(address _admin) external onlyOwner {
        grantRole(ADMIN_ROLE, _admin);
    }

    function removeAdmin(address _admin) external onlyOwner {
        revokeRole(ADMIN_ROLE, _admin);
    }

    function registerAPI(string memory _name, uint256 _pricePerRequest) external onlyAdmin {
        require(bytes(_name).length > 0, "API name cannot be empty");
        require(_pricePerRequest > 0, "Price per request must be greater than zero");

        uint256 apiId = apiIdCounter++;
        apis[apiId] = APIAccess({
            name: _name,
            pricePerRequest: _pricePerRequest,
            totalPurchases: 0,
            isActive: true
        });

        emit APIRegistered(apiId, _name, _pricePerRequest);
    }

    function setAPIStatus(uint256 _apiId, bool _isActive) external onlyAdmin {
        require(_apiId < apiIdCounter, "API does not exist");
        apis[_apiId].isActive = _isActive;

        emit APIStatusUpdated(_apiId, _isActive);
    }

    function purchaseAPIAccess(uint256 _apiId, uint256 _requests) external {
        require(_apiId < apiIdCounter, "API does not exist");
        require(_requests > 0, "Number of requests must be greater than zero");

        APIAccess storage api = apis[_apiId];
        require(api.isActive, "API is not active");

        uint256 totalCost = api.pricePerRequest * _requests;
        require(totalCost / _requests == api.pricePerRequest, "Overflow detected");

        token.safeTransferFrom(msg.sender, address(this), totalCost);
        userUsages[msg.sender].remainingRequests[_apiId] += _requests;
        api.totalPurchases += _requests;

        emit APIAccessPurchased(msg.sender, _apiId, _requests);
    }

    function purchaseSubscription(uint256 _apiId, uint256 _duration) external {
        require(_apiId < apiIdCounter, "API does not exist");

        APIAccess storage api = apis[_apiId];
        require(api.isActive, "API is not active");

        uint256 totalCost = api.pricePerRequest * _duration;
        token.safeTransferFrom(msg.sender, address(this), totalCost);

        userUsages[msg.sender].subscriptionExpiry[_apiId] = block.timestamp + _duration;

        emit SubscriptionPurchased(msg.sender, _apiId, _duration);
    }

    function useAPIAccess(uint256 _apiId) external {
        require(_apiId < apiIdCounter, "API does not exist");

        APIAccess storage api = apis[_apiId];
        require(api.isActive, "API is not active");

        uint256 remaining = userUsages[msg.sender].remainingRequests[_apiId];
        require(remaining > 0, "No remaining API requests");

        userUsages[msg.sender].remainingRequests[_apiId] -= 1;
        emit APICallMade(msg.sender, _apiId);
    }

    function withdrawTokens() external onlyOwner nonReentrant {
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, "No tokens to withdraw");

        token.safeTransfer(owner, balance);
        emit TokensWithdrawn(owner, balance);
    }

    function refundUnusedRequests(uint256 _apiId) external {
        require(_apiId < apiIdCounter, "API does not exist");
        require(!apis[_apiId].isActive, "API is still active");

        uint256 remainingRequests = userUsages[msg.sender].remainingRequests[_apiId];
        require(remainingRequests > 0, "No requests to refund");

        uint256 refundAmount = remainingRequests * apis[_apiId].pricePerRequest;
        userUsages[msg.sender].remainingRequests[_apiId] = 0;

        token.safeTransfer(msg.sender, refundAmount);
        emit RefundIssued(msg.sender, _apiId, refundAmount);
    }

    function getRemainingRequests(address _user, uint256 _apiId) external view returns (uint256) {
        require(_apiId < apiIdCounter, "API does not exist");
        return userUsages[_user].remainingRequests[_apiId];
    }

    function getSubscriptionStatus(address _user, uint256 _apiId) external view returns (bool) {
        require(_apiId < apiIdCounter, "API does not exist");
        return block.timestamp <= userUsages[_user].subscriptionExpiry[_apiId];
    }
}
