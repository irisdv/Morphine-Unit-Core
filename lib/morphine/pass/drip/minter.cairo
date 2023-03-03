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

from openzeppelin.access.ownable.library import Ownable
from openzeppelin.introspection.erc165.library import ERC165
from openzeppelin.token.erc721.library import ERC721
from openzeppelin.token.erc721.enumerable.library import ERC721Enumerable
from openzeppelin.security.safemath.library import SafeUint256
from morphine.interfaces.IMorphinePass import IMorphinePass

/// @title Minter method for Morphine pass
/// @author  (0xSacha)
/// @dev Contract that contains all the method needed for NFT mint
/// @custom:experimental This is an experimental contract.

@storage_var
func nft_contract() -> (nft_contract: felt) {
}

@storage_var
func is_whitelisted(user: felt) -> (state: felt) {
}

@storage_var
func has_minted(user: felt) -> (state: felt) {
}

//
// Protectors
//

// @notice: Only Whitelisted person who doesn't have a NFT yet can mint
func assert_only_whitelisted_and_not_minted{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(){
    let (caller_) = get_caller_address();
    let (is_whitelisted_) = is_whitelisted.read(caller_);
    let (has_minted_) = has_minted.read(caller_);
    with_attr error_message("only whitelisted") {
        assert is_whitelisted_ = 1;
    }
    with_attr error_message("already minted") {
        assert has_minted_ = 0;
    }
    return();
}

//
// Constructor
//

// @notice: Constructor for the contract can only be called once
@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    _nft_contract: felt
) {
    nft_contract.write(_nft_contract);
    return ();
}

//
// Getters
//

// @notice: Check if a user is whitelistedo
// @param: _user User to check
// @return: state True if user is whitelisted
@view
func isWhitelisted{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(_user: felt) -> (
    state: felt
) {
    let (is_whitelisted_) = is_whitelisted.read(_user);
    return (is_whitelisted_,);
}

// @notice: Check if a user has minted
// @param: _user User to check
// @return: state True if user has minted
@view
func hasMinted{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(_user: felt) -> (
    state: felt
) {
    let (has_minted_) = has_minted.read(_user);
    return (has_minted_,);
}

// @notice: get the nft address
// @return: nft address
@view
func nftContract{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}() -> (
    nftContract: felt
) {
    let (nft_contract_) = nft_contract.read();
    return (nft_contract_,);
}


//
// Externals
//

// @notice: mint a NFT
@external
func mint{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;
    assert_only_whitelisted_and_not_minted();
    let (caller_) = get_caller_address();
    let (nft_contract_) = nft_contract.read();
    IMorphinePass.mint(nft_contract_, caller_, Uint256(1,0));
    has_minted.write(caller_, 1);
    return ();
}

// @notice: Whitelist some user or users
// @param: _address user or users addressto whitelist
@external
func setWhitelist{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(_address_len: felt, _address: felt*) {
    alloc_locals;
    if(_address_len == 0){
        return();
    }
    is_whitelisted.write(_address[0], 1);
    return setWhitelist(_address_len - 1, _address + 1);
}
