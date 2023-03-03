%lang starknet

// Starkware dependencies
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.math import assert_not_zero
from starkware.cairo.common.uint256 import Uint256
from starkware.starknet.common.syscalls import get_block_timestamp, get_block_number

// OpenZeppelin dependencies
from openzeppelin.token.erc20.IERC20 import IERC20

// Project dependencies
from morphine.interfaces.IStrategies import IStrategies, IMinterStrategies

// Registery
const ADMIN = 'morphine-admin';
const TREASURY = 'morphine_treasyury';
const ORACLE_TRANSIT = 'oracle_transit';

// Token
const TOKEN_NAME = 'dai';
const TOKEN_SYMBOL = 'DAI';
const TOKEN_DECIMALS = 6;
const TOKEN_INITIAL_SUPPLY_LO = 1000000000000;
const TOKEN_INITIAL_SUPPLY_HI = 0;

// strategies
const NAME = 'morphine-strategies';
const SYMBOL = 'MSTRAT';
const USER = 'user';

@view
func __setup__{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    tempvar dai;
    tempvar registery;
    tempvar drip_hash;
    tempvar strategies;
    tempvar minter_strategies;
    %{
        ids.dai = deploy_contract("./tests/mocks/erc20.cairo", [ids.TOKEN_NAME, ids.TOKEN_SYMBOL, ids.TOKEN_DECIMALS, ids.TOKEN_INITIAL_SUPPLY_LO, ids.TOKEN_INITIAL_SUPPLY_HI, ids.ADMIN, ids.ADMIN]).contract_address 
        context.dai = ids.dai

        ids.drip_hash = declare("./lib/morphine/drip/drip.cairo").class_hash
        context.drip_hash = ids.drip_hash

        ids.registery = deploy_contract("./lib/morphine/registery.cairo", [ids.ADMIN, ids.TREASURY , ids.ORACLE_TRANSIT, ids.drip_hash]).contract_address 
        context.registery = ids.registery

        ids.strategies = deploy_contract("./lib/morphine/strat/strategies.cairo", [ids.NAME, ids.SYMBOL, ids.registery]).contract_address
        context.strategies = ids.strategies

        ids.minter_strategies = deploy_contract("./lib/morphine/strat/minterStrategies.cairo", [ids.strategies, ids.registery, ids.dai]).contract_address
        context.minter_strategies = ids.minter_strategies

        stop_pranks = [start_prank(ids.ADMIN, contract) for contract in [context.dai]]
    %}
    IERC20.approve(dai, ADMIN, Uint256(10000000, 0));
    IERC20.transferFrom(dai, ADMIN, USER, Uint256(10000000, 0));
    %{ [stop_prank() for stop_prank in stop_pranks] %}
    return ();
}

@external
func test_mint_nft{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;
    let (minter_strategies_) = minter_strategies_instance.deployed();
    let (strategies_) = strategies_instance.deployed();
    strategies_instance.setMinter(minter_strategies_);
    erc20_instance.approve(USER, minter_strategies_, Uint256(1000000, 0));

    %{ stop_pranks = [start_prank(ids.USER, contract) for contract in [context.minter_strategies] ] %}
    minter_strategies_instance.mint(
        2, cast(new ('123', '456'), felt*), 2, cast(new (500000, 500000), felt*)
    );
    let (balance_) = strategies_instance.balanceOf(USER);
    assert balance_.low = 1;
    let (owner_) = strategies_instance.ownerOf(Uint256(1, 0));
    assert owner_ = USER;
    return ();
}

@external
func test_transfer_strategy{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;
    let (minter_strategies_) = minter_strategies_instance.deployed();
    let (strategies_) = strategies_instance.deployed();
    strategies_instance.setMinter(minter_strategies_);
    erc20_instance.approve(USER, minter_strategies_, Uint256(1000000, 0));

    %{ stop_pranks = [start_prank(ids.USER, contract) for contract in [context.minter_strategies] ] %}
    minter_strategies_instance.mint(
        2, cast(new ('123', '456'), felt*), 2, cast(new (500000, 500000), felt*)
    );
    strategies_instance.transferFrom(USER, ADMIN, Uint256(1, 0));

    let (balance_user_) = strategies_instance.balanceOf(USER);
    assert balance_user_.low = 0;
    let (balance_admin_) = strategies_instance.balanceOf(ADMIN);
    assert balance_admin_.low = 1;
    let (owner_) = strategies_instance.ownerOf(Uint256(1, 0));
    assert owner_ = ADMIN;

    return ();
}

@external
func test_burn_strategy{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;
    let (minter_strategies_) = minter_strategies_instance.deployed();
    let (strategies_) = strategies_instance.deployed();
    strategies_instance.setMinter(minter_strategies_);
    erc20_instance.approve(USER, minter_strategies_, Uint256(1000000, 0));

    %{ stop_pranks = [start_prank(ids.USER, contract) for contract in [context.minter_strategies] ] %}
    minter_strategies_instance.mint(
        2, cast(new ('123', '456'), felt*), 2, cast(new (500000, 500000), felt*)
    );
    strategies_instance.burn(USER, Uint256(1, 0));

    let (balance_user_) = strategies_instance.balanceOf(USER);
    assert balance_user_.low = 0;
    %{ expect_revert(error_message="ERC721: owner query for nonexistent token") %}
    let (owner_) = strategies_instance.ownerOf(Uint256(1, 0));

    return ();
}

@external
func test_wrong_allocation{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    alloc_locals;
    let (minter_strategies_) = minter_strategies_instance.deployed();
    let (strategies_) = strategies_instance.deployed();
    strategies_instance.setMinter(minter_strategies_);
    erc20_instance.approve(USER, minter_strategies_, Uint256(1000000, 0));

    %{ stop_pranks = [start_prank(ids.USER, contract) for contract in [context.minter_strategies] ] %}
    %{ expect_revert(error_message="total token allocation must be equal to 100%") %}
    minter_strategies_instance.mint(
        2, cast(new ('123', '456'), felt*), 2, cast(new (100000, 500000), felt*)
    );

    return ();
}

namespace minter_strategies_instance {
    func deployed() -> (minter_strategies: felt) {
        tempvar minter_strategies;
        %{ ids.minter_strategies = context.minter_strategies %}
        return (minter_strategies,);
    }
    func mint{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        _tokens_len: felt, _tokens: felt*, _allocation_len: felt, _allocation: felt*
    ) {
        tempvar minter_strategies;
        %{ ids.minter_strategies = context.minter_strategies %}
        IMinterStrategies.mint(
            minter_strategies, _tokens_len, _tokens, _allocation_len, _allocation
        );
        return ();
    }
}

namespace strategies_instance {
    func deployed() -> (strategies: felt) {
        tempvar strategies;
        %{ ids.strategies = context.strategies %}
        return (strategies,);
    }
    func setMinter{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(_minter: felt) {
        tempvar strategies;
        %{
            ids.strategies = context.strategies 
            stop_pranks = [start_prank(ids.ADMIN, contract) for contract in [context.strategies] ]
        %}
        IStrategies.setMinter(strategies, _minter);
        %{ [stop_prank() for stop_prank in stop_pranks] %}
        return ();
    }

    func balanceOf{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        _owner: felt
    ) -> (balance: Uint256) {
        tempvar strategies;
        %{ ids.strategies = context.strategies %}
        let (balance_) = IStrategies.balanceOf(strategies, _owner);
        return (balance_,);
    }

    func ownerOf{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        _tokenId: Uint256
    ) -> (owner: felt) {
        tempvar strategies;
        %{ ids.strategies = context.strategies %}
        let (owner_) = IStrategies.ownerOf(strategies, _tokenId);
        return (owner_,);
    }

    func transferFrom{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        _from: felt, _to: felt, _token_id: Uint256
    ) {
        tempvar strategies;
        %{
            ids.strategies = context.strategies 
            stop_pranks = [start_prank(ids._from, contract) for contract in [context.strategies] ]
        %}
        IStrategies.approve(strategies, _to, _token_id);
        IStrategies.transferFrom(strategies, _from, _to, _token_id);
        return ();
    }

    func burn{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        _from: felt, _token_id: Uint256
    ) {
        tempvar strategies;
        %{
            ids.strategies = context.strategies 
            stop_pranks = [start_prank(ids._from, contract) for contract in [context.strategies] ]
        %}
        IStrategies.burn(strategies, _from, _token_id);
        return ();
    }
}

namespace erc20_instance {
    func approve{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        _user: felt, _to: felt, _amount: Uint256
    ) {
        tempvar dai;
        %{
            ids.dai = context.dai 
            stop_pranks = [start_prank(ids._user, contract) for contract in [context.dai] ]
        %}
        IERC20.approve(dai, _to, _amount);
        %{ [stop_prank() for stop_prank in stop_pranks] %}
        return ();
    }
}
