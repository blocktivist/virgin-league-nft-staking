// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {MockERC721A} from "../src/MockERC721A.sol";
import {VirginLeagueStaking} from "../src/VirginLeagueStaking.sol";
import {DeployVirginLeagueStaking} from "../script/DeployVirginLeagueStaking.s.sol";

contract VirginLeagueStakingTest is Test {
    MockERC721A public mockERC721A;
    VirginLeagueStaking public virginLeagueStaking;

    address public user = address(1);
    address public attacker = address(2);

    function setUp() external {
        DeployVirginLeagueStaking deployVirginLeagueStaking = new DeployVirginLeagueStaking();
        (mockERC721A, virginLeagueStaking) = deployVirginLeagueStaking.deployVirginLeagueStakingOnBaseSepolia();
    }

    function testStakeSingleTokenWithApprove() external {
        // Mint a token to the user
        vm.startPrank(user);
        mockERC721A.mint(user, 1);
        // Approve the staking contract to transfer the token
        mockERC721A.approve(address(virginLeagueStaking), 0);
        // Stake the token
        uint256[] memory token = new uint256[](1);
        token[0] = 0;
        virginLeagueStaking.stake(token);
        assert(virginLeagueStaking.ownerOf(0) == user);
        assert(mockERC721A.ownerOf(0) == address(virginLeagueStaking));
    }

    function testStakeSingleTokenWithApprovalForAll() external {
        // Mint a token to the user
        vm.startPrank(user);
        mockERC721A.mint(user, 1);
        // Approve the staking contract to transfer the token
        mockERC721A.setApprovalForAll(address(virginLeagueStaking), true);
        // Stake the token
        uint256[] memory token = new uint256[](1);
        token[0] = 0;
        virginLeagueStaking.stake(token);
        assert(virginLeagueStaking.ownerOf(0) == user);
        assert(mockERC721A.ownerOf(0) == address(virginLeagueStaking));
    }

    function testStakeMultipleTokens() external {
        // Mint 3 tokens to the user
        vm.startPrank(user);
        mockERC721A.mint(user, 3);
        // Approve the staking contract to transfer the tokens
        mockERC721A.setApprovalForAll(address(virginLeagueStaking), true);
        // Stake the tokens
        uint256[] memory tokens = new uint256[](3);
        tokens[0] = 0;
        tokens[1] = 1;
        tokens[2] = 2;
        virginLeagueStaking.stake(tokens);
        assert(virginLeagueStaking.ownerOf(0) == user);
        assert(virginLeagueStaking.ownerOf(1) == user);
        assert(virginLeagueStaking.ownerOf(2) == user);
        assert(mockERC721A.ownerOf(0) == address(virginLeagueStaking));
        assert(mockERC721A.ownerOf(1) == address(virginLeagueStaking));
        assert(mockERC721A.ownerOf(2) == address(virginLeagueStaking));
    }

    function testStakeAccessControl() external {
        // Mint a token to the user
        vm.startPrank(user);
        mockERC721A.mint(user, 1);
        // Approve the staking contract to transfer the token
        mockERC721A.setApprovalForAll(address(virginLeagueStaking), true);
        // Try to stake the token as the attacker
        vm.startPrank(attacker);
        uint256[] memory token = new uint256[](1);
        token[0] = 0;
        vm.expectRevert();
        virginLeagueStaking.stake(token);
    }

    function testStakeWhenContractIsPaused() external {
        // Mint a token to the user
        vm.startPrank(user);
        mockERC721A.mint(user, 1);
        // Approve the staking contract to transfer the token
        mockERC721A.setApprovalForAll(address(virginLeagueStaking), true);
        // Pause the contract
        vm.startPrank(virginLeagueStaking.owner());
        virginLeagueStaking.pause();
        // Try to stake the token
        vm.startPrank(user);
        uint256[] memory token = new uint256[](1);
        token[0] = 0;
        vm.expectRevert();
        virginLeagueStaking.stake(token);
    }

    function testUnstakeSingleToken() external {
        // Mint a token to the user
        vm.startPrank(user);
        mockERC721A.mint(user, 1);
        // Approve the staking contract to transfer the tokens
        mockERC721A.setApprovalForAll(address(virginLeagueStaking), true);
        // Stake the token
        uint256[] memory token = new uint256[](1);
        token[0] = 0;
        virginLeagueStaking.stake(token);
        // Unstake the token
        virginLeagueStaking.unstake(token);
        assert(mockERC721A.ownerOf(0) == user);
    }

    function testUnstakeMultipleTokens() external {
        // Mint 3 tokens to the user
        vm.startPrank(user);
        mockERC721A.mint(user, 3);
        // Approve the staking contract to transfer the token
        mockERC721A.setApprovalForAll(address(virginLeagueStaking), true);
        // Stake the tokens
        uint256[] memory tokens = new uint256[](3);
        tokens[0] = 0;
        tokens[1] = 1;
        tokens[2] = 2;
        virginLeagueStaking.stake(tokens);
        // Unstake the token
        virginLeagueStaking.unstake(tokens);
        assert(mockERC721A.ownerOf(0) == user);
        assert(mockERC721A.ownerOf(1) == user);
        assert(mockERC721A.ownerOf(2) == user);
    }

    function testUnstakeAccessControl() external {
        // Mint a token to the user
        vm.startPrank(user);
        mockERC721A.mint(user, 1);
        // Approve the staking contract to transfer the tokens
        mockERC721A.setApprovalForAll(address(virginLeagueStaking), true);
        // Stake the token
        uint256[] memory token = new uint256[](1);
        token[0] = 0;
        virginLeagueStaking.stake(token);
        // Try to unstake the token as the attacker
        vm.startPrank(attacker);
        vm.expectRevert();
        virginLeagueStaking.unstake(token);
    }

    function testUnstakeUnownedToken() external {
        // Mint a token to the user
        vm.startPrank(user);
        mockERC721A.mint(user, 1);
        // Approve the staking contract to transfer the token
        mockERC721A.setApprovalForAll(address(virginLeagueStaking), true);
        // Stake the token
        uint256[] memory userToken = new uint256[](1);
        userToken[0] = 0;
        virginLeagueStaking.stake(userToken);
        // Mint a token to the attacker
        vm.startPrank(attacker);
        mockERC721A.mint(attacker, 1);
        // Approve the staking contract to transfer the token
        mockERC721A.setApprovalForAll(address(virginLeagueStaking), true);
        // Stake the token
        uint256[] memory attackerToken = new uint256[](1);
        attackerToken[0] = 1;
        virginLeagueStaking.stake(attackerToken);
        // Try to unstake boths tokens as the attacker
        vm.expectRevert();
        uint256[] memory tokens = new uint256[](2);
        tokens[0] = 0;
        tokens[1] = 1;
        virginLeagueStaking.unstake(tokens);
    }

    function testOwnerUnstakeSingleToken() external {
        // Mint a token to the user
        vm.startPrank(user);
        mockERC721A.mint(user, 1);
        // Approve the staking contract to transfer the tokens
        mockERC721A.setApprovalForAll(address(virginLeagueStaking), true);
        // Stake the token
        uint256[] memory token = new uint256[](1);
        token[0] = 0;
        virginLeagueStaking.stake(token);
        // Pause the contract
        vm.startPrank(virginLeagueStaking.owner());
        virginLeagueStaking.pause();
        // Unstake the token as the owner
        virginLeagueStaking.ownerUnstake(token);
        assert(mockERC721A.ownerOf(0) == user);
    }

    function testOwnerUnstakeMultipleTokens() external {
        // Mint 3 tokens to the user
        vm.startPrank(user);
        mockERC721A.mint(user, 3);
        // Approve the staking contract to transfer the token
        mockERC721A.setApprovalForAll(address(virginLeagueStaking), true);
        // Stake the tokens
        uint256[] memory tokens = new uint256[](3);
        tokens[0] = 0;
        tokens[1] = 1;
        tokens[2] = 2;
        virginLeagueStaking.stake(tokens);
        // Pause the contract
        vm.startPrank(virginLeagueStaking.owner());
        virginLeagueStaking.pause();
        // Unstake the token as the owner
        virginLeagueStaking.ownerUnstake(tokens);
        assert(mockERC721A.ownerOf(0) == user);
        assert(mockERC721A.ownerOf(1) == user);
        assert(mockERC721A.ownerOf(2) == user);
    }

    function testTransferTokenWithTransferFrom() external {
        // Mint a token to the user
        vm.startPrank(user);
        mockERC721A.mint(user, 1);
        // Approve the staking contract to transfer the token
        mockERC721A.setApprovalForAll(address(virginLeagueStaking), true);
        // Stake the token
        uint256[] memory token = new uint256[](1);
        token[0] = 0;
        virginLeagueStaking.stake(token);
        // Try to transfer the replacing token
        vm.expectRevert();
        virginLeagueStaking.transferFrom(user, attacker, 0);
    }

    function testTransferTokenWithSafeTransferFrom() external {
        // Mint a token to the user
        vm.startPrank(user);
        mockERC721A.mint(user, 1);
        // Approve the staking contract to transfer the token
        mockERC721A.setApprovalForAll(address(virginLeagueStaking), true);
        // Stake the token
        uint256[] memory token = new uint256[](1);
        token[0] = 0;
        virginLeagueStaking.stake(token);
        // Try to transfer the replacing token
        vm.expectRevert();
        virginLeagueStaking.safeTransferFrom(user, attacker, 0);
    }

    function testTransferTokenWithSafeTransferFromAlt() external {
        // Mint a token to the user
        vm.startPrank(user);
        mockERC721A.mint(user, 1);
        // Approve the staking contract to transfer the token
        mockERC721A.setApprovalForAll(address(virginLeagueStaking), true);
        // Stake the token
        uint256[] memory token = new uint256[](1);
        token[0] = 0;
        virginLeagueStaking.stake(token);
        // Try to transfer the replacing token
        vm.expectRevert();
        virginLeagueStaking.safeTransferFrom(user, attacker, 0, "");
    }

    function testBurnTokenAccidentally() external {
        // Mint a token to the user
        vm.startPrank(user);
        mockERC721A.mint(user, 1);
        // Try to accidentally burns the token
        vm.expectRevert();
        mockERC721A.transferFrom(user, address(0), 0);
    }

    function testClaimPoints() external {
        // Mint a token to the user
        vm.startPrank(user);
        mockERC721A.mint(user, 1);
        // Approve the staking contract to transfer the token
        mockERC721A.setApprovalForAll(address(virginLeagueStaking), true);
        // Stake the token
        uint256[] memory token = new uint256[](1);
        token[0] = 0;
        virginLeagueStaking.stake(token);
        // Unstake the token
        uint256 duration = 1000;
        vm.warp(block.timestamp + duration);
        virginLeagueStaking.unstake(token);
        // Check the points
        uint256 expectedPoints = ((duration * 10 ** 4) * 1) / 1 days;
        console.log(expectedPoints);
        assertEq(virginLeagueStaking.points(user), expectedPoints);
    }

    function testSetPointsPerDay() external {
        // Set the points per day to 2
        vm.startPrank(virginLeagueStaking.owner());
        virginLeagueStaking.setPointsPerDay(2);
        // Mint a token to the user
        vm.startPrank(user);
        mockERC721A.mint(user, 1);
        // Approve the staking contract to transfer the token
        mockERC721A.setApprovalForAll(address(virginLeagueStaking), true);
        // Stake the token
        uint256[] memory token = new uint256[](1);
        token[0] = 0;
        virginLeagueStaking.stake(token);
        // Unstake the token
        uint256 duration = 1000;
        vm.warp(block.timestamp + duration);
        virginLeagueStaking.unstake(token);
        // Check the points
        uint256 expectedPoints = ((duration * 10 ** 4) * 2) / 1 days;
        console.log(expectedPoints);
        assertEq(virginLeagueStaking.points(user), expectedPoints);
    }

    function testSetBaseURI() external {
        // Set the base URI
        vm.startPrank(virginLeagueStaking.owner());
        virginLeagueStaking.setBaseURI("ipfs://anotherexample.com/");
        // Mint a token to the user
        vm.startPrank(user);
        mockERC721A.mint(user, 1);
        // Approve the staking contract to transfer the token
        mockERC721A.setApprovalForAll(address(virginLeagueStaking), true);
        // Stake the token
        uint256[] memory token = new uint256[](1);
        token[0] = 0;
        virginLeagueStaking.stake(token);
        // Check the token URI
        string memory uri = virginLeagueStaking.tokenURI(0);
        assertEq(uri, "ipfs://anotherexample.com/0");
    }
}
