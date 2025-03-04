// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**Created by Matt Lindborg
 * UAT MS636 Week 7
 * @title General API Marketplace Token
 * @dev General API Marketplace Contract
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */

// API marketplace contract, using tokens as currency
contract GeneralApiMarketplaceToken is ReentrancyGuard {
    using SafeERC20 for IERC20;

    // state variables
    IERC20 public immutable token;
    address public owner;

    // API access struct
    struct APIAccess {
        string name;
        uint256 pricePerRequest;
        uint256 totalPurchases;
        bool isActive;
    }

    // user usage struct, of map of remainingRequests
    struct UserUsage {
        mapping(uint256 => uint256) remainingRequests;
    }

    // API id counter
    uint256 public apiIdCounter;

    // map of APIs
    mapping(uint256 => APIAccess) public apis;

    // map of user usages
    mapping(address => UserUsage) private userUsages;

    // events, using indexed
    event APIRegistered(uint256 indexed apiId, string name, uint256 pricePerRequest);
    event APIAccessPurchased(address indexed user, uint256 indexed apiId, uint256 requests);
    event APICallMade(address indexed user, uint256 indexed apiId);
    event TokensWithdrawn(address indexed owner, uint256 amount);

    // constructor, using a token
    constructor(IERC20 _token) {
        require(address(_token) != address(0), "Invalid token address");
        token = _token;
        owner = msg.sender;
    }

    // only owner modifier
    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    // register API function
    function registerAPI(string memory _name, uint256 _pricePerRequest) external onlyOwner {
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

    // purchase API access function
    function purchaseAPIAccess(uint256 _apiId, uint256 _requests) external {
        require(_apiId < apiIdCounter, "API does not exist");
        require(_requests > 0, "Number of requests must be greater than zero");

        APIAccess storage api = apis[_apiId];
        require(api.isActive, "API is not active");

        uint256 totalCost = api.pricePerRequest * _requests;

        // prevent potential overflow in multiplication
        require(totalCost / _requests == api.pricePerRequest, "Overflow detected");

        // transfer tokens from user to contract
        token.safeTransferFrom(msg.sender, address(this), totalCost);

        userUsages[msg.sender].remainingRequests[_apiId] += _requests;
        api.totalPurchases += _requests;

        emit APIAccessPurchased(msg.sender, _apiId, _requests);
    }

    // use API access function
    function useAPIAccess(uint256 _apiId) external {
        require(_apiId < apiIdCounter, "API does not exist");

        APIAccess storage api = apis[_apiId];
        require(api.isActive, "API is not active");

        uint256 remaining = userUsages[msg.sender].remainingRequests[_apiId];
        require(remaining > 0, "No remaining API requests");

        userUsages[msg.sender].remainingRequests[_apiId] -= 1;

        emit APICallMade(msg.sender, _apiId);
    }

    // withdraw tokens function
    function withdrawTokens() external onlyOwner nonReentrant {
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, "No tokens to withdraw");

        token.safeTransfer(owner, balance);

        emit TokensWithdrawn(owner, balance);
    }

    // get remaining requests function
    function getRemainingRequests(address _user, uint256 _apiId) external view returns (uint256) {
        require(_apiId < apiIdCounter, "API does not exist");
        return userUsages[_user].remainingRequests[_apiId];
    }
}
