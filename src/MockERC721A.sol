// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {ERC721A} from "erc721a/ERC721A.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title MockERC721A
contract MockERC721A is ERC721A, Ownable {
    /// Constructor ///
    constructor() ERC721A("MockERC721A", "MOCK") Ownable(msg.sender) {}

    /// External functions ///
    /// @notice Mints multiple NFTs
    /// @param _to Address of the recipient
    /// @param _quantity Quantity of mints
    function mint(address _to, uint256 _quantity) external {
        _mint(_to, _quantity);
    }
}
