%lang starknet

from starkware.starknet.common.syscalls import (
    get_tx_info,
    get_block_number,
    get_block_timestamp,
    get_contract_address,
    get_caller_address,
)
from starkware.cairo.common.math_cmp import is_le, is_nn, is_not_zero
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.uint256 import (
    uint256_sub,
    uint256_check,
    uint256_le,
    uint256_lt,
    uint256_eq,
    uint256_add,
    uint256_mul,
    uint256_unsigned_div_rem,
)
from morphine.utils.utils import (
    felt_to_uint256,
    uint256_div,
    uint256_percent,
    uint256_mul_low,
    uint256_pow,
)
from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import deploy
from openzeppelin.token.erc20.IERC20 import IERC20
from starkware.cairo.common.math import assert_not_zero
from openzeppelin.security.pausable.library import Pausable
from openzeppelin.security.reentrancyguard.library import ReentrancyGuard
from morphine.utils.RegisteryAccess import RegisteryAccess
from morphine.interfaces.IContainer import IContainer
from morphine.interfaces.IRegistery import IRegistery

/// @title Container Factory
/// @author 0xSacha
/// @dev Contract Contract Factory with recycling mechanisms
/// @custom:experimental This is an experimental contract.


// Events

@event
func NewContainer(container: felt) {
}

@event
func ContainerTaken(container: felt, caller: felt) {
}

@event
func ContainerReturned(container: felt) {
}

@event
func ContainerTakenForever(container: felt, caller: felt) {
}

// Storage var

@storage_var
func next_container(address: felt) -> (address: felt) {
}

@storage_var
func head() -> (address: felt) {
}

@storage_var
func tail() -> (address: felt) {
}

@storage_var
func containers_length() -> (len: felt) {
}

@storage_var
func is_container(address: felt) -> (is_container_account: felt) {
}

@storage_var
func id_to_container(id: felt) -> (container: felt) {
}

@storage_var
func container_to_id(address: felt) -> (container_id: felt) {
}


@storage_var
func salt() -> (res: felt) {
}


// Protector

// @notice: only_borrow_manager
// @dev: check if caller is borrow manager
func only_borrow_manager{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    let (registery_) = RegisteryAccess.registery();
    let (caller_: felt) = get_caller_address();
    let (state_: felt) = IRegistery.isBorrowManager(registery_, caller_);
    with_attr error_message("caller is not a borrow manager") {
        assert state_ = 1;
    }
    return ();
}

// Constructor

// @notice: Container Factory Constructor
// @param: _registery Registery (felt)
@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    _registery: felt
) {
    with_attr error_message("zero address") {
        assert_not_zero(_registery);
    }
    RegisteryAccess.initializer(_registery);
    addContainer();
    let (tail_) = tail.read();
    head.write(tail_);
    next_container.write(0, 0);
    return ();
}

// View

// @notice: Next Container
// @param: _container Container (felt)
// @return: container Next container (felt)
@view
func nextContainer{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(_container: felt) -> (
    container: felt
) {
    let (next_) = next_container.read(_container);
    return (next_,);
}

// @notice: Containers Length
// @return: containerLength Total Container Length  (felt)
@view
func containersLength{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    containerLength: felt
) {
    let (containers_length_) = containers_length.read();
    return (containers_length_,);
}

// @notice: ID To Container
// @param: _id Container ID (felt)
// @return: container Container (felt)
@view
func idToContainer{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(_id: felt) -> (
    container: felt
) {
    let (container_) = id_to_container.read(_id);
    return (container_,);
}

// @notice: Container To ID
// @param: _container Container (felt)
// @return: id Container ID (felt)
@view
func containerToId{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(_container: felt) -> (
    id: felt
) {
    let (id_) = container_to_id.read(_container);
    return (id_,);
}

// @notice: Is Container
// @param: _container Container (felt)
// @return: state 1 if is Container, 0 else (felt)
@view
func isContainer{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(_container: felt) -> (
    state: felt
) {
    let (state_) = is_container.read(_container);
    return (state_,);
}

// @notice: Container Stock Length
// @dev: Unused containers are stored to save gas for new Container
// @return: length Container Stock Length (felt)
@view
func containerStockLength{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    length: felt
) {
    let (head_) = head.read();
    let (tail_) = tail.read();
    let (length_) = recursive_stock_length(head_, tail_, 0);
    return (length_,);
}

// @notice: add Container
// @dev: Deploy a new Container
@external
func addContainer{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;
    let (new_container_: felt) = deploy_container_account();
    let (tail_: felt) = tail.read();
    next_container.write(tail_, new_container_);
    tail.write(new_container_);
    let (container_length_: felt) = containers_length.read();
    id_to_container.write(container_length_, new_container_);
    container_to_id.write(new_container_, container_length_);
    is_container.write(new_container_, 1);
    containers_length.write(container_length_ + 1);
    NewContainer.emit(new_container_);
    return ();
}

// @notice: Take Container
// @dev: Function Used by Container Manager for new borrower
// @param: _borrowed_amount Borrowed Amount (Uint256)
// @param: _cumulative_index Cumulative Index (Uint256)
// @return: address Container Address (felt)
@external
func takeContainer{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    _borrowed_amount: Uint256, _cumulative_index: Uint256
) -> (address: felt) {
    alloc_locals;
    only_borrow_manager();
    check_stock();
    let (caller_) = get_caller_address();
    let (container_: felt) = head.read();
    let (next_) = next_container.read(container_);
    head.write(next_);
    next_container.write(container_, 0);
    IContainer.connectTo(container_, caller_, _borrowed_amount, _cumulative_index);
    ContainerTaken.emit(container_, caller_);
    return (container_,);
}

// @notice: Return Container
// @dev: Function Used by Container Manager when closing Container
// @param: _used_container Used Container (felt)
@external
func returnContainer{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(_used_container: felt) {
    alloc_locals;
    only_borrow_manager();
    let (is_container_) = is_container.read(_used_container);
    with_attr error_message("external containers forbidden") {
        assert is_container_ = 1;
    }
    let (since_) = IContainer.lastUpdate(_used_container);
    let (block_timestamp_) = get_block_timestamp();
    with_attr error_message("can not return container in the same block") {
        assert_not_zero(block_timestamp_ - since_);
    }
    let (tail_) = tail.read();
    next_container.write(tail_, _used_container);
    tail.write(_used_container);
    ContainerReturned.emit(_used_container);
    return ();
}

// @notice: Take Out
// @dev: Function Used by the Admin to Remove a bad Container
// @param: _prev Previous Container (felt)
// @param: _container Container to remove (felt)
// @param: _to Address to connect Container (felt)
@external
func takeOut{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    _prev: felt, _container: felt, _to: felt
) {
    alloc_locals;
    RegisteryAccess.assert_only_owner();
    check_stock();
    let (head_: felt) = head.read();
    if (head_ == _container) {
        let (new_head_: felt) = next_container.read(head_);
        head.write(new_head_);
        next_container.write(head_, 0);
        IContainer.connectTo(_container, _to, Uint256(0, 0), Uint256(0, 0));
        let (length_) = containers_length.read();
        let (last_container_) = id_to_container.read(length_ - 1);
        let (container_to_remove_id_) = container_to_id.read(_container);
        id_to_container.write(container_to_remove_id_, last_container_);
        id_to_container.write(length_ - 1, 0);
        container_to_id.write(last_container_, container_to_remove_id_);
        container_to_id.write(_container, 0);
        is_container.write(_container, 0);
        containers_length.write(length_ - 1);
        ContainerTakenForever.emit(_container, _to);
        return ();
    }

    with_attr error_message("zero address") {
        assert_not_zero(_container);
    }

    let (next_prev_) = next_container.read(_prev);
    with_attr error_message("account not in stock") {
        assert next_prev_ = _container;
    }
    let (tail_) = tail.read();
    if (_container == tail_) {
        tail.write(_prev);
        next_container.write(_prev, 0);
        IContainer.connectTo(_container, _to, Uint256(0, 0), Uint256(0, 0));
        let (length_) = containers_length.read();
        let (last_container_) = id_to_container.read(length_ - 1);
        let (container_to_remove_id_) = container_to_id.read(_container);
        id_to_container.write(container_to_remove_id_, last_container_);
        id_to_container.write(length_ - 1, 0);
        container_to_id.write(last_container_, container_to_remove_id_);
        container_to_id.write(_container, 0);
        is_container.write(_container, 0);
        containers_length.write(length_ - 1);
        ContainerTakenForever.emit(_container, _to);
        return ();
    } else {
        let (next_container_) = next_container.read(_container);
        next_container.write(_prev, next_container_);
        next_container.write(_container, 0);
        IContainer.connectTo(_container, _to, Uint256(0, 0), Uint256(0, 0));
        let (length_) = containers_length.read();
        let (last_container_) = id_to_container.read(length_ - 1);
        let (container_to_remove_id_) = container_to_id.read(_container);
        id_to_container.write(container_to_remove_id_, last_container_);
        id_to_container.write(length_ - 1, 0);
        container_to_id.write(last_container_, container_to_remove_id_);
        container_to_id.write(_container, 0);
        is_container.write(_container, 0);
        containers_length.write(length_ - 1);
        ContainerTakenForever.emit(_container, _to);
        return ();
    }
}

// Internals

// @notice: deploy_container_account 
// @return: contract_address Container Deployed Address (felt)
func deploy_container_account{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    contract_address: felt
) {
    let (registery_) = RegisteryAccess.registery();
    let (class_hash_) = IRegistery.containerHash(registery_);
    let (call_data_) = alloc();
    let (salt_) = salt.read();
    let (contract_address_) = deploy(class_hash_, salt_, 0, call_data_, 0);
    salt.write(salt_ + 1);
    return (contract_address_,);
}


// @notice: check_stock
// @dev: Check for eventuals Containers in Stock and deploy if nothing is stock
func check_stock{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    let (head_: felt) = head.read();
    let (next_head_) = next_container.read(head_);
    if (next_head_ == 0) {
        addContainer();
        return ();
    }
    return ();
}

// @notice: recursive_stock_length 
// @dev: Calculate container Stock Length
// @param: _temp_head Temp Head (felt)
// @param: _tail Container Tail (felt)
// @param: _count Container Cumulative Count (felt)
// @return: count Container Stock Length (felt)
func recursive_stock_length{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    _temp_head: felt, _tail: felt, _count: felt
) -> (count: felt) {
    if (_temp_head == 0) {
        return (_count,);
    }
    let (next_head_) = next_container.read(_temp_head);
    return recursive_stock_length(next_head_, _tail, _count + 1);
}
