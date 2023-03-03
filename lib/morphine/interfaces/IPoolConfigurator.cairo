%lang starknet

from starkware.cairo.common.uint256 import Uint256

@contract_interface
namespace IPoolConfigurator {

    func freezeBorrow() {
    }

    func unfreezeBorrow() {
    }

    func setWithdrawFee(withdraw_fee: Uint256) {
    }

    func setExpectedLiquidityLimit(_expected_liquidity_limit: Uint256) {
    }

    func updateInterestRateModel(interest_rate_model: felt) {
    }

    func connectBorrowModule(borrow_module: felt) {
    }

    func forbidBorrowModule(borrow_module: felt) {
    }

    func upgradeConfigurator(pool_configurator: felt) {
    }

    func getPool() -> (pool: felt) {
    }


}
