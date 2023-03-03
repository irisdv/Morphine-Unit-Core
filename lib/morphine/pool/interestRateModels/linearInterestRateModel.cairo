%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256
from openzeppelin.security.safemath.library import SafeUint256
from starkware.cairo.common.uint256 import (
    uint256_check,
    uint256_le,
    uint256_eq
)
from morphine.utils.various import PRECISION

/// @title Linear Interest rate model
/// @author 0xSacha
/// @dev Contract Used to calculate borrow rate, respecting the linear interest rate model
/// @custom:experimental This is an experimental contract.


@storage_var
func slope1() -> (res: Uint256) {
}

@storage_var
func slope2() -> (res: Uint256) {
}

@storage_var
func availableLiquidity() -> (res: Uint256) {
}

@storage_var
func base_rate() -> (res: Uint256) {
}

@storage_var
func optimal_liquidity_utilization() -> (res: Uint256) {
}

// @notice Constructor
// @param _optimal_liquidity_utilization optimal liquidity utilization
// @param _slope1 slope1
// @param _slope2 slope2
// @param _base_rate base_rate
@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    _optimal_liquidity_utilization: Uint256,
    _slope1: Uint256,
    _slope2: Uint256,
    _base_rate: Uint256) {
    alloc_locals;
    let (is_optimal_liquidity_utilization_in_range_) = uint256_le(
        _optimal_liquidity_utilization, Uint256(PRECISION, 0)
    );
    let (is_base_rate_in_range_) = uint256_le(
        _optimal_liquidity_utilization, Uint256(PRECISION, 0)
    );
    let (is_slop1_in_range_) = uint256_le(_slope1, Uint256(PRECISION, 0));
    let (is_slop2_in_range_) = uint256_le(_slope2, Uint256(PRECISION, 0));

    with_attr error_message("Parameter out of range") {
        assert is_optimal_liquidity_utilization_in_range_ * is_base_rate_in_range_ * is_slop1_in_range_ * is_slop2_in_range_ = 1;
    }

    optimal_liquidity_utilization.write(_optimal_liquidity_utilization);
    slope1.write(_slope1);
    slope2.write(_slope2);
    base_rate.write(_base_rate);
    return ();
}

// @notice calculate the borrow rate
// @param _expected_liqudity expected liquidity
// @param _available_liquidity available liquidity
// @return borrowRate return the borrow rate
@external
func calcBorrowRate{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(_expected_liqudity: Uint256, _available_liquidity: Uint256) -> (
    borrowRate: Uint256
) {
    alloc_locals;
    let (is_expected_liquidity_nul_) = uint256_eq(_expected_liqudity, Uint256(0, 0));
    // prevent from sending token to the pool
    let (is_expected_liquidity_le_expected_liquidity_) = uint256_le(
        _expected_liqudity, _available_liquidity
    );
    let (base_rate_) = base_rate.read();
    if (is_expected_liquidity_nul_ + is_expected_liquidity_le_expected_liquidity_ != 0) {
        return (base_rate_,);
    }

    //                      expected_liquidity_last_update - available_liquidity
    // liquidity_utilization_ = -------------------------------------
    //                               expected_liquidity_last_update

    let (step1_) = SafeUint256.sub_lt(_expected_liqudity, _available_liquidity);
    let (step2_) = SafeUint256.mul(step1_, Uint256(PRECISION, 0));
    let (liquidity_utilization_, _) = SafeUint256.div_rem(step2_, _expected_liqudity);
    let (optimal_liquidity_utilization_) = optimal_liquidity_utilization.read();
    let (is_utilization_le_optimal_utilization_) = uint256_le(
        liquidity_utilization_, optimal_liquidity_utilization_
    );

    // if liquidity_utilization_ <= optimal_liquidity_utilization_:
    
    //                                    liquidity_utilization_
    // borrow_rate = base_rate +  slope1 * -----------------------------
    //                                     optimal_liquidity_utilization_

    let (slop1_) = slope1.read();
    if (is_utilization_le_optimal_utilization_ == 1) {
        let (step1_) = SafeUint256.mul(liquidity_utilization_,slop1_);
        let (step2_, _) = SafeUint256.div_rem(step1_, optimal_liquidity_utilization_);
        let (borrow_rate_) = SafeUint256.add(step2_, base_rate_);
        return (borrow_rate_,);
    } else {
        // if liquidity_utilization_ >= optimal_liquidity_utilization_:
        //
        //                                           liquidity_utilization_ - optimal_liquidity_utilization_
        // borrow_rate = base_rate + slope1 + slope2 * ------------------------------------------------------
        //                                              1 - optimal_liquidity_utilization

        let (slop2_) = slope2.read();
        let (step1_) = SafeUint256.sub_le(liquidity_utilization_ , optimal_liquidity_utilization_);
        let (step2_) = SafeUint256.mul(slop2_, step1_);
        let (step3_) = SafeUint256.sub_le(Uint256(PRECISION, 0), optimal_liquidity_utilization_);
        let (step4_,_) = SafeUint256.div_rem(step2_, step3_);
        let (step5_) = SafeUint256.add(step4_, slop1_);
        let (borrow_rate_) = SafeUint256.add(step5_, base_rate_);
        return (borrow_rate_,);
    }
}

// @notice modelize all the parameters need in order to calculate the interest rate
// @param _expected_liqudity expected liquidity
// @param _available_liquidity available liquidity
// @return borrowRate return the borrow rate
@view
func modelParameters{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    optimalLiquidityUtilization: Uint256,
    baseRate: Uint256,
    slope1: Uint256,
    slope2: Uint256) {
    alloc_locals;
    let (optimal_liquidity_utilization_) = optimal_liquidity_utilization.read();
    let (base_rate_) = base_rate.read();
    let (slop1_) = slope1.read();
    let (slop2_) = slope2.read();
    return(optimal_liquidity_utilization_, base_rate_, slop1_, slop2_);
}