// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IRoboShort.sol";
import "./interfaces/IRoboStoreShort.sol";

contract RoborovskiTraits is Ownable {
    address public immutable ROBO;
    address public immutable STORE;

    struct Temp {
        uint256 tokenId;
        string ipfsHash;
        bytes traitBytes;
        string name;
    }

    string[] public traitTypes = ["Surname", "Background", "Base", "Body", "Clothes", "Head", "Eyes", "Mouth", "Head Gear", "Back Weapon", "Right Hand Weapon", "Left Hand Weapon", "Glove & Weapon"];

    mapping(uint256 => mapping(uint256 => string)) public traitData;
    mapping(uint256 => uint256) public traitCount;

    string public imagePrefix = "https://ipfs.roborovski.org/ipfs/";
    bool public useTokenId = true;

    string private constant _ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    constructor(address robo, address store) {
        ROBO = robo;
        STORE = store;
    }

    function setImagePrefix(string memory imagePrefix_) public onlyOwner {
        imagePrefix = imagePrefix_;
    }

    function setUseTokenId(bool useTokenId_) public onlyOwner {
        useTokenId = useTokenId_;
    }

    function setTraitData(uint256 traitId, uint256 startAt, string[] memory data) public onlyOwner {
        for (uint256 i = 0; i < data.length; i++) {
            traitData[traitId][startAt + i] = data[i];
        }
    }

    function setTraitCount(uint256[] memory traitIds, uint256[] memory counts) public onlyOwner {
        for (uint256 i = 0; i < traitIds.length; i++) {
            traitCount[traitIds[i]] = counts[i];
        }
    }

    /***RENDER */
    function contractURI() external view returns (string memory) {
        string memory metadata = string(
            abi.encodePacked(
                '{"name": "Roborovski NFT Collection by SYA Concept","description": "An NFT project initiated by Hollywood-class enterprise SYA Concept & Caravan studio. Based on the character created by Dev Patel and Tilda Cobham-Hervey.","image": "',
                imagePrefix,
                'QmWG8P7koQoujLc3zn7zZR6HKarinpDtoKx5oaqjtu7fYi","external_url": "https://roborovski.org/","seller_fee_basis_points": 750,"fee_recipient": "0x5AF3F92c0725D54565014b5EA0d5f15A685d1a2a"}'
            )
        );

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    _base64(bytes(metadata))
                )
            );
    }

    function _makeTemp(uint256 tokenId) private view returns (Temp memory _temp) {
        _temp.tokenId = tokenId;
        _temp.ipfsHash = IRoboStoreShort(STORE).getIpfsHash(tokenId);
        _temp.traitBytes = IRoboStoreShort(STORE).getTraitBytes(tokenId);
        _temp.name = IRoboShort(ROBO).tokenName(tokenId);
    }

    function _byteToUint8(bytes1 bits) private pure returns (uint8 traitId) {
        traitId = uint8(bits);
    }

    function _compileAttributes(Temp memory _temp) private view returns (string memory) {
        string memory traits_1;
        traits_1 = string(
            abi.encodePacked(
                _attributeForTypeAndValue("Name", _temp.name),
                ",",
                _attributeForTypeAndValue(
                    traitTypes[0],
                    traitData[0][_byteToUint8(_temp.traitBytes[0])]
                ),
                ",",
                _attributeForTypeAndValue(
                    traitTypes[1],
                    traitData[1][_byteToUint8(_temp.traitBytes[1])]
                ),
                ",",
                _attributeForTypeAndValue(
                    traitTypes[2],
                    traitData[2][_byteToUint8(_temp.traitBytes[2])]
                ),
                ",",
                _attributeForTypeAndValue(
                    traitTypes[3],
                    traitData[3][_byteToUint8(_temp.traitBytes[3])]
                )
            )
        );

        string memory traits_2;
        traits_2 = string(
            abi.encodePacked(
                ",",
                _attributeForTypeAndValue(
                    traitTypes[5],
                    traitData[5][_byteToUint8(_temp.traitBytes[5])]
                ),
                ",",
                _attributeForTypeAndValue(
                    traitTypes[6],
                    traitData[6][_byteToUint8(_temp.traitBytes[6])]
                ),
                ",",
                _attributeForTypeAndValue(
                    traitTypes[7],
                    traitData[7][_byteToUint8(_temp.traitBytes[7])]
                ),
                ",",
                _attributeForTypeAndValue(
                    traitTypes[10],
                    traitData[10][_byteToUint8(_temp.traitBytes[10])]
                ),
                ",",
                _attributeForTypeAndValue(
                    traitTypes[11],
                    traitData[11][_byteToUint8(_temp.traitBytes[11])]
                )
            )
        );

        string memory traits4 = "";
        uint8 traits4Id = _byteToUint8(_temp.traitBytes[4]);
        if (traits4Id != 0) {
            traits4 = string(
                abi.encodePacked(
                    ",",
                    _attributeForTypeAndValue(
                        traitTypes[4],
                        traitData[4][traits4Id]
                    )
                )
            );
        }

        string memory traits8 = "";
        uint8 traits8Id = _byteToUint8(_temp.traitBytes[8]);
        if (traits8Id != 0) {
            traits8 = string(
                abi.encodePacked(
                    ",",
                    _attributeForTypeAndValue(
                        traitTypes[8],
                        traitData[8][traits8Id]
                    )
                )
            );
        }

        string memory traits9 = "";
        uint8 traits9Id = _byteToUint8(_temp.traitBytes[9]);
        if (traits9Id != 0) {
            traits9 = string(
                abi.encodePacked(
                    ",",
                    _attributeForTypeAndValue(
                        traitTypes[9],
                        traitData[9][traits9Id]
                    )
                )
            );
        }

        string memory traits12 = "";
        uint8 traits12Id = _byteToUint8(_temp.traitBytes[12]);
        if (traits12Id != 0) {
            traits12 = string(
                abi.encodePacked(
                    ",",
                    _attributeForTypeAndValue(
                        traitTypes[12],
                        traitData[12][traits12Id]
                    )
                )
            );
        }

        return
            string(
                abi.encodePacked(
                    "[",
                    traits_1,
                    traits_2,
                    traits4,
                    traits8,
                    traits9,
                    traits12,
                    "]"
                )
            );
    }

    function _compileMetadata(Temp memory _temp) private view returns (bytes memory) {
        string memory attributes = _compileAttributes(_temp);

        return
            abi.encodePacked(
                '{"name": "',
                _temp.name,
                " ",
                traitData[0][_byteToUint8(_temp.traitBytes[0])],
                useTokenId ? " #" : "",
                useTokenId ? _toString(_temp.tokenId) : "",
                '","description": "An NFT project initiated by Hollywood-class enterprise SYA Concept & Caravan studio. Based on the character created by Dev Patel and Tilda Cobham-Hervey.","image": "',
                imagePrefix,
                _temp.ipfsHash,
                '","external_url": "https://roborovski.org/#/details/',
                _toString(_temp.tokenId),
                '","attributes": ',
                attributes,
                "}"
            );
    }

    function tokenURI(uint256 tokenId) external view returns (string memory) {
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    _base64(_compileMetadata(_makeTemp(tokenId)))
                )
            );
    }

    function _attributeForTypeAndValue(string memory traitType, string memory value) internal pure returns (string memory) {
        return
            string(
                abi.encodePacked(
                    '{"trait_type":"',
                    traitType,
                    '","value":"',
                    value,
                    '"}'
                )
            );
    }

    function _base64(bytes memory data) internal pure returns (string memory) {
        if (data.length == 0) return "";

        // load the table into memory
        string memory table = _ALPHABET;

        // multiply by 4/3 rounded up
        uint256 encodedLen = 4 * ((data.length + 2) / 3);

        // add some extra buffer at the end required for the writing
        string memory result = new string(encodedLen + 32);

        assembly {
            // set the actual output length
            mstore(result, encodedLen)

            // prepare the lookup table
            let tablePtr := add(table, 1)

            // input ptr
            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))

            // result ptr, jump over length
            let resultPtr := add(result, 32)

            // run over the input, 3 bytes at a time
            for {

            } lt(dataPtr, endPtr) {

            } {
                dataPtr := add(dataPtr, 3)

                // read 3 bytes
                let input := mload(dataPtr)

                // write 4 characters
                mstore(
                    resultPtr,
                    shl(248, mload(add(tablePtr, and(shr(18, input), 0x3F))))
                )
                resultPtr := add(resultPtr, 1)
                mstore(
                    resultPtr,
                    shl(248, mload(add(tablePtr, and(shr(12, input), 0x3F))))
                )
                resultPtr := add(resultPtr, 1)
                mstore(
                    resultPtr,
                    shl(248, mload(add(tablePtr, and(shr(6, input), 0x3F))))
                )
                resultPtr := add(resultPtr, 1)
                mstore(
                    resultPtr,
                    shl(248, mload(add(tablePtr, and(input, 0x3F))))
                )
                resultPtr := add(resultPtr, 1)
            }

            // padding with '='
            switch mod(mload(data), 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }
        }

        return result;
    }

    function _toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}
