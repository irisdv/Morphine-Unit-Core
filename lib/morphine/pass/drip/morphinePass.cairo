// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts for Cairo v0.4.0b (token/erc721/presets/ERC721MintableBurnable.cairo)

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256, uint256_pow2, uint256_eq, uint256_lt
from starkware.cairo.common.math import assert_not_zero, split_felt
from starkware.starknet.common.syscalls import (
    get_contract_address,
    get_caller_address
)

from openzeppelin.introspection.erc165.library import ERC165
from openzeppelin.token.erc721.library import ERC721
from openzeppelin.token.erc721.enumerable.library import ERC721Enumerable
from openzeppelin.security.safemath.library import SafeUint256
from morphine.utils.RegisteryAccess import RegisteryAccess

from morphine.interfaces.IRegistery import IRegistery
from morphine.interfaces.IBorrowTransit import IBorrowTransit
from morphine.interfaces.IBorrowManager import IBorrowManager

/// @title: Morphine pass 
/// @author: Morphine team
/// @dev: ERC721 and ERC721Enumerable for Morphine pass
/// @custom: experimental This is an experimental contract.

//
// Events 
//

@event 
func NewMinterSet(minter: felt){
}

@event 
func NewDripTransitAdded(drip_transit: felt){
}

@event 
func NewDripTransitRemoved(drip_transit: felt){
}

// Storage

@storage_var
func registery() -> (registery: felt) {
}

@storage_var
func supported_drip_transit(drip_transit: felt) -> (state: felt) {
}

@storage_var
func minter() -> (minter: felt) {
}

@storage_var
func base_URI() -> (minter: felt) {
}

//
// Protectors
//

// @notice: Only the owner or the drip transit can call this function
func assert_only_owner_or_drip_transit{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(){
    let (caller_) = get_caller_address();
    let (owner_) = RegisteryAccess.owner();
    let (is_supported_drip_transit_) = supported_drip_transit.read(caller_);
    with_attr error_message("only callable by drip transit or owner") {
        assert ((caller_ - owner_) * (is_supported_drip_transit_ - 1)) = 0;
    }
    return();
}

// @notice: Only a user who mint can call this function
func assert_only_minter{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(){
    let (caller_) = get_caller_address();
    let (minter_) = minter.read();
    with_attr error_message("only callable by minter") {
        assert caller_ = minter_;
    }
    return();
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
func ownerOf{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(_tokenId: Uint256) -> (
    owner: felt
) {
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
    return(token_uri_,);
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
func setMinter{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    _minter: felt
) {
    RegisteryAccess.assert_only_owner();
    minter.write(_minter);
    NewMinterSet.emit(_minter);
    return ();
}

// @notice: add Drip transit 
// @param: _dripTransit The drip transit address you want to add
@external
func addDripTransit{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    _drip_transit: felt
) {
    alloc_locals;
    RegisteryAccess.assert_only_owner();
    let (is_supported_drip_transit_) = supported_drip_transit.read(_drip_transit);
    with_attr error_message("drip transit already registered") {
        assert is_supported_drip_transit_ = 0;
    }
    let (drip_manager_) = IBorrowTransit.borrowManager(_drip_transit);
    let (registery_) = registery.read();
    let (is_drip_manager_) = IRegistery.isBorrowManager(registery_, drip_manager_);

    let (nft_) = IBorrowTransit.getNft(_drip_transit);
    let (this_) = get_contract_address();
    let (is_right_nft_) = is_equal(nft_, this_);
    
    let (drip_transit_from_drip_manager_) = IBorrowManager.borrowTransit(drip_manager_);
    let (is_right_drip_transit_) = is_equal(drip_transit_from_drip_manager_, _drip_transit);

    with_attr error_message("invalid dependencies") {
        assert_not_zero(is_drip_manager_*  is_right_nft_*is_right_drip_transit_ );
    }
    supported_drip_transit.write(_drip_transit, 1);
    NewDripTransitAdded.emit(_drip_transit);
    return ();
}

// @notice: remove Drip transit
// @param: _dripTransit The drip transit address you want to remove
@external
func removeDripTransit{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    _drip_transit: felt
) {
    RegisteryAccess.assert_only_owner();
    let (is_supported_drip_transit_) = supported_drip_transit.read(_drip_transit);
    with_attr error_message("drip transit not registered") {
        assert is_supported_drip_transit_ = 1;
    }
    supported_drip_transit.write(_drip_transit, 0);
    NewDripTransitRemoved.emit(_drip_transit);
    return ();
}


// @notice: Method for SBT should all aways fail
@external
func approve{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    to: felt, tokenId: Uint256
) {
    with_attr error_message("method not implemented") {
        assert 1 = 0;
    }
    return ();
}

// @notice: Method for SBT should all aways fail
@external
func setApprovalForAll{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    operator: felt, approved: felt
) {
    with_attr error_message("method not implemented") {
        assert 1 = 0;
    }
    return ();
}

// @notice: Method for SBT should all aways fail
@external
func transferFrom{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    from_: felt, to: felt, tokenId: Uint256
) {
    with_attr error_message("method not implemented") {
        assert 1 = 0;
    }
    return ();
}

// @notice: Method for SBT should all aways fail
@external
func safeTransferFrom{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    from_: felt, to: felt, tokenId: Uint256, data_len: felt, data: felt*
) {
    with_attr error_message("method not implemented") {
        assert 1 = 0;
    }
    return ();
}

// @notice: mint NFT
// @param: _to The address you want to mint the NFT to
// @param: _amount The amount of NFT you want to mint 
@external
func mint{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    _to: felt, _amount: Uint256
) {
    alloc_locals;
    assert_only_minter();
    let (is_correct_amount_) = uint256_eq(Uint256(1,0), _amount);
    with_attr error_message("only one mint allowed") {
        assert is_correct_amount_ = 1;
    }
    let (user_balance_) = balanceOf(_to);
    let (is_user_balance_nul_) = uint256_eq(Uint256(0,0), user_balance_);
    with_attr error_message("already minted") {
        assert is_user_balance_nul_ = 1;
    }
    let (token_id_) = totalSupply();
    ERC721Enumerable._mint(_to, token_id_);
    return ();
}

// @notice: burn NFT
// @param: _from The address you want to burn the NFT from
// @param: _amount The amount of NFT you want to burn
@external
func burn{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(_from: felt, _amount: Uint256) {
    alloc_locals;
    assert_only_owner_or_drip_transit();
    let (user_balance_) = balanceOf(_from);
    let (is_lt_) = uint256_lt(user_balance_, _amount);
    with_attr error_message("insufficient balance") {
        assert is_lt_ = 0;
    }
    let (token_id_) = tokenOfOwnerByIndex(_from, Uint256(0,0));
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

// @notice: Check is two felt are equal
// @custom: Internal function
// @param: _a The first felt
// @param: _b The second felt
// @return: state_ 1 if equal, 0 otherwise
func is_equal{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(_a: felt, _b: felt) -> (state: felt) {
    if (_a == _b){
        return(1,);
    } else {
        return(0,);
    }
}

// @notice: transform felt to Uint256
// @param: _felt_value The felt you want to transform
// @return: uint256_value The Uint256 value
func felt_to_uint256{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    _felt_value : felt
) -> (uint256_value : Uint256) {
    let (high, low) = split_felt(_felt_value);
    let uint256_value : Uint256 = Uint256(low, high);
    return (uint256_value,);
}