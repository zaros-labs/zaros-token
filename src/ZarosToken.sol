// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// Open zeppelin upgradeable dependencies
import { ERC20PermitUpgradeable } from "@openzeppelin-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import { OwnableUpgradeable } from "@openzeppelin-upgradeable/access/OwnableUpgradeable.sol";
import { UUPSUpgradeable } from "@openzeppelin-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract ZarosToken is UUPSUpgradeable, ERC20PermitUpgradeable, OwnableUpgradeable {
    mapping(address user => bool isAllowed) allowList;

    /// @notice Emitted when the array length of addresses is not equal to the array length of booleans
    /// @param addresses Array of addresses
    /// @param isAllowed Array of booleans
    error ArrayMustBeOfEqualLength(address[] addresses, bool[] isAllowed);

    /// @notice Emitted when the user is not allowed to mint
    /// @param user Address that is not allowed to mind
    error UserNotAllowed(address user);

    /// @notice Emitted when the allow list is updated
    /// @param user Address that was updated
    /// @param isAllowed Boolean to set the address
    event LogUpdateAllowList(address indexed user, bool isAllowed);

    /// @notice Emitted when token are minted
    /// @param to Address that received the tokens
    /// @param amount Amount of tokens minted
    event LogMint(address indexed to, uint256 amount);

    /// @notice Initilize the contract
    /// @param owner Address that will be the owner of the contract
    /// @param name Name of the token
    /// @param symbol Symbol of the token
    function initialize(address owner, string memory name, string memory symbol) external initializer {
        __ERC20_init(name, symbol);
        __ERC20Permit_init(name);
        __Ownable_init(owner);
    }

    /// @notice Mint tokens to an address
    /// @param to Address to mint the tokens to
    /// @param amount Amount of tokens to mint
    function mint(address to, uint256 amount) external {
        if (allowList[to] == false) {
            revert UserNotAllowed(to);
        }

        _mint(to, amount);

        emit LogMint(to, amount);
    }

    /// @notice Configure the allow list for minting by passing an array of addresses and an array of booleans
    /// @param _addresses Array of addresses to update
    /// @param _isAllowed Array of booleans to ser the adresses
    function updateArrayOfAddresses(address[] memory _addresses, bool[] memory _isAllowed) external onlyOwner {
        if (_addresses.length != _isAllowed.length) {
            revert ArrayMustBeOfEqualLength(_addresses, _isAllowed);
        }

        for (uint256 i = 0; i < _addresses.length; i++) {
            updateAllowList(_addresses[i], _isAllowed[i]);
        }
    }

    /// @notice Update the allow list for minting
    /// @param _user Address to update
    /// @param _isAllowed Boolean to set the address
    function updateAllowList(address _user, bool _isAllowed) public onlyOwner {
        allowList[_user] = _isAllowed;

        emit LogUpdateAllowList(_user, _isAllowed);
    }

    /// @notice Check if the user has permission to mint
    /// @param _user Address to check
    /// @return Boolean if the user has permission
    function checkIfTheUserHasPermission(address _user) public view returns (bool) {
        return allowList[_user];
    }

    function _authorizeUpgrade(address newImplementation) internal virtual override onlyOwner { }
}
