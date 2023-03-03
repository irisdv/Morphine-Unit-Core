// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts for Cairo v0.4.0b (access/ownable/library.cairo)

%lang starknet

from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_not_zero
from starkware.cairo.common.uint256 import ALL_ONES, Uint256
from openzeppelin.token.erc20.IERC20 import IERC20
from morphine.interfaces.IBorrowManager import IBorrowManager


/// @title: BaseAdapter
/// @author: 0xSacha
/// @dev: Contract that contains all method needed for future protocol integraton
/// @custom: experimental This is an experimental contract.

//
// Storage
//

@storage_var
func borrow_manager() -> (borrow_manager: felt) {
}

@storage_var
func borrow_transit() -> (borrow_transit: felt) {
}

@storage_var
func target() -> (target: felt) {
}

// @title: BaseAdapter namespace
namespace BaseAdapter {

    //
    // Initializer
    //

    // @notice: Initializes the contract.
    // @param: _borrow_manager The address of the borrow manager.
    // @param: _target_contract The address of the target.
    func initializer{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(_borrow_manager: felt, _target_contract: felt) {
        with_attr error_message("zero address") {
            assert_not_zero(_borrow_manager * _target_contract);
        }
        borrow_manager.write(_borrow_manager);
        let (borrow_transit_) = IBorrowManager.borrowTransit(_borrow_manager);
        borrow_transit.write(borrow_transit_);
        target.write(_target_contract);
        return ();
    }

    // @notice: Approve tokens to the borrow manager.
    // @param: _token The address of the token.
    // @param: _amount The amount of tokens to approve.
    func approve_token{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(_token: felt, _amount: Uint256) {
        let (borrow_manager_) = borrow_manager.read();
        let (caller_) = get_caller_address();
        let (target_) = target.read();
        IBorrowManager.approveContainer(borrow_manager_, caller_, target_, _token ,_amount);
        return ();
    }

    // @notice: Execute order on the target contract.
    // @param: _selector The selector of the function to call.
    // @param: _calldata The data to pass to the function.
    // @param: _calladata_len The length of the data.
    // @return: retdata The return data of the function call.
    // @return: retdata_len The length of the return data.
    func execute{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(_selector: felt, _calldata_len: felt, _calldata: felt*) -> (retdata_len: felt, retdata: felt*) {
        alloc_locals;
        let (borrow_manager_) = borrow_manager.read();
        let (caller_) = get_caller_address();
        let (target_) = target.read();
        let (retdata_len: felt, retdata: felt*) = IBorrowManager.executeOrder(borrow_manager_, caller_, target_, _selector, _calldata_len, _calldata);
        return (retdata_len, retdata,);
    }

    // @notice: Execute maximum allowance
    // @param: _token_in 
    // @param: _token_out
    // @param: _allow_token_in Check if the token_in is allowed
    // @param: _disable_token_in 
    // @param: _selector The selector of the function to call.
    // @param: _calldata The data to pass to the function.
    // @param: _calladata_len The length of the data.
    // @return: retdata The return data of the function call.
    // @return: retdata_len The length of the return data.
    func execute_max_allowance{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
            token_in_len: felt,
            token_in: felt*, 
            token_out_len: felt,
            token_out: felt*, 
            _allow_token_in: felt,
            disable_token_in_len: felt,
            disable_token_in: felt*,
            _selector: felt,
            _calldata_len: felt, 
            _calldata: felt*) -> (retdata_len: felt, retdata: felt*) {
        let (borrow_manager_) = borrow_manager.read();
        let (caller_) = get_caller_address();
        let (container_) = IBorrowManager.getContainerOrRevert(borrow_manager_, caller_);
        let (retdata_len: felt, retdata: felt*) = execute_max_allowance_container(container_, token_in_len, token_in, token_out_len, token_out, _allow_token_in, disable_token_in_len, disable_token_in, _selector, _calldata_len, _calldata);
        return (retdata_len, retdata,);
    }

    // @notice: Execute maximum allowance container
    // @param: _container The container to execute
    // @param: _token_in
    // @param: _token_out
    // @param: _allow_token_in Check if the token_in is allowed
    // @param: _disable_token_in 
    // @param: _selector The selector of the function to call.
    // @param: _calldata The data to pass to the function.
    // @param: _calladata_len The length of the data.
    // @return: retdata The return data of the function call.
    // @return: retdata_len The length of the return data.
    func execute_max_allowance_container{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
            _container: felt,
            token_in_len: felt,
            token_in: felt*, 
            token_out_len: felt,
            token_out: felt*, 
            _allow_token_in: felt,
            disable_token_in_len: felt,
            disable_token_in: felt*,
            _selector: felt,
            _calldata_len: felt, 
            _calldata: felt*) -> (retdata_len: felt, retdata: felt*) {
        alloc_locals;
        if(_allow_token_in == 1){
            approve_token_list(token_in_len, token_in, Uint256(ALL_ONES, ALL_ONES));
            tempvar syscall_ptr = syscall_ptr;
            tempvar pedersen_ptr = pedersen_ptr;
            tempvar range_check_ptr = range_check_ptr;
        } else {
            tempvar syscall_ptr = syscall_ptr;
            tempvar pedersen_ptr = pedersen_ptr;
            tempvar range_check_ptr = range_check_ptr;
        }
        let (retdata_len: felt, retdata: felt*) = execute(_selector, _calldata_len, _calldata);
        if(_allow_token_in == 1){
            approve_token_list(token_in_len, token_in, Uint256(ALL_ONES, ALL_ONES));
            tempvar syscall_ptr = syscall_ptr;
            tempvar pedersen_ptr = pedersen_ptr;
            tempvar range_check_ptr = range_check_ptr;
        } else {
            tempvar syscall_ptr = syscall_ptr;
            tempvar pedersen_ptr = pedersen_ptr;
            tempvar range_check_ptr = range_check_ptr;
        }
        full_check(_container, token_in_len, token_in, token_out_len, token_out, disable_token_in_len, disable_token_in);
        return (retdata_len, retdata,);
    }

    // @notice: Safe execute
    // @param: _token_in
    // @param: _token_out
    // @param: _allow_token_in Check if the token_in is allowed
    // @param: _disable_token_in
    // @param: _selector The selector of the function to call.
    // @param: _calldata The data to pass to the function.
    // @param: _calladata_len The length of the data.
    // @return: retdata The return data of the function call.
    // @return: retdata_len The length of the return data.
    func safe_execute{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
            token_in_len: felt,
            token_in: felt*, 
            token_out_len: felt,
            token_out: felt*, 
            _allow_token_in: felt,
            disable_token_in_len: felt,
            disable_token_in: felt*,
            _selector: felt,
            _calldata_len: felt, 
            _calldata: felt*) -> (retdata_len: felt, retdata: felt*) {
        let (borrow_manager_) = borrow_manager.read();
        let (caller_) = get_caller_address();
        let (container_) = IBorrowManager.getContainerOrRevert(borrow_manager_, caller_);
        let (retdata_len: felt, retdata: felt*) = safe_execute_container(container_, token_in_len, token_in, token_out_len, token_out, _allow_token_in, disable_token_in_len, disable_token_in, _selector, _calldata_len, _calldata);
        return (retdata_len, retdata,);
    }

    // @notice: Safe execute
    // @param: _token_in
    // @param: _token_out
    // @param: _allow_token_in Check if the token_in is allowed
    // @param: _disable_token_in
    // @param: _selector The selector of the function to call.
    // @param: _calldata The data to pass to the function.
    // @param: _calladata_len The length of the data.
    // @return: retdata The return data of the function call.
    // @return: retdata_len The length of the return data.
    func safe_execute_container{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
            _container: felt,
            token_in_len: felt,
            token_in: felt*, 
            token_out_len: felt,
            token_out: felt*, 
            _allow_token_in: felt,
            disable_token_in_len: felt,
            disable_token_in: felt*,
            _selector: felt,
            _calldata_len: felt, 
            _calldata: felt*) -> (retdata_len: felt, retdata: felt*) {
        alloc_locals;
        if(_allow_token_in == 1){
            approve_token_list(token_in_len, token_in, Uint256(ALL_ONES, ALL_ONES));
            tempvar syscall_ptr = syscall_ptr;
            tempvar pedersen_ptr = pedersen_ptr;
            tempvar range_check_ptr = range_check_ptr;
        } else {
            tempvar syscall_ptr = syscall_ptr;
            tempvar pedersen_ptr = pedersen_ptr;
            tempvar range_check_ptr = range_check_ptr;
        }

        let (retdata_len: felt, retdata: felt*) = execute(_selector, _calldata_len, _calldata);

        if(_allow_token_in == 1){
            approve_token_list(token_in_len, token_in, Uint256(0, 0));
            tempvar syscall_ptr = syscall_ptr;
            tempvar pedersen_ptr = pedersen_ptr;
            tempvar range_check_ptr = range_check_ptr;
        } else {
            tempvar syscall_ptr = syscall_ptr;
            tempvar pedersen_ptr = pedersen_ptr;
            tempvar range_check_ptr = range_check_ptr;
        }

        full_check(_container, token_in_len, token_in, token_out_len, token_out, disable_token_in_len, disable_token_in);
        return (retdata_len, retdata,);
    }

    // @notice: Full check
    // @param: _container the container 
    // @param: _token_in
    // @param: _token_out
    // @param: _disable_token_in
    func full_check{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
            _container: felt, 
            token_in_len: felt,
            token_in: felt*, 
            token_out_len: felt,
            token_out: felt*, 
            disable_token_in_len: felt,
            disable_token_in: felt*) {
        alloc_locals;
        let (borrow_manager_) = borrow_manager.read();
        let (caller_) = get_caller_address();
        let (borrow_transit_) = borrow_transit.read();
        check_and_enable_token_list(token_out_len, token_out, borrow_manager_, _container);
        disable_token_list(token_in_len, token_in, disable_token_in_len, disable_token_in, borrow_manager_, _container);
        // If caller is borrow transit, it is a multicall 
        if(caller_ == borrow_transit_){
           return();
        } else {
            IBorrowManager.fullCollateralCheck(borrow_manager_, _container);
            return();
        }
    }

    // @notice: Check and optimize enable token
    // @param: _container The container
    func check_and_optimize_enabled_tokens{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
            _container: felt) {
        alloc_locals;
        let (borrow_manager_) = borrow_manager.read();
        let (caller_) = get_caller_address();
        let (borrow_transit_) = borrow_transit.read();
        if(caller_ == borrow_transit_){
           return();
        } else {
            IBorrowManager.checkAndOptimizeEnabledTokens(borrow_manager_, _container);
            return();
        }
    }

    func approve_token_list{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
            tokens_len: felt, tokens: felt*, amount: Uint256) {
        alloc_locals;
        if(tokens_len == 0){
            return();
        }
        approve_token(tokens[0], amount);
        return approve_token_list(tokens_len - 1, tokens + 1, amount,);
    }

    func check_and_enable_token_list{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
            tokens_len: felt, tokens: felt*, _borrow_manager: felt, _container: felt) {
        alloc_locals;
        if(tokens_len == 0){
            return();
        }
        IBorrowManager.checkAndEnableToken(_borrow_manager, _container, tokens[0]);
        return check_and_enable_token_list(tokens_len - 1, tokens + 1, _borrow_manager, _container,);
    }

    func disable_token_list{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
            tokens_len: felt, tokens: felt*, is_disable_len: felt, is_disable: felt*, _borrow_manager: felt, _container: felt) {
        alloc_locals;
        if(tokens_len == 0){
            return();
        }
        if(is_disable[0] == 0){
            return disable_token_list(tokens_len - 1, tokens + 1, is_disable_len - 1, is_disable + 1, _borrow_manager, _container,);
        } else {
            IBorrowManager.disableToken(_borrow_manager, _container, tokens[0]);
            return disable_token_list(tokens_len - 1, tokens + 1, is_disable_len - 1, is_disable + 1, _borrow_manager, _container,);
        }
    }

}
