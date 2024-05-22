// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

// Open zeppelin upgradeable dependencies
import { ERC20PermitUpgradeable } from "@openzeppelin-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import { ERC20BurnableUpgradeable } from "@openzeppelin-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import { OwnableUpgradeable } from "@openzeppelin-upgradeable/access/OwnableUpgradeable.sol";
import { UUPSUpgradeable } from "@openzeppelin-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract ZarosToken is UUPSUpgradeable, OwnableUpgradeable, ERC20PermitUpgradeable, ERC20BurnableUpgradeable {
    /// @notice Maps users allowed to mint tokens.
    mapping(address user => bool isAllowed) isMinter;

    error NotMinter();

    /// @notice Emitted when a new minter is set or unset.
    /// @param user Address of the minter
    /// @param isAllowed True if the user is allowed to mint tokens
    event LogSetIsMinter(address indexed user, bool isAllowed);

    /// @notice Emitted when tokens are minted
    /// @param to Minted ZRS recipient
    /// @param amount Amount of ZRS to be minted
    event LogMint(address indexed to, uint256 amount);

    function initialize(address _owner, string memory _name, string memory _symbol) external initializer {
        __ERC20_init(_name, _symbol);
        __ERC20Permit_init(_name);
        __Ownable_init(_owner);
    }

    /// @notice Allows or disallows a given address to be a minter.
    /// @dev Only the contract owner can call this function.
    /// @param user Address of the user.
    /// @param isAllowed True if the user is allowed to mint tokens
    function setIsMinter(address user, bool isAllowed) external onlyOwner {
        isMinter[user] = isAllowed;

        emit LogSetIsMinter(user, isAllowed);
    }

    /// @notice Mints ZRS tokens to the given address
    /// @param to Minted ZRS recipient
    /// @param amount Amount of ZRS to be minted
    function mint(address to, uint256 amount) external {
        if (!isMinter[msg.sender]) {
            revert NotMinter();
        }
        _mint(to, amount);

        emit LogMint(to, amount);
    }

    function _authorizeUpgrade(address newImplementation) internal virtual override onlyOwner { }
}
