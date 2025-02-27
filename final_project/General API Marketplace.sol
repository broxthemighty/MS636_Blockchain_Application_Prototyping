// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 <0.9.0;

/**Created by Matt Lindborg
 * UAT MS636 Final Project
 * @title GeneralApiMarketplace
 * @dev General API Marketplace
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// dummy ERC20 token for testing
contract DummyToken is IERC20 {

    string public name = "Dummy Token";
    string public symbol = "DMT";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;

    constructor(uint256 initialSupply) {
        mint(msg.sender, initialSupply);
    }

    function balanceOf(address account) public view override returns (uint256) {
        return balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        balances[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        require(balances[sender] >= amount, "Insufficient balance");
        require(allowances[sender][msg.sender] >= amount, "Allowance exceeded");
        balances[sender] -= amount;
        allowances[sender][msg.sender] -= amount;
        balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return allowances[owner][spender];
    }

    // mints tokens to a specified account (for testing purposes only).
    function mint(address account, uint256 amount) public {
        totalSupply += amount;
        balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }
}

// General API Marketplace contract
contract GeneralApiMarketplace {

    // State variables
    IERC20 public token; 
    address public owner; 

    // API access strucutre
    struct APIAccess {
        string name; 
        uint256 pricePerRequest; 
        uint256 totalPurchases; 
        bool isActive;
    }

    struct UserUsage {
        // API ID => remaining requests
        mapping(uint256 => uint256) remainingRequests; 
    }

    // counter for assigning unique API IDs
    uint256 public apiIdCounter; 

    // API ID => API details
    mapping(uint256 => APIAccess) public apis; 

    // user address => API usage
    mapping(address => UserUsage) private userUsages; 

    // events
    event APIRegistered(uint256 apiId, string name, uint256 pricePerRequest);
    event APIUpdated(uint256 apiId, uint256 pricePerRequest, bool isActive);
    event APIAccessPurchased(address user, uint256 apiId, uint256 requests);
    event APICallMade(address user, uint256 apiId);
    event WithdrawalFailed(address to, uint256 amount);
    event WithdrawalSuccessful(address to, uint256 amount);

    // initializes the contract with the token address and sets the owner
    constructor(IERC20 _token) {
        require(address(_token) != address(0), "Invalid token address");
        token = _token;
        owner = msg.sender;
    }

    // registers a new API with a price per request
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

    // updates the details of an existing API
    function updateAPI(uint256 _apiId, uint256 _pricePerRequest, bool _isActive) external onlyOwner {
        require(_apiId < apiIdCounter, "API does not exist");
        require(_pricePerRequest > 0, "Price per request must be greater than zero");

        APIAccess storage api = apis[_apiId];
        api.pricePerRequest = _pricePerRequest;
        api.isActive = _isActive;

        emit APIUpdated(_apiId, _pricePerRequest, _isActive);
    }

    // purchases API access for a specific number of requests
    function purchaseAPIAccess(uint256 _apiId, uint256 _requests) external {
        require(_apiId < apiIdCounter, "API does not exist");
        require(_requests > 0, "Number of requests must be greater than zero");

        APIAccess storage api = apis[_apiId];
        require(api.isActive, "API is not active");

        uint256 totalCost = api.pricePerRequest * _requests;

        // attempt to transfer tokens from the user to the contract
        try token.transferFrom(msg.sender, address(this), totalCost) {
            // update user usage
            userUsages[msg.sender].remainingRequests[_apiId] += _requests;
            api.totalPurchases += _requests;

            emit APIAccessPurchased(msg.sender, _apiId, _requests);
        } catch Error(string memory reason) {
            revert(reason); // revert with the specific error reason from the token contract
        } catch {
            revert("Token transfer failed.");
        }

    }

    // records an API call by a user, deducting one request from their balance
    function useAPIAccess(uint256 _apiId) external {
        require(_apiId < apiIdCounter, "API does not exist");

        APIAccess storage api = apis[_apiId];
        require(api.isActive, "API is not active");

        uint256 remaining = userUsages[msg.sender].remainingRequests[_apiId];
        require(remaining > 0, "No remaining API requests");

        // deduct one request from the user's balance
        userUsages[msg.sender].remainingRequests[_apiId] -= 1;

        emit APICallMade(msg.sender, _apiId);
    }

    // gets the remaining requests for a user on a specific API
    function getRemainingRequests(address _user, uint256 _apiId) external view returns (uint256) {
        require(_apiId < apiIdCounter, "API does not exist");
        return userUsages[_user].remainingRequests[_apiId];
    }

    // withdraws the collected tokens to the owner's wallet
    function withdrawTokens() external onlyOwner {
        uint256 balance = token.balanceOf(address(this));
        require(balance > 0, "No tokens to withdraw");

         try token.transfer(owner, balance) {
            emit WithdrawalSuccessful(owner, balance);
        } catch Error(string memory reason) {
            emit WithdrawalFailed(owner, balance);
            revert(reason); // revert with the specific error reason from the token contract
        } catch {
            emit WithdrawalFailed(owner, balance);
            revert("Token transfer failed.");
        }

    }

    // modifier to restrict access to only the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }
}
