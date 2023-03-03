%lang starknet

from starkware.starknet.common.syscalls import (
    get_block_timestamp,
    get_caller_address,
    call_contract,
)

from starkware.cairo.common.uint256 import Uint256, ALL_ONES, uint256_lt, uint256_eq
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from starkware.cairo.common.bitwise import bitwise_and, bitwise_xor, bitwise_or
from starkware.cairo.common.math import assert_not_zero
from openzeppelin.token.erc20.IERC20 import IERC20
from openzeppelin.security.safemath.library import SafeUint256
from openzeppelin.security.reentrancyguard.library import ReentrancyGuard
from morphine.adapters.baseAdapter import BaseAdapter, borrow_manager, borrow_transit, target
from morphine.interfaces.IERC4626 import IERC4626
from morphine.interfaces.IBorrowManager import IBorrowManager
from morphine.utils.various import DEPOSIT_SELECTOR, REDEEM_SELECTOR

/// @title: ERC4626 adapter
/// @author: 0xSacha
/// @dev: Contract that contains all method to interact with ERC4626
/// @custom: experimental This is an experimental contract.

//
// Storage
//

@storage_var
func token() -> (address : felt) {
}

//
//  Constructor
//

// @notice: Constructor for the adapter will be called only once.
// @param: _borrow_manager borrow manager address
// @param: _target target address
@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        _borrow_manager: felt,
        _target: felt) {
    alloc_locals;
    BaseAdapter.initializer(_borrow_manager, _target);
    let (token_) = IERC4626.asset(_target);
    token.write(token_);  

    let (underlying_token_mask_) = IBorrowManager.tokenMask(_borrow_manager, token_);
    let (is_zero_) = uint256_eq(underlying_token_mask_, Uint256(0,0));
    with_attr error_message("underlying token not allowed") {
        assert is_zero_ = 0;
    }

    let (vault_token_mask_) = IBorrowManager.tokenMask(_borrow_manager, _target);
    let (is_zero_) = uint256_eq(vault_token_mask_, Uint256(0,0));
    with_attr error_message("vault token not allowed") {
        assert is_zero_ = 0;
    }

    return();
}

//
//  Views
//

// @notice: Returns the borrow manager address
// @return: borrow manager address
@view
func borrowManager{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (borrowManager: felt){
    let (borrow_manager_) = borrow_manager.read();
    return (borrow_manager_,);
}

// @notice: Returns the borrow transit address
// @return: borrow transit address
@view
func borrowTransit{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (borrowTransit: felt){
    let (borrow_transit_) = borrow_transit.read();
    return (borrow_transit_,);
}

// @notice: Returns the target address
// @return: target address
@view
func targetContract{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (target: felt){
    let (target_) = target.read();
    return (target_,);
}

//
//  Externals
//

// @notice: Deposits all tokens 
// @return: amount of tokens deposited
@external 
func depositAll{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (shares: Uint256) {
    ReentrancyGuard.start();
    let (borrow_manager_) = borrowManager(); 
    let (caller_) = get_caller_address();
    let (container_) = IBorrowManager.getContainerOrRevert(borrow_manager_, caller_);
    let (token_) = token.read();
    let (balance_) = IERC20.balanceOf(token_, container_);
    let (is_lt_) = uint256_lt(Uint256(0,0), balance_);
    if(is_lt_ == 1){
        let (shares_) = _deposit(container_, balance_, 1);
        ReentrancyGuard.end();
        return (shares_,);
    } else {
        ReentrancyGuard.end();
        return (Uint256(0,0),);
    }
}

// @notice: Deposits tokens
// @param: _amount amount of tokens to deposit
// @return: shares amount of shares
@external 
func deposit{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(_amount: Uint256) -> (shares: Uint256) {
    ReentrancyGuard.start();
    let (borrow_manager_) = borrowManager(); 
    let (caller_) = get_caller_address();
    let (container_) = IBorrowManager.getContainerOrRevert(borrow_manager_, caller_);
    let (shares_) = _deposit(container_, _amount, 0);
    ReentrancyGuard.end();
    return (shares_,);
}

// @notice: Redeem all tokens
// @return: amount of tokens redeemed
@external
func redeemAll{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (assets: Uint256) {
    ReentrancyGuard.start();
    let (borrow_manager_) = borrowManager(); 
    let (caller_) = get_caller_address();
    let (container_) = IBorrowManager.getContainerOrRevert(borrow_manager_, caller_);
    let (token_) = targetContract();
    let (balance_) = IERC20.balanceOf(token_, container_);
    let (is_lt_) = uint256_lt(Uint256(0,0), balance_);
    if(is_lt_ == 1){
        let (assets_) = _redeem(container_, balance_, 1);
        ReentrancyGuard.end();
        return (assets_,);
    } else {
        ReentrancyGuard.end();
        return (Uint256(0,0),);
    }
}

// @notice: Redeem tokens
// @param: _amount  amount of shares to redeem
// @return: amount of assets redeemed
@external 
func redeem{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(_amount: Uint256) -> (assets: Uint256) {
    ReentrancyGuard.start();
    let (borrow_manager_) = borrow_manager.read();
    let (caller_) = get_caller_address();
    let (container_) = IBorrowManager.getContainerOrRevert(borrow_manager_, caller_);
    let (assets_) = _redeem(container_, _amount, 0);
    ReentrancyGuard.end();
    return (assets_,);
}

//
//  Internals 
//

// @notice: Deposits tokens
// @custom: internal function
// @param: _container container address
// @param: _amount amount of tokens to deposit
// @param: _disable_token_in boolean to disable token in
// @return: shares amount of shares
func _deposit{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(_container: felt, _amount: Uint256, _disable_token_in: felt) -> (shares: Uint256) {
    alloc_locals;
    let (token_in_) = token.read();
    let (token_out_) = targetContract();
    let (tokens_in) = alloc();
    let (tokens_out) = alloc();
    assert tokens_in[0] = token_in_;
    assert tokens_out[0] = token_out_;
    let (disable_token_in) = alloc();
    assert disable_token_in[0] = _disable_token_in;
    let (calldata) = alloc();
    assert calldata[0] = _amount.low;
    assert calldata[1] = _amount.high;
    assert calldata[2] = _container;
    let (retdata_len: felt, retdata: felt*) = BaseAdapter.safe_execute_container(_container, 1, tokens_in, 1, tokens_out, 1, 1, disable_token_in, DEPOSIT_SELECTOR, 3, calldata);
    return (Uint256(retdata[0], retdata[1]),);
}

// @notice: Redeem tokens
// @custom: internal function
// @param: _container container address
// @param: _amount amount of shares to redeem
// @param: _disable_token_out boolean to disable token out
// @return: amount of assets redeemed
func _redeem{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(_container: felt, _amount: Uint256, _disable_token_in: felt) -> (assets: Uint256) {
    alloc_locals;
    let (token_out_) = token.read();
    let (token_in_) = targetContract();
    let (tokens_in) = alloc();
    let (tokens_out) = alloc();
    assert tokens_in[0] = token_in_;
    assert tokens_out[0] = token_out_;
    let (disable_token_in) = alloc();
    assert disable_token_in[0] = _disable_token_in;
    let (calldata) = alloc();
    assert calldata[0] = _amount.low;
    assert calldata[1] = _amount.high;
    assert calldata[2] = _container;
    assert calldata[3] = _container;
    let (retdata_len: felt, retdata: felt*) = BaseAdapter.safe_execute_container(_container, 1, tokens_in, 1, tokens_out, 1, 1, disable_token_in, REDEEM_SELECTOR, 4, calldata);
    return (Uint256(retdata[0], retdata[1]),);
}

    
