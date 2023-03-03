%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.uint256 import Uint256

from openzeppelin.token.erc20.IERC20 import IERC20
from morphine.interfaces.IStrategies import IStrategies, TokenAllocation
from morphine.interfaces.IRegistery import IRegistery

// @title Minter for Morphine strategies

// Storage

@storage_var
func registery() -> (registery: felt) {
}

@storage_var
func nft_contract() -> (nft_contract: felt) {
}

@storage_var
func erc20_contract() -> (erc20_contract: felt) {
}

//
// Constructor
//

// @notice: Constructor for the contract can only be called once
@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    _nft_contract: felt, _registery: felt, _erc20_contract: felt
) {
    registery.write(_registery);
    nft_contract.write(_nft_contract);
    erc20_contract.write(_erc20_contract);
    return ();
}

//
// Getters
//

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

// @notice: mint a strategy NFT
// @param: token addresses array
// @param: token allocation array
@external
func mint{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    _tokens_len: felt, _tokens: felt*, _allocation_len: felt, _allocation: felt*
) {
    alloc_locals;
    with_attr error_message("token addresses and allocation array lengths must be equal") {
        assert _tokens_len = _allocation_len;
    }
    assertAllocation(_allocation_len, _allocation, 0);
    let (caller_) = get_caller_address();
    let (fees_) = calculate_fees();
    let (registry_) = registery.read();
    let (treasury_) = IRegistery.getTreasury(registry_);
    let (erc20_contract_) = erc20_contract.read();
    IERC20.transferFrom(erc20_contract_, caller_, treasury_, fees_);
    let (nft_contract_) = nft_contract.read();
    IStrategies.mint(nft_contract_, caller_, _tokens_len, _tokens, _allocation_len, _allocation);
    return ();
}

//
// Internals
//

func assertAllocation{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    _allocation_len: felt, _allocation: felt*, _total: felt
) {
    if (_allocation_len == 0) {
        with_attr error_message("total token allocation must be equal to 100%") {
            assert _total = 1000000;
        }
        return ();
    }
    return assertAllocation(_allocation_len - 1, _allocation + 1, _total + _allocation[0]);
}

// @notice: calculate fees to mint a strategy
// for now returns 1 DAI
func calculate_fees{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    amount: Uint256
) {
    return (Uint256(1000000, 0),);
}
