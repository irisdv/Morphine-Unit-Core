%lang starknet

from openzeppelin.access.ownable.library import Ownable

from starkware.cairo.common.cairo_builtins import HashBuiltin

from starkware.starknet.common.syscalls import get_caller_address

from starkware.cairo.common.math import (
    assert_not_zero,
    assert_not_equal,
)

from starkware.cairo.common.math_cmp import is_le

/// @title: Registery
/// @author: Morphine team
/// @dev: this contract is like our registery where you can find all useful contract address
/// @custom: experimental This is an experimental contract.

@storage_var
func treasury() -> (treasury : felt) {
}

@storage_var
func container_factory() -> (container_factory : felt) {
}

@storage_var
func oracle_transit() -> (address : felt) {
}

@storage_var
func container_hash() -> (address : felt) {
}

@storage_var
func pools_length() -> (len: felt) {
}

@storage_var
func is_pool(address: felt) -> (is_container_account: felt) {
}

@storage_var
func id_to_pool(id: felt) -> (container: felt) {
}

// @notice: Constructor call only once when contract is deployed
// @param: _owner: Owner of the contract
// @param: _treasury: Address of the treasury contract
// @param: _oracle_transit: Address of the oracle transit contract
// @param: _container_hash : container hash 
@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(_owner : felt, _treasury: felt, _oracle_transit: felt, _container_hash: felt) {
    Ownable.initializer(_owner);
    treasury.write(_treasury);
    oracle_transit.write(_oracle_transit);
    container_hash.write(_container_hash);
    return();
}

// @notice: get treasury address
// @return: treasury address
@view
func getTreasury{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (treasury : felt) {
    let (treasury_) = treasury.read();
    return(treasury_,);
}

// @notice: get container factory address
// @return: container factory address
@view
func containerFactory{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (container_factory : felt) {
    let (container_factory_) = container_factory.read();
    return(container_factory_,);
}

// @notice: get container hash
// @return: container_hash container hash 
@view
func containerHash{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (container_hash : felt) {
    let (container_hash_) = container_hash.read();
    return(container_hash_,);
}

// @notice: get owner address
// @return: owner address
@view
func owner{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (owner : felt) {
    let (owner_) = Ownable.owner();
    return(owner_,);
}

// @notice: get oracle transit address
// @return: oracle transit address
@view
func oracleTransit{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (oracle : felt) {
    let (oracle_) = oracle_transit.read();
    return(oracle_,);
}

// @notice: check if address is a pool
// @param: _pool: address to check
// @return: is_pool: true if address is a pool
@view
func isPool{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(_pool: felt) -> (state : felt) {
    let (state_) = is_pool.read(_pool);
    return(state_,);
}

// @notice: check if address is a borrow manager
// @param: _container_manager: address to check
// @return: is_borrow_manager: true if address is a borrow manager
@view
func isBorrowManager{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(_borrow_manager: felt) -> (state : felt) {
    // To complete

    return(0,);
}

// @notice: get pool address by id
// @param: _id: id of the pool
// @return: pool address
@view
func idToPool{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(_id: felt) -> (pool : felt) {
    let (len) = pools_length.read();
    let (pool_) = id_to_pool.read(_id);
    return(pool_,);
}

// @notice: get pools length
// @return: pools length
@view
func poolsLength{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (poolsLength : felt) {
    let (pools_length_) = pools_length.read();
    return(pools_length_,);
}

// @notice: set new owner
// @param: _newOwner: new owner address
@external
func setOwner{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(_new_owner : felt) {
    Ownable.assert_only_owner();
    Ownable.transfer_ownership(_new_owner);
    return();
}

// @notice: set new treasury address
// @param: _newTreasury: new treasury address
@external
func setTreasury{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(_new_treasury: felt) {
    Ownable.assert_only_owner();
    with_attr error_message("Treasury: address is zero") {
        assert_not_zero(_new_treasury);
    }
    treasury.write(_new_treasury);
    return();
}

// @notice: set new Container factory address
// @param: _newContainerFactory: new Container factory address
@external
func setContainerFactory{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(_container_factory: felt) {
    Ownable.assert_only_owner();
    with_attr error_message("Container factory: address is zero") {
        assert_not_zero(_container_factory);
    }
    container_factory.write(_container_factory);
    return();
}

// @notice: set new oracle transit address
// @param: _newOracleTransit: new oracle transit address
@external
func setOracleTransit{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(_new_oracle_transit : felt) {
    Ownable.assert_only_owner();
    with_attr error_message("Oracle transit: address is zero") {
        assert_not_zero(_new_oracle_transit);
    }
    oracle_transit.write(_new_oracle_transit);
    return();
}

// @notice: set new container hash 
// @param: _newContainerHash: new container hash address
@external
func setContainerHash{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(_new_container_hash : felt) {
    Ownable.assert_only_owner();
    with_attr error_message("Container hash: hash is zero") {
        assert_not_zero(_new_container_hash);
    }
    container_hash.write(_new_container_hash);
    return();
}

// @notice: add new pool
// @param: _pool: new pool address
@external
func addPool{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(_pool : felt)  {
    Ownable.assert_only_owner();
    let (pool_exists_) = is_pool.read(_pool);
    with_attr error_message("Pool: already exist"){
        assert pool_exists_ = 0;
    }
    with_attr error_message("Pool: address is zero"){
        assert_not_zero(_pool);
    }
    is_pool.write(_pool, 1);
    let (pools_length_) = pools_length.read();
    id_to_pool.write(pools_length_, _pool);
    pools_length.write(pools_length_ + 1);
    return();
}


