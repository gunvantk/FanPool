// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

// Compound contract interface to supply ETH
interface CEth {
    function mint() external payable;

    function exchangeRateCurrent() external returns (uint256);

    function supplyRatePerBlock() external returns (uint256);

    function redeem(uint256) external returns (uint256);

    function redeemUnderlying(uint256) external returns (uint256);

    function balanceOf(address) external returns (uint256);
}

/**
 * Contract for the FanPool app, Provide ability to
 * Enroll creator on platform
 * Allows fans to deposit money
 * Lend ETH collected to Compound App for yield generation
 * Allows fans to withdraw their original capital back
 * Allows creators to withdraw yield generated for their pool
 */
contract FanPool {
    struct Creator {
        string Name;
        string SocialUrl;
        uint256 TotalDeposits;
        uint256 TotalYieldPaid;
        uint256 TotalCEtch;
        bool IsExist; // This allows to see if creator exist in map while Guard check
    }

    event MyLog(string, uint256);
    // Allows lookup for creator by their address
    mapping(address => Creator) public creators;
    address[] public allCreators;
    // Allows access to creator pool by their address, value of this mapping provides ability to check deposits amount by each fan
    mapping(address => mapping(address => uint256)) public creatorPool;

    // Holds one-to-many relation for Fan and their enrolled Pool
    mapping(address => address[]) public userSubscribedPool;

    function onBoardCreator(string memory name, string memory socialUrl)
        public
        returns (bool)
    {
        Creator memory newCreator = Creator(name, socialUrl, 0, 0, 0, true);
        creators[msg.sender] = newCreator;
        allCreators.push(msg.sender);
        return true;
    }

    /**
     * Get the details of the pool
     * @param creatorAddress The address of the creator
     * return values Provides details like Name, SocialUrl, Total deposits made into the pool, total Yield paid so far,
     * Current Yield generated for the pool and maxium withdrawal amount. In case of Creator maxWithdrawalAvailable will be interest genrerated for the pool,
     * In case of a fan it will be the amount they deposited originally
     */
    function getPoolByCreator(address creatorAddress)
        public
        view
        returns (
            address cAddress,
            string memory name,
            string memory socialUrl,
            uint256 totalDeposits,
            uint256 totalYieldPaid,
            uint256 maxWithdrawalAvailable,
            uint256 totalCEtch
        )
    {
        Creator memory creator = creators[creatorAddress];
        cAddress = creatorAddress;
        name = creator.Name;
        socialUrl = creator.SocialUrl;
        totalDeposits = creator.TotalDeposits;
        totalYieldPaid = creator.TotalYieldPaid;
        totalCEtch = creator.TotalCEtch;
        if (msg.sender == creatorAddress) {
            maxWithdrawalAvailable = 0;
        } else {
            maxWithdrawalAvailable = creatorPool[creatorAddress][msg.sender];
        }
    }

    // Gives list of pool user has participated in
    function getPoolsSubscribedByUser() public view returns (address[] memory) {
        return userSubscribedPool[msg.sender];
    }

    function getAllPools() public view returns (address[] memory) {
        return allCreators;
    }

    function calculateInterest(uint256 originalBalance, uint256 cEth)
        public
        returns (uint256)
    {
        CEth cToken = CEth(0xd6801a1DfFCd0a410336Ef88DeF4320D6DF1883e);

        // Amount of current exchange rate from cToken to underlying
        uint256 exchangeRateMantissa = (cToken.exchangeRateCurrent()) / 1e18;
        uint256 underlyingBalance = cEth * exchangeRateMantissa;
        return underlyingBalance - originalBalance;
    }

    /**
     * Deposit ether into the creator Pool
     * @param creatorAddress The address of the creator amount to deposit amount to
     * @param _cEtherContract The compound contract address for ETH
     * @return Whether or not the deposit succeeded
     */
    function deposit(address creatorAddress, address payable _cEtherContract)
        public
        payable
        returns (bool)
    {
        require(creatorAddress != address(0), "Invalid creator Address");
        require(
            creatorAddress != msg.sender,
            "Creator cannot deposit ETH in the pool started by them"
        );
        require(msg.value != 0, "Amount should be greater than 0.");
        require(
            creators[creatorAddress].IsExist,
            "Creator should be enrolled in the system."
        );

        creatorPool[creatorAddress][msg.sender] += msg.value;
        creators[creatorAddress].TotalDeposits += msg.value;
        userSubscribedPool[msg.sender].push(creatorAddress);
        CEth cToken = CEth(_cEtherContract);
        uint256 tokensBefore = cToken.balanceOf(address(this));
        supplyEthToCompound(_cEtherContract, msg.value);
        uint256 tokensAfter = cToken.balanceOf(address(this));
        uint256 newTokens = tokensAfter - tokensBefore;
        creators[creatorAddress].TotalCEtch += newTokens;
        return true;
    }

    /**
     * Withdraw ETH from the creator Pool, can be performed by Creator or Fan
     * @param creatorAddress The address of the creator amount to deposit amount to
     * @param _cEtherContract The compound contract address for ETH
     */
    function withdraw(
        address creatorAddress,
        uint256 amount,
        address payable _cEtherContract
    ) public {
        require(creatorAddress != address(0), "Invalid creator Address");
        require(amount != 0, "Amount should be greater than 0.");
        require(
            creators[creatorAddress].IsExist,
            "Creator should be enrolled in the system."
        );
        if (msg.sender == creatorAddress) {
            //Todo cannot be greater than pool yield
        } else {
            require(
                creatorPool[creatorAddress][msg.sender] >= amount,
                "Amount cannot be greater than deposits."
            );
        }

        creatorPool[creatorAddress][msg.sender] -= amount;
        creators[creatorAddress].TotalDeposits -= amount;

        CEth cToken = CEth(_cEtherContract);
        uint256 tokensBefore = cToken.balanceOf(address(this));
        redeemCEth(amount, false, _cEtherContract);
        uint256 tokensAfter = cToken.balanceOf(address(this));
        uint256 tokensReedemed = tokensBefore - tokensAfter;
        creators[creatorAddress].TotalCEtch -= tokensReedemed;

        address payable to = payable(msg.sender);
        (bool sent, bytes memory data) = to.call{value: amount}("");
        require(sent, "Failed to withdraw Ether");
    }

    function checkPoolBalanceByUser(address creatorAddress)
        public
        view
        returns (uint256)
    {
        return creatorPool[creatorAddress][msg.sender];
    }

    function checkPoolBalanceByCreator(address creatorAddress)
        public
        view
        returns (uint256)
    {
        return creatorPool[creatorAddress][msg.sender];
    }

    // Total ETH Balance of the contract
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // Lend ETH to Compound to generate yield, compound provides cETH ERC20 token based on current exchange rate
    function supplyEthToCompound(
        address payable _cEtherContract,
        uint256 amount
    ) private returns (bool) {
        CEth cToken = CEth(_cEtherContract);

        // Amount of current exchange rate from cToken to underlying
        uint256 exchangeRateMantissa = cToken.exchangeRateCurrent();
        emit MyLog("Exchange Rate (scaled up by 1e18): ", exchangeRateMantissa);

        // Amount added to you supply balance this block
        uint256 supplyRateMantissa = cToken.supplyRatePerBlock();
        emit MyLog("Supply Rate: (scaled up by 1e18)", supplyRateMantissa);

        cToken.mint{value: amount, gas: 250000}();
        return true;
    }

    // Withdraw ETH from Compound, Compound need cETH ERC20 token back to return the capital in ETH
    function redeemCEth(
        uint256 amount,
        bool redeemType,
        address _cEtherContract
    ) private returns (bool) {
        CEth cToken = CEth(_cEtherContract);

        // `amount` is scaled up by 1e18 to avoid decimals
        uint256 redeemResult;

        if (redeemType == true) {
            // Retrieve your asset based on a cToken amount
            redeemResult = cToken.redeem(amount);
        } else {
            // Retrieve your asset based on an amount of the asset
            redeemResult = cToken.redeemUnderlying(amount);
        }

        // Error codes are listed here:
        // https://compound.finance/docs/ctokens#ctoken-error-codes
        emit MyLog("If this is not 0, there was an error", redeemResult);

        return true;
    }

    fallback() external payable {}

    // This is needed to receive ETH to wallet
    receive() external payable {}
}
