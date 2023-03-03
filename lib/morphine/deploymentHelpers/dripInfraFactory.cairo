%lang starknet

from starkware.starknet.common.syscalls import (
    get_tx_info,
    get_block_number,
    get_block_timestamp,
    get_caller_address,
)
from starkware.starknet.core.os.contract_address.contract_address import get_contract_address

from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin

from starkware.cairo.common.cairo_keccak.keccak import keccak_felts
from starkware.cairo.common.memcpy import memcpy
from starkware.cairo.common.hash_state import hash_felts
from morphine.interfaces.IBorrowConfigurator import AllowedToken


from starkware.cairo.common.uint256 import Uint256

from starkware.cairo.common.alloc import alloc
from starkware.starknet.common.syscalls import deploy

from morphine.interfaces.IBorrowManager import IBorrowManager


/// @title: dripInfraFactory
/// @author: 
/// @dev: Helper contract to deploy interdependent contracts
/// @custom: experimental This is an experimental contract.

//
// Storage
//
@storage_var
func drip_manager_hash() -> (drip_manager_hash: felt) {
}

@storage_var
func drip_transit_hash() -> (drip_transit_hash: felt) {
}

@storage_var
func drip_configurator_hash() -> (drip_configurator_hash: felt) {
}


@storage_var
func drip_manager() -> (drip_manager: felt) {
}

@storage_var
func drip_transit() -> (drip_transit: felt) {
}

@storage_var
func drip_configurator() -> (drip_configurator: felt) {
}




// Constructor

// @notice Constructor will be called once when the contract is deployed.
@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    _drip_manager_hash: felt,
    _drip_transit_hash: felt,
    _drip_configurator_hash: felt,
) {
    drip_manager_hash.write(_drip_manager_hash);
    drip_transit_hash.write(_drip_transit_hash);
    drip_configurator_hash.write(_drip_configurator_hash);
    return ();
}

// @notice Deploy the DripManager contract.
// @param: _drip_infra_factory - The address of the DripInfraFactory contract.
// @param: _pool - The pool address.
// @param: _nft - The NFT address.
// @param: _expirable
// @param: _minimum_borrowed_amount (Uint256)
// @param: _maximum_borrowed_amount (Uint256)
// @param: _allowed_token_len 
// @param: _allowed_tokens (AllowedToken*))
// @param: _salt
@external
func deployDripInfra{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*}(
        _drip_infra_factory: felt, 
        _pool: felt, 
        _nft: felt,
        _expirable: felt,
        _minimum_borrowed_amount: Uint256,
        _maximum_borrowed_amount: Uint256,
        _allowed_tokens_len: felt,
        _allowed_tokens: AllowedToken*,
        _salt: felt) {
    alloc_locals;
    let (drip_manager_hash_) = drip_manager_hash.read();
    let (drip_manager_calldata_) = alloc();
    assert drip_manager_calldata_[0] = _pool;
    let (drip_manager_) = deploy(drip_manager_hash_, _salt, 1, drip_manager_calldata_, 0);
    drip_manager.write(drip_manager_);
    let (drip_transit_hash_) = drip_transit_hash.read();
    let (drip_transit_calldata_) = alloc();
    assert drip_transit_calldata_[0] = drip_manager_;
    assert drip_transit_calldata_[1] = _nft;
    assert drip_transit_calldata_[2] = _expirable;
    let (drip_transit_) = deploy(drip_transit_hash_, _salt, 3, drip_transit_calldata_, 0);
    drip_transit.write(drip_transit_);
    let (drip_configurator_hash_) = drip_configurator_hash.read();
    let (drip_configurator_calldata_: felt*) = alloc();
    assert drip_configurator_calldata_[0] = drip_manager_;
    assert drip_configurator_calldata_[1] = drip_transit_;
    assert drip_configurator_calldata_[2] = _minimum_borrowed_amount.low;
    assert drip_configurator_calldata_[3] = _minimum_borrowed_amount.high;
    assert drip_configurator_calldata_[4] = _maximum_borrowed_amount.low;
    assert drip_configurator_calldata_[5] = _maximum_borrowed_amount.high;
    assert drip_configurator_calldata_[6] = _allowed_tokens_len;
    memcpy(drip_configurator_calldata_ + 7, _allowed_tokens, _allowed_tokens_len * 3);
    let (drip_configurator_address_) = get_contract_address{hash_ptr= pedersen_ptr}(_salt, drip_configurator_hash_, 7 + _allowed_tokens_len * 3, drip_configurator_calldata_, _drip_infra_factory);
    IBorrowManager.setBorrowConfigurator(drip_manager_, drip_configurator_address_);
    let (drip_configurator_) = deploy(drip_configurator_hash_, _salt, 7 + _allowed_tokens_len*3, drip_configurator_calldata_, 0);
    drip_configurator.write(drip_configurator_);
    return ();
}

// @notice: Get Drip Infra Address
// @return: _drip_manager - The address of the DripManager contract.
// @return: _drip_transit - The address of the DripTransit contract.
// @return: _drip_configurator - The address of the DripConfigurator contract.
@view
func getDripInfraAddresses{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr, bitwise_ptr: BitwiseBuiltin*}() -> (
        drip_manager: felt, drip_transit: felt, drip_configurator: felt) {
    alloc_locals;
    let (drip_manager_) = drip_manager.read();
    let (drip_transit_) = drip_transit.read();
    let (drip_configurator_) = drip_configurator.read();
    return (drip_manager_, drip_transit_, drip_configurator_,);
}


