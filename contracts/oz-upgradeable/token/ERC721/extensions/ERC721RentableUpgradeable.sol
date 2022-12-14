// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../ERC721Upgradeable.sol";

import "./IERC721RentableUpgradeable.sol";

import "../../../utils/math/SafeCastUpgradeable.sol";

abstract contract ERC721RentableUpgradeable is
    ERC721Upgradeable,
    IERC721RentableUpgradeable
{
    using SafeCastUpgradeable for uint256;

    mapping(uint256 => UserInfo) internal _users;

    function __ERC721Rentable_init() internal onlyInitializing {}

    function __ERC721Rentable_init_unchained() internal onlyInitializing {}

    function setUser(
        uint256 tokenId,
        address user,
        uint64 expires
    ) external virtual override {
        if (!_isApprovedOrOwner(_msgSender(), tokenId))
            revert Rentable__OnlyOwnerOrApproved();

        UserInfo memory info = _users[tokenId];
        info.user = user;
        unchecked {
            info.expires = (block.timestamp + expires).toUint96();
        }

        _users[tokenId] = info;

        emit UserUpdated(tokenId, user, expires);
    }

    function userOf(
        uint256 tokenId
    ) external view virtual override returns (address user) {
        UserInfo memory info = _users[tokenId];
        user = info.expires > block.timestamp ? info.user : address(0);
    }

    function userExpires(
        uint256 tokenId
    ) public view virtual override returns (uint256) {
        return _users[tokenId].expires;
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override returns (bool) {
        return
            interfaceId == type(IERC721RentableUpgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        super._beforeTokenTransfer(from, to, tokenId);

        UserInfo memory info = _users[tokenId];
        if (block.timestamp < info.expires) revert Rentable__NotValidTransfer();
        if (from != to && info.user != address(0)) {
            delete _users[tokenId];

            emit UserUpdated(tokenId, address(0), 0);
        }
    }

    uint256[49] private __gap;
}
