// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {IERC721A} from "erc721a/IERC721A.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";

/// @title VirginLeagueStaking
contract VirginLeagueStaking is ERC721, ERC721Enumerable, Pausable, Ownable {
    /// Custom errors ///
    error NotTheOwner();
    error NotTheStaker();
    error NotTransferable();

    /// Virgin League NFT contract ///
    IERC721A public virginLeagueContract;

    /// State variables ///
    uint256 public pointsPerDay;
    uint256 public multiplierPerTenDays;
    string private _baseTokenURI;

    /// Mappings ///
    mapping(uint256 tokenId => uint256 timestamp) public stakingStartTime;
    mapping(address account => uint256 balance) public points;

    /// Events ///
    event Staked(address indexed account, uint256 tokenId, uint256 timestamp);
    event Unstaked(address indexed account, uint256 tokenId, uint256 timestamp);
    event PointsClaimed(address indexed account, uint256 tokenId, uint256 points, uint256 timestamp);

    /// Constructor ///
    /// @param _virginLeagueContract Address of the Virgin League NFT contract
    /// @param _pointsPerDay Points per day
    /// @param _multiplierPerTenDays Point multiplier per ten days
    /// @param _uri Base URI
    constructor(address _virginLeagueContract, uint256 _pointsPerDay, uint256 _multiplierPerTenDays, string memory _uri)
        ERC721("StakedVirgin", "STVL")
        Ownable(msg.sender)
    {
        virginLeagueContract = IERC721A(_virginLeagueContract);
        pointsPerDay = _pointsPerDay;
        multiplierPerTenDays = _multiplierPerTenDays;
        _baseTokenURI = _uri;
    }

    /// External functions ///
    /// @notice Stakes multiple Virgin League NFTs and mints the corresponding STVL NFTs
    /// @dev Can only be called when the contract is not paused
    /// @dev Requires approval from the Virgin League NFT contract for each tokenId
    /// @param _tokenIds Array of IDs of the Virgin League NFTs
    function stake(uint256[] calldata _tokenIds) external whenNotPaused {
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            uint256 tokenId = _tokenIds[i];
            if (virginLeagueContract.ownerOf(tokenId) != msg.sender) revert NotTheOwner();

            stakingStartTime[tokenId] = block.timestamp;

            _mint(msg.sender, tokenId);
            virginLeagueContract.transferFrom(msg.sender, address(this), tokenId);

            emit Staked(msg.sender, tokenId, block.timestamp);
        }
    }

    /// @notice Unstakes multiple Virgin League NFTs and burns the corresponding STVL NFTs
    /// @dev Can be called even when the contract is paused
    /// @param _tokenIds Array of IDs of the Virgin League NFTs
    function unstake(uint256[] calldata _tokenIds) external {
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            uint256 tokenId = _tokenIds[i];
            if (ownerOf(tokenId) != msg.sender) revert NotTheStaker();

            _claimPoints(tokenId);

            _burn(tokenId);
            virginLeagueContract.transferFrom(address(this), msg.sender, tokenId);

            emit Unstaked(msg.sender, tokenId, block.timestamp);
        }
    }

    /// @notice Unstakes multiple Virgin League NFTs and burns the corresponding STVL NFTs
    /// @dev Can only be called by the owner and when the contract is paused
    /// @param _tokenIds Array of IDs of the Virgin League NFTs to unstake
    function ownerUnstake(uint256[] calldata _tokenIds) external onlyOwner whenPaused {
        for (uint256 i = 0; i < _tokenIds.length; i++) {
            uint256 tokenId = _tokenIds[i];
            address staker = ownerOf(tokenId);
            if (staker != address(0)) {
                _claimPoints(tokenId);

                _burn(tokenId);
                virginLeagueContract.transferFrom(address(this), staker, tokenId);

                emit Unstaked(staker, tokenId, block.timestamp);
            }
        }
    }

    /// @notice Pauses the VirginLeagueStaking contract
    /// @dev Can only be called by the owner
    function pause() external onlyOwner {
        _pause();
    }

    /// @notice Unpauses the VirginLeagueStaking contract
    /// @dev Can only be called by the owner
    function unpause() external onlyOwner {
        _unpause();
    }

    /// @notice Sets the points per day
    /// @dev Can only be called by the owner
    /// @param _pointsPerDay Points per day
    function setPointsPerDay(uint256 _pointsPerDay) external onlyOwner {
        pointsPerDay = _pointsPerDay;
    }

    /// @notice Sets the point multiplier per ten days
    /// @dev Can only be called by the owner
    /// @param _multiplierPerTenDays Point multiplier per ten days
    function setMultiplierPerTenDays(uint256 _multiplierPerTenDays) external onlyOwner {
        multiplierPerTenDays = _multiplierPerTenDays;
    }

    /// @notice Sets the base URI
    /// @dev Can only be called by the owner
    /// @param _uri Base URI
    function setBaseURI(string calldata _uri) external onlyOwner {
        _baseTokenURI = _uri;
    }

    /// @notice Returns an array of token IDs owned by an STVL owner
    /// @param owner Address of the STVL owner
    /// @return tokenIds Array of token IDs
    function tokensOfOwner(address owner) external view returns (uint256[] memory) {
        uint256 tokenCount = balanceOf(owner);
        uint256[] memory tokenIds = new uint256[](tokenCount);
        for (uint256 i = 0; i < tokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(owner, i);
        }

        return tokenIds;
    }

    /// Public functions ///
    /// @notice Overrides the supportsInterface function
    /// @dev See {ERC721-supportsInterface}
    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /// Internal functions ///
    /// @notice Overrides the _update function to prevent transfers of the STVL token
    /// @dev See {ERC721-_update}
    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721, ERC721Enumerable)
        returns (address)
    {
        if (auth != address(0) && to != address(0)) revert NotTransferable();

        return super._update(to, tokenId, auth);
    }

    /// @notice Overrides the _increaseBalance function
    /// @dev See {ERC721-_increaseBalance}
    function _increaseBalance(address account, uint128 value) internal override(ERC721, ERC721Enumerable) {
        super._increaseBalance(account, value);
    }

    /// @notice Overrides the _baseURI function
    /// @dev See {ERC721-_baseURI}
    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }

    /// Private functions ///
    /// @notice Claims points for a staked Virgin League NFT
    /// @param _tokenId ID of the Virgin League NFT
    function _claimPoints(uint256 _tokenId) private {
        uint256 stakingDuration = block.timestamp - stakingStartTime[_tokenId];
        uint256 earnedPoints = _calculatePoints(stakingDuration);
        delete stakingStartTime[_tokenId];
        points[ownerOf(_tokenId)] += earnedPoints;

        emit PointsClaimed(ownerOf(_tokenId), _tokenId, earnedPoints, block.timestamp);
    }

    /// @notice Calculates the points for a staked Virgin League NFT
    /// @dev `daysStaked` are rounded down to the nearest day
    /// @dev `multiplier` is designed to increment every 10 days
    /// @param _duration Staking duration
    /// @return calculatedPoints Points earned in 4 decimal precision
    function _calculatePoints(uint256 _duration) private view returns (uint256) {
        uint256 daysStaked = _duration / 1 days;
        uint256 multiplier = (daysStaked / 10) * multiplierPerTenDays;
        uint256 calculatedPoints = ((_duration * 10 ** 4) * (pointsPerDay * 100 + multiplier)) / (1 days * 100);

        return calculatedPoints;
    }
}
