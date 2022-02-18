// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "./ProxyRegistry.sol";
import "./interfaces/IRoboTraitsShort.sol";

abstract contract RoborovskiErc721 is
    Ownable,
    IERC165,
    IERC721,
    IERC721Metadata,
    IERC721Enumerable
{
    using Strings for uint256;
    using Address for address;

    // Metadata
    string private _name = "ROBOROVSKI";
    string private _symbol = "ROBO";
    string private _contractURI = "https://ipfs.io/ipfs/QmXHfdENe1vLPn2g6BP7KnvnhgXGMekst3YaP49hYjXbFY";
    string private _baseURI = "";
    string private _baseExtension = ".json";
    bool private _revealed = false;
    string private _notRevealedURI = "https://ipfs.io/ipfs/QmUCSUQPJuvLbm7ymJ3BFfAc9CYMqCbBX9hoMFQQvP3iTa";
    mapping(uint256 => string) private _tokenURIs;

    // Balances
    uint256 internal constant MAX_SUPPLY = 10000;
    uint256 private _total;
    address[MAX_SUPPLY + 1] private _owners;

    // Approvals
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Traits
    address public TRAITS;

    // OpenSea
    address private _proxyRegistry;

    constructor(address proxyRegistry_) {
        _proxyRegistry = proxyRegistry_;
    }

    function supportsInterface(bytes4 interfaceId) external pure override returns (bool) {
        return
            interfaceId == type(IERC721Enumerable).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC165).interfaceId;
    }

    function balanceOf(address owner) public view override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        uint256 count = 0;
        uint256 length = _owners.length;
        for (uint256 i = 0; i < length; ++i) {
            if (owner == _owners[i]) {
                ++count;
            }
        }
        delete length;
        return count;
    }

    function ownerOf(uint256 tokenId) public view override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    function rawOwnerOf(uint256 tokenId) public view returns (address) {
        return _owners[tokenId];
    }

    function name() public view override returns (string memory) {
        return _name;
    }

    function symbol() public view override returns (string memory) {
        return _symbol;
    }

    function contractURI() external view returns (string memory) {
        if (TRAITS != address(0))
            return IRoboTraitsShort(TRAITS).contractURI();
        return _contractURI;
    }

    function tokenURI(uint256 tokenId) external view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        if (!_revealed)
            return _notRevealedURI;

        if (TRAITS != address(0))
            return IRoboTraitsShort(TRAITS).tokenURI(tokenId);

        string memory _tokenURI = _tokenURIs[tokenId];
        if (bytes(_tokenURI).length > 0)
            return _tokenURI;

        return string(abi.encodePacked(_baseURI, tokenId.toString(), _baseExtension));
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view override returns (uint256 tokenId) {
        require(index < balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        uint256 count;
        for (uint256 i; i < _owners.length; ++i) {
            if (owner == _owners[i]) {
                if (count == index)
                    return i;
                else
                    ++count;
            }
        }
        require(false, "ERC721Enumerable: owner index out of bounds");
    }

    function tokensOfOwner(address owner) public view returns (uint256[] memory) {
        require(0 < balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        uint256 tokenCount = balanceOf(owner);
        uint256[] memory tokenIds = new uint256[](tokenCount);
        for (uint256 i = 0; i < tokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(owner, i);
        }
        return tokenIds;
    }

    function totalSupply() public view override returns (uint256) {
        return _total;
    }

    function tokenByIndex(uint256 index) public pure override returns (uint256) {
        return index;
    }

    function approve(address to, uint256 tokenId) public override {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");
        require(_msgSender() == owner || isApprovedForAll(owner, _msgSender()), "ERC721: approve caller is not owner nor approved for all");
        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");
        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view override returns (bool) {
        if (_proxyRegistry != address(0) && address(ProxyRegistry(_proxyRegistry).proxies(owner)) == operator)
            return true;
        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public override {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory _data) internal {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view returns (bool) {
        return _owners[tokenId] != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ownerOf(tokenId);
        return
            spender == owner ||
            getApproved(tokenId) == spender ||
            isApprovedForAll(owner, spender);
    }

    /*function _safeMint(address to, uint256 tokenId) internal {
        _safeMint(to, tokenId, "");
    }

    function _safeMint(address to, uint256 tokenId, bytes memory _data) internal {
        _mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }*/

    function _mint(address to, uint256 tokenId) internal {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");
        _owners[tokenId] = to;
        _total++;
        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal {
        address owner = ownerOf(tokenId);
        _approve(address(0), tokenId);
        _owners[tokenId] = address(0);
        _total--;

        if (bytes(_tokenURIs[tokenId]).length != 0)
            delete _tokenURIs[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    function _transfer(address from, address to, uint256 tokenId) internal {
        require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _approve(address(0), tokenId);
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _approve(address to, uint256 tokenId) internal {
        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }

    function _setApprovalForAll(address owner, address operator, bool approved) internal {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data) private returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    // Metadata
    function reveal() external onlyOwner {
        _revealed = true;
    }

    function setNotRevealedURI(string memory uri_) external onlyOwner {
        _notRevealedURI = uri_;
    }

    function setContractURI(string memory uri_) external onlyOwner {
        _contractURI = uri_;
    }

    function setBaseURI(string memory uri_) external onlyOwner {
        _baseURI = uri_;
    }

    function setBaseExtension(string memory fileExtension) external onlyOwner {
        _baseExtension = fileExtension;
    }

    function setTokenURIs(uint256[] memory ids, string[] memory uris) external onlyOwner {
        require(ids.length == uris.length, "ERC721URIStorage: parameters mismatch");
        for (uint256 i = 0; i < ids.length; i++) {
            _setTokenURI(ids[i], uris[i]);
        }
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) private {
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    // Traits
    function setTraits(address traits_) external onlyOwner {
        TRAITS = traits_;
    }

    // OpenSea
    function unsetProxyRegistry() external onlyOwner {
        _proxyRegistry = address(0);
    }
}
