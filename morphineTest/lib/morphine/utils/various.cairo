from starkware.cairo.common.math import split_felt, unsigned_div_rem
from starkware.cairo.common.math_cmp import is_le
from starkware.cairo.common.uint256 import uint256_unsigned_div_rem, uint256_mul
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.cairo_builtins import HashBuiltin

const APPROVE_SELECTOR = 73937833738373;
const PRECISION = 1000000;
const SECONDS_PER_YEAR = 31536000;
const DEFAULT_FEE_INTEREST = 100000;
const DEFAULT_LIQUIDATION_PREMIUM = 50000;
const DEFAULT_FEE_LIQUIDATION = 9950;
const DEFAULT_FEE_LIQUIDATION_EXPIRED_PREMIUM = 50000;
const DEFAULT_FEE_LIQUIDATION_EXPIRED = 9950;
const MAX_WITHDRAW_FEE = 10000;
const DEFAULT_LIMIT_PER_BLOCK_MULTIPLIER = 5;
const ALL_ONES = 2 ** 128 - 1;
const EMPIRIC_ORACLE_ADDRESS = 0x446812bac98c08190dee8967180f4e3cdcd1db9373ca269904acb17f67f7093;

func uint256_permillion{pedersen_ptr: HashBuiltin*, range_check_ptr}(
    x: Uint256, permillion: Uint256
) -> (res: Uint256) {
    let (mul, _high) = uint256_mul(x, permillion);
    let (res, _) = uint256_unsigned_div_rem(mul, Uint256(PRECISION, 0));
    return (res=res);
}
