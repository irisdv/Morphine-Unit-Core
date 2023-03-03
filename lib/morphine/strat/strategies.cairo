%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.uint256 import Uint256, uint256_eq, uint256_lt, uint256_add
from starkware.cairo.common.alloc import alloc

from openzeppelin.introspection.erc165.library import ERC165
from openzeppelin.token.erc721.library import ERC721
from openzeppelin.token.erc721.enumerable.library import ERC721Enumerable
from morphine.utils.RegisteryAccess import RegisteryAccess

from morphine.interfaces.IStrategies import TokenAllocation

//
// Events
//

@event
func NewMinterSet(minter: felt) {
}

@event
func NewStrategyMinted(token_id_: Uint256, allocations_len: felt, allocations: TokenAllocation*) {
}

//
// Storage
//

@storage_var
func registery() -> (registery: felt) {
}

@storage_var
func minter() -> (minter: felt) {
}

@storage_var
func base_URI() -> (minter: felt) {
}

@storage_var
func strategies(token_id: Uint256) -> (length: felt) {
}

@storage_var
func strategies_allocation(token_id: Uint256, id: felt) -> (allocations: TokenAllocation) {
}

//
// Protectors
//

// @notice: Only minter contract can call this function
func assert_only_minter{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    let (caller_) = get_caller_address();
    let (minter_) = minter.read();
    with_attr error_message("only callable by minter") {
        assert caller_ = minter_;
    }
    return ();
}

//
// Constructor
//

// @notice: Constructor for the contract can only be called by once
@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    _name: felt, _symbol: felt, _registery: felt
) {
    ERC721.initializer(_name, _symbol);
    ERC721Enumerable.initializer();
    registery.write(_registery);
    RegisteryAccess.initializer(_registery);
    return ();
}

//
// Getters
//

// @notice: Get the Morphine pass totalSupply
// @return: The total supply of Morphine pass
@view
func totalSupply{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}() -> (
    totalSupply: Uint256
) {
    let (totalSupply: Uint256) = ERC721Enumerable.total_supply();
    return (totalSupply=totalSupply);
}

// @notice: Get the Morphine pass coresponding to the token id
// @param: _index The index of the NFT you want
// @return: The token id of the NFT
@view
func tokenByIndex{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    _index: Uint256
) -> (tokenId: Uint256) {
    let (tokenId: Uint256) = ERC721Enumerable.token_by_index(_index);
    return (tokenId=tokenId);
}

// @notice: Get the Morphine pass owner coresponding to the token id
// @param: owner The owner address of the NFT you want
// @return: The token id of the NFT
@view
func tokenOfOwnerByIndex{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    _owner: felt, _index: Uint256
) -> (tokenId: Uint256) {
    let (tokenId: Uint256) = ERC721Enumerable.token_of_owner_by_index(_owner, _index);
    return (tokenId=tokenId);
}

// @notice: Check if the interface is supported
// @param: _interfaceId The interface id you want to check
// @return: success True if the interface is supported
@view
func supportsInterface{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    _interfaceId: felt
) -> (success: felt) {
    return ERC165.supports_interface(_interfaceId);
}

// @notice : Get the ERC721 name
// @return : The ERC721 name
@view
func name{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (name: felt) {
    return ERC721.name();
}

// @notice : Get the ERC721 symbol
// @return : The ERC721 symbol
@view
func symbol{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (symbol: felt) {
    return ERC721.symbol();
}

// @notice : Get the ERC721 balanceOf
// @param: _owner The owner address of the NFT you want
// @return : The ERC721 balanceOf
@view
func balanceOf{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(_owner: felt) -> (
    balance: Uint256
) {
    return ERC721.balance_of(_owner);
}

// @notice : Get the ERC721 ownerOf
// @param: _tokenId The token id of the NFT you want
// @return : The ERC721 ownerOf
@view
func ownerOf{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    _tokenId: Uint256
) -> (owner: felt) {
    return ERC721.owner_of(_tokenId);
}

// @notice: Approuve your ERC721 token
// @param: _tokenId The token id of the NFT you want to approve
// @return: approved True if the approval is successful
@view
func getApproved{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    _tokenId: Uint256
) -> (approved: felt) {
    return ERC721.get_approved(_tokenId);
}

// @notice: Check if the operator is approved for all
// @param: _owner The owner address of the NFT you want to check
// @param: _operator The operator address of the NFT you want to check
// @return: isApproved True if the operator is approved for all
@view
func isApprovedForAll{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    _owner: felt, _operator: felt
) -> (isApproved: felt) {
    let (isApproved: felt) = ERC721.is_approved_for_all(_owner, _operator);
    return (isApproved=isApproved);
}

// @notice: Get the token URI
// @param: _tokenId The token id of the NFT you want to get the token URI
// @return: tokenURI The token URI of the NFT
@view
func tokenURI{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    _tokenId: Uint256
) -> (tokenURI: felt) {
    let (token_uri_) = baseURI();
    return (token_uri_,);
}

// @notice: Get the base URI
// @return: baseURI The base URI of the NFT
@view
func baseURI{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (baseURI: felt) {
    let (baseURI_: felt) = base_URI.read();
    return (baseURI_,);
}

// @notice: Get the owner of the NFT
@view
func owner{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (owner: felt) {
    return RegisteryAccess.owner();
}

//
// Externals
//

// @notice: Set Minter status
// @param: _minter The minter address you want to set
@external
func setMinter{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(_minter: felt) {
    RegisteryAccess.assert_only_owner();
    minter.write(_minter);
    NewMinterSet.emit(_minter);
    return ();
}

// @notice: mint NFT
// @param: _to The address you want to mint the NFT to
// @param: _amount The amount of NFT you want to mint
// @param: tokens Array of token addresses
// @param: allocation Array of allocation
@external
func mint{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    _to: felt, _tokens_len: felt, _tokens: felt*, _allocations_len: felt, _allocations: felt*
) {
    alloc_locals;
    assert_only_minter();
    let (prev_token_id_) = totalSupply();
    let (local token_id_, _) = uint256_add(prev_token_id_, Uint256(1, 0));
    strategies.write(token_id_, _tokens_len);
    let (local strategy_: TokenAllocation*) = alloc();
    saveStrategy(token_id_, _tokens_len, _tokens, _allocations, 0, strategy_);
    ERC721Enumerable._mint(_to, token_id_);
    NewStrategyMinted.emit(token_id_, _tokens_len, strategy_);
    return ();
}

// @notice: burn NFT
// @param: _from The address you want to burn the NFT from
// @param: token_id_ The token id of the NFT you want to burn
@external
func burn{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    _from: felt, token_id_: Uint256
) {
    ERC721Enumerable._burn(token_id_);
    return ();
}

// @notice: set Base URI NFT
// @param: _baseURI The base URI you want to set
@external
func setBaseURI{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(_baseURI: felt) {
    RegisteryAccess.assert_only_owner();
    base_URI.write(_baseURI);
    return ();
}

// @notice: transfer from
// @param: _from The address you want to transfer the NFT from
// @param: _to The address you want to transfer the NFT to
// @param: token_id_ The token id of the NFT you want to transfer
@external
func transferFrom{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    _from: felt, _to: felt, _token_id_: Uint256
) {
    ERC721Enumerable.transfer_from(_from, _to, _token_id_);
    return ();
}

// @notice: safe transfer from
// @param: _from The address you want to transfer the NFT from
// @param: _to The address you want to transfer the NFT to
// @param: token_id_ The token id of the NFT you want to transfer
@external
func safeTransferFrom{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    _from: felt, _to: felt, _token_id: Uint256, _data_len: felt, _data: felt*
) {
    ERC721Enumerable.safe_transfer_from(_from, _to, _token_id, _data_len, _data);
    return ();
}

// @notice: approve
// @param: _to The address you want to approve the NFT to
// @param: token_id_ The token id of the NFT you want to approve
@external
func approve{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    _to: felt, _token_id: Uint256
) {
    ERC721.approve(_to, _token_id);
    return ();
}

// @notice: set approval for all
// @param: _operator The address you want to approve the NFT to
// @param: _approved The approval status you want to set
@external
func setApprovalForAll{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    _operator: felt, _approved: felt
) {
    ERC721.set_approval_for_all(_operator, _approved);
    return ();
}

//
// Internals
//

// @notice: save strategy onchain
// @param: _token_id The id of the strategy
// @param: _tokens array
// @param: _allocations array
// @param: _res_len The length of the array of strategy
// @param: _res array of TokenAllocation
func saveStrategy{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    _token_id: Uint256,
    _tokens_len: felt,
    _tokens: felt*,
    _allocations: felt*,
    _res_len: felt,
    _res: TokenAllocation*,
) {
    alloc_locals;
    if (_res_len == _tokens_len * 2) {
        return ();
    }
    assert _res[0] = TokenAllocation(address=_tokens[0], allocation=_allocations[0]);
    strategies_allocation.write(_token_id, _res_len, _res[0]);
    return saveStrategy(
        _token_id, _tokens_len, _tokens + 1, _allocations + 1, _res_len + 2, _res + 2
    );
}
