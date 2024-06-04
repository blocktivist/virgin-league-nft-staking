// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Script} from "forge-std/Script.sol";
import {MockERC721A} from "../src/MockERC721A.sol";
import {VirginLeagueStaking} from "../src/VirginLeagueStaking.sol";

contract DeployVirginLeagueStaking is Script {
    function run() external {
        deployVirginLeagueStakingOnBaseSepolia();
        // deployVirginLeagueStakingOnBase();
    }

    function deployVirginLeagueStakingOnBaseSepolia() public returns (MockERC721A, VirginLeagueStaking) {
        uint256 pointsPerDay = 1;
        string memory uri = "ipfs://bafybeicttntytjyvgco4s6q2qa2753243bo65vvqhbwjew7wxz7ccddwau/";

        vm.startBroadcast();
        MockERC721A mockERC721A = new MockERC721A();
        VirginLeagueStaking virginLeagueStaking = new VirginLeagueStaking(address(mockERC721A), pointsPerDay, uri);
        vm.stopBroadcast();

        return (mockERC721A, virginLeagueStaking);
    }

    function deployVirginLeagueStakingOnBase() public returns (VirginLeagueStaking) {
        address virginLeagueContract = 0x338c686291C616797727518028905B526973F8a2;
        uint256 pointsPerDay = 1;
        string memory uri = "ipfs://bafybeicttntytjyvgco4s6q2qa2753243bo65vvqhbwjew7wxz7ccddwau/";

        vm.startBroadcast();
        VirginLeagueStaking virginLeagueStaking = new VirginLeagueStaking(virginLeagueContract, pointsPerDay, uri);
        vm.stopBroadcast();

        return virginLeagueStaking;
    }
}
