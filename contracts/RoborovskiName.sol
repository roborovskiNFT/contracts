// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";
import "./RoborovskiErc721.sol";
import "./interfaces/IRnctShort.sol";

abstract contract RoborovskiName is Context, RoborovskiErc721 {
    uint256 public constant PRICE_CHANGE_NAME = 1830 ether;
    address public immutable RNCT;

    mapping(uint256 => string) private _tokenName;
    mapping(string => bool) private _nameReserved;

    event NameChange(uint256 indexed tokenId, string newName);

    constructor(address rnct_) {
        RNCT = rnct_;
    }

    function burn(uint256 tokenId) external {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Burnable: caller is not owner nor approved");
        _burn(tokenId);

        // If already named, dereserve and remove name
        if (bytes(_tokenName[tokenId]).length != 0) {
            _toggleReserveName(_tokenName[tokenId], false);
            delete _tokenName[tokenId];
            emit NameChange(tokenId, "");
        }
    }

    function tokenName(uint256 tokenId) external view returns (string memory) {
        return _tokenName[tokenId];
    }

    function isNameReserved(string memory nameString) public view returns (bool) {
        return _nameReserved[toLower(nameString)];
    }

    function changeName(uint256 tokenId, string memory newName) external {
        address owner = ownerOf(tokenId);
        require(_msgSender() == owner, "ROBOROVSKI: caller is not the token owner");
        require(validateName(newName) == true, "ROBOROVSKI: not a valid new name");
        require(sha256(bytes(newName)) != sha256(bytes(_tokenName[tokenId])), "ROBOROVSKI: new name is same as the current one");
        require(isNameReserved(newName) == false, "ROBOROVSKI: name already reserved");
        require(IRnctShort(RNCT).transferFrom(_msgSender(), address(this), PRICE_CHANGE_NAME), "ROBOROVSKI: ERC20_TRANSFER_FAILED");
        IRnctShort(RNCT).burn(PRICE_CHANGE_NAME);

        // If already named, dereserve old name
        if (bytes(_tokenName[tokenId]).length > 0) {
            _toggleReserveName(_tokenName[tokenId], false);
        }
        _toggleReserveName(newName, true);
        _tokenName[tokenId] = newName;
        emit NameChange(tokenId, newName);
    }

    // Reserves the name if isReserve is set to true, de-reserves if set to false
    function _toggleReserveName(string memory str, bool isReserve) private {
        _nameReserved[toLower(str)] = isReserve;
    }

    // Check if the name string is valid (Alphanumeric and spaces without leading or trailing space)
    function validateName(string memory str) public pure returns (bool) {
        bytes memory b = bytes(str);
        if (b.length < 1)
            return false;
        // Cannot be longer than 25 characters
        if (b.length > 25)
            return false;
        // Leading space
        if (b[0] == 0x20)
            return false;
        // Trailing space
        if (b[b.length - 1] == 0x20)
            return false;

        bytes1 lastChar = b[0];

        for (uint256 i; i < b.length; i++) {
            bytes1 char = b[i];
            // Cannot contain continous spaces
            if (char == 0x20 && lastChar == 0x20)
                return false;
            if (
                !(char >= 0x30 && char <= 0x39) && //9-0
                !(char >= 0x41 && char <= 0x5A) && //A-Z
                !(char >= 0x61 && char <= 0x7A) && //a-z
                !(char == 0x20) //space
            )
                return false;
            lastChar = char;
        }
        return true;
    }

    // Converts the string to lowercase
    function toLower(string memory str) public pure returns (string memory) {
        bytes memory bStr = bytes(str);
        bytes memory bLower = new bytes(bStr.length);
        for (uint256 i = 0; i < bStr.length; i++) {
            // Uppercase character
            if ((uint8(bStr[i]) >= 65) && (uint8(bStr[i]) <= 90))
                bLower[i] = bytes1(uint8(bStr[i]) + 32);
            else
                bLower[i] = bStr[i];
        }
        return string(bLower);
    }
}
