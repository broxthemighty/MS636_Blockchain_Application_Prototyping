// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/**Created by Matt Lindborg
 * UAT MS636 Week 7
 * @title General API Marketplace Token
 * @dev General API Marketplace Contract
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
 
contract ApiMarketplace is ReentrancyGuard, AccessControl {
    using SafeERC20 for IERC20;

    // token used for payments.
    IERC20 public immutable token;

    // contract owner (marketplace administrator).
    address public owner;

    // admin role hash for permission control.
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    // counter for API IDs
    uint256 public apiIdCounter;

    // API provider revenue balances
    mapping(address => uint256) public providerBalances;

    // struct to store API details
    struct API {
        address provider;
        string name;
        uint256 pricePerRequest;
        uint256 subscriptionPrice;
        uint256 subscriptionDuration;
        uint256 totalPurchases;
        bool isActive;
    }

    // mapping of API ID to API details.
    mapping(uint256 => API) public apis;

    // struct to store user API access details.
    struct UserUsage {
        mapping(uint256 => uint256) remainingRequests;
        mapping(uint256 => uint256) subscriptionExpiry;
    }

    // mapping of user addresses to their API access details.
    mapping(address => UserUsage) private userUsages;

    // events
    event APIRegistered(uint256 indexed apiId, address indexed provider, string name, uint256 pricePerRequest, uint256 subscriptionPrice);
    event APIAccessPurchased(address indexed user, uint256 indexed apiId, uint256 requests);
    event APICallMade(address indexed user, uint256 indexed apiId, uint256 timestamp);
    event TokensWithdrawn(address indexed provider, uint256 amount);
    event APIStatusUpdated(uint256 indexed apiId, bool isActive);
    event SubscriptionPurchased(address indexed user, uint256 indexed apiId, uint256 duration);
    event SubscriptionCancelled(address indexed user, uint256 indexed apiId);
    event RefundIssued(address indexed user, uint256 indexed apiId, uint256 amount);

    constructor(IERC20 _token) {
        require(address(_token) != address(0), "Invalid token address");
        token = _token;
        owner = msg.sender;

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
    }

    modifier onlyProvider(uint256 _apiId) {
        require(apis[_apiId].provider == msg.sender, "Not the API provider");
        _;
    }

    modifier onlyAdmin() {
        require(hasRole(ADMIN_ROLE, msg.sender), "Caller is not an admin");
        _;
    }

    function registerAPI(
        string memory _name,
        uint256 _pricePerRequest,
        uint256 _subscriptionPrice,
        uint256 _subscriptionDuration
    ) external {
        require(bytes(_name).length > 0, "API name cannot be empty");
        require(_pricePerRequest > 0 || _subscriptionPrice > 0, "At least one pricing option required");

        uint256 apiId = apiIdCounter++;
        apis[apiId] = API({
            provider: msg.sender,
            name: _name,
            pricePerRequest: _pricePerRequest,
            subscriptionPrice: _subscriptionPrice,
            subscriptionDuration: _subscriptionDuration,
            totalPurchases: 0,
            isActive: true
        });

        emit APIRegistered(apiId, msg.sender, _name, _pricePerRequest, _subscriptionPrice);
    }

    function purchaseAPIAccess(uint256 _apiId, uint256 _requests) external {
        require(_apiId < apiIdCounter, "API does not exist");
        require(_requests > 0, "Must purchase at least one request");

        API storage api = apis[_apiId];
        require(api.isActive, "API is not active");

        uint256 totalCost = api.pricePerRequest * _requests;
        token.safeTransferFrom(msg.sender, address(this), totalCost);

        userUsages[msg.sender].remainingRequests[_apiId] += _requests;
        providerBalances[api.provider] += totalCost;

        api.totalPurchases += _requests;
        emit APIAccessPurchased(msg.sender, _apiId, _requests);
    }

    function purchaseSubscription(uint256 _apiId) external {
        require(_apiId < apiIdCounter, "API does not exist");

        API storage api = apis[_apiId];
        require(api.isActive, "API is not active");

        uint256 totalCost = api.subscriptionPrice;
        token.safeTransferFrom(msg.sender, address(this), totalCost);

        userUsages[msg.sender].subscriptionExpiry[_apiId] = block.timestamp + api.subscriptionDuration;
        providerBalances[api.provider] += totalCost;

        emit SubscriptionPurchased(msg.sender, _apiId, api.subscriptionDuration);
    }

    function useAPIAccess(uint256 _apiId) external {
        require(_apiId < apiIdCounter, "API does not exist");

        API storage api = apis[_apiId];
        require(api.isActive, "API is not active");

        uint256 remaining = userUsages[msg.sender].remainingRequests[_apiId];
        require(remaining > 0, "No remaining requests");

        userUsages[msg.sender].remainingRequests[_apiId] -= 1;

        emit APICallMade(msg.sender, _apiId, block.timestamp);
    }

    function withdrawEarnings() external nonReentrant {
        uint256 balance = providerBalances[msg.sender];
        require(balance > 0, "No earnings to withdraw");

        providerBalances[msg.sender] = 0;
        token.safeTransfer(msg.sender, balance);

        emit TokensWithdrawn(msg.sender, balance);
    }

    function cancelSubscription(uint256 _apiId) external {
        require(_apiId < apiIdCounter, "API does not exist");
        require(userUsages[msg.sender].subscriptionExpiry[_apiId] > block.timestamp, "No active subscription");

        userUsages[msg.sender].subscriptionExpiry[_apiId] = block.timestamp;
        emit SubscriptionCancelled(msg.sender, _apiId);
    }

    function getUserBalance(address _user) external view returns (uint256) {
        return token.balanceOf(_user);
    }
}
