%lang starknet

from starkware.cairo.common.uint256 import Uint256

@contract_interface
namespace IPool {

    // setters

    //owner stuff

    func pause() {
    }

    func unpause() {
    }

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

    func setForbidMask(forbidden_mask: Uint256) {
    }

    func setConfigurator(pool_configurator: felt) {
    }



    //supply stuff

    func deposit(_assets: Uint256, _receiver: felt) -> (shares: Uint256) {
    }

    func mint(_shares: Uint256, _receiver: felt) -> (assets: Uint256) {
    }

    func withdraw(_assets: Uint256, _receiver: felt, _owner: felt) -> (shares: Uint256) {
    }

    func redeem(_shares: Uint256, _receiver: felt, _owner: felt) -> (assets: Uint256) {
    }

    // max actions

    func maxDeposit(to: felt) -> (maxAssets: Uint256) {
    }

    func maxMint(to: felt) -> (maxShares: Uint256) {
    }

    func maxWithdraw(to: felt) -> (maxAssets: Uint256) {
    }

    func maxRedeem(to: felt) -> (maxShares: Uint256) {
    }

    

    //borrow stuff

    func borrow(borrow_amount: Uint256, drip: felt) {
    }

    func repayContainerDebt(borrowed_amount: Uint256, profit: Uint256, loss: Uint256) {
    }


    // getters

    func isPaused() -> (state: felt) {
    }

    func isBorrowFrozen() -> (state: felt) {
    }

    func interestRateModel() -> (interestRateModel: felt) {
    }

    func isBorrowModuleAllowed(caller: felt) -> (state: felt) {
    }

    func forbiddenMask() -> (forbiddenMask: Uint256) {
    }

    func borrowModuleMask(borrow_module: felt) -> (borrowModuleMask: Uint256) {
    }

    func borrowModuleByMask(borrow_module_mask: Uint256) -> (borrowModule: felt) {
    }

    func borrowModuleById(id: felt) -> (borrowModule: felt) {
    }

    func getRegistery() -> (registery: felt) {
    }

    func poolConfigurator() -> (poolConfigurator: felt) {
    }

    func asset() -> (asset: felt) {
    }

    func withdrawFee() -> (withdrawFee: Uint256) {
    }

    func expectedLiquidityLimit() -> (expectedLiquidityLimit: Uint256) {
    }

    func totalAssets() -> (totalManagedAssets: Uint256) {
    }

    func expectedLiquidity() -> (expectedLiquidity: Uint256) {
    }

    func availableLiquidity() -> (availableLiquidity: Uint256) {
    }

    // quote price

    func previewDeposit(_assets: Uint256) -> (shares: Uint256) {
    }

    func previewMint(_shares: Uint256) -> (assets: Uint256) {
    }

    func previewWithdraw(_assets: Uint256) -> (shares: Uint256) {
    }

    func previewRedeem(_shares: Uint256) -> (assets: Uint256) {
    }

    func convertToShares(_assets: Uint256) -> (shares: Uint256) {
    }

    func convertToAssets(_shares: Uint256) -> (assets: Uint256) {
    }

    // borrow info 

    func totalBorrowed() -> (totalBorrowed: Uint256) {
    }

    func borrowRate() -> (borrowRate: Uint256) {
    }

    func calcLinearCumulativeIndex() -> (cumulativeIndex: Uint256) {
    }

    func cumulativeIndex() -> (cumulativeIndex: Uint256) {
    }

    func lastUpdatedTimestamp() -> (lastUpdatedTimestamp: felt) {
    }




    // ERC 20 STUFF

    func name() -> (name: felt) {
    }

    func symbol() -> (symbol: felt) {
    }

    func totalSupply() -> (totalSupply: Uint256) {
    }

    func decimals() -> (decimals: felt) {
    }

    func balanceOf(account: felt) -> (balance: Uint256) {
    }

    func allowance(_owner: felt, _spender: felt) -> (remaining: Uint256) {
    }

    func transfer(recipient: felt, amount: Uint256) -> (success: felt) {
    }

    func transferFrom(sender: felt, recipient: felt, amount: Uint256) -> (success: felt) {
    }

    func approve(_spender: felt, amount: Uint256) -> (success: felt) {
    }

    func increaseAllowance(_spender: felt, added_value: Uint256) -> (success: felt) {
    }

    func decreaseAllowance(_spender: felt, subtracted_value: Uint256) -> (success: felt) {
    }
}
