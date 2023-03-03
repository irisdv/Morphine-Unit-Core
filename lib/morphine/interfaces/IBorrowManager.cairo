%lang starknet

from starkware.cairo.common.uint256 import Uint256
from morphine.interfaces.IBorrowTransit import Call

@contract_interface
namespace IBorrowManager {

    //
    // Externals
    //

    // pause

    func pause() {
    }

    func unpause() {
    }

    // Liquidation Emergency

    func checkEmergencyPausable(_caller: felt, _state: felt) -> (state: felt) {
    }

    // Container

    func openContainer(borrowed_amount: Uint256, on_belhalf_of: felt) -> (container: felt) {
    }

    func closeContainer(borrower: felt, type: felt, total_value: Uint256, payer: felt, to: felt) -> (remaining_funds: Uint256) {
    }

    // Container Management

    func addCollateral(payer: felt, container: felt, token: felt, amount: Uint256) {
    }

    func manageDebt(container: felt, amount: Uint256, increase: felt) -> (newBorrowedAmount: Uint256){
    }

    func approveContainer(borrower: felt, target: felt, token: felt,amount: Uint256) {
    }

    func executeOrder(_borrower: felt, _to: felt, _selector: felt, _calldata_len: felt, _calldata: felt*) -> (retdata_len: felt, retdata: felt*) {
    }

    func checkAndEnableToken(_container: felt, _token: felt){
    }

    func disableToken(container: felt, token: felt) -> (was_changed: felt) {
    }

    func transferContainerOwnership(_from : felt, _to: felt) {
    }

    // Security Check

    func fullCollateralCheck(container: felt) {
    }

    func checkAndOptimizeEnabledTokens(container: felt) {
    }

    // Configurator

    func addToken(token: felt) {
    }

    func setFees(fee_interest: Uint256, fee_liqudidation: Uint256, liquidation_discount: Uint256, fee_liqudidation_expired: Uint256, liquidation_discount_expired: Uint256,) {
    }

    func setLiquidationThreshold(token: felt, liquidation_threshold: Uint256) {
    }

    func setForbidMask(forbid_mask_: Uint256) {
    }

    func setMaxEnabledTokens(new_max_enabled_tokens: Uint256) {
    }

    func changeContractAllowance(adapter: felt, target: felt) {
    }

    func upgradeOracleTransit(oracle_transit: felt) {
    }

    func upgradeBorrowTransit(borrow_transit: felt) {
    }

    func setBorrowConfigurator(borrow_configurator: felt) {
    }

    func addEmergencyLiquidator(liquidator : felt) {
    }
    
    func removeEmergencyLiquidator(liquidator : felt) {
    }


    //
    // Views
    //


    // Pause

    func isPaused() -> (state: felt) {
    }

    // Token

    func underlying() -> (underlying: felt) {
    }

    func allowedTokensLength() -> (tokenLength: felt) {
    }

    func maxAllowedTokensLength() -> (maxAllowedTokenLength: Uint256) {
    }


    func tokenMask(token: felt) -> (token_mask: Uint256) {
    }

    func enabledTokensMap(container: felt) -> (enabledTokensMap: Uint256) {
    }

    func forbiddenTokenMask() -> (forbiden_token_mask: Uint256) {
    }

    func tokenByMask(_token_mask: Uint256) -> (token: felt) {
    }
    
    func tokenById(_id: felt) -> (token: felt) {
    }

    func liquidationThreshold(token: felt) -> (liquidationThresold: Uint256) {
    }
    
    func liquidationThresholdByMask(_token_mask: Uint256) -> (liquidation_threshold: Uint256) {
    }
    
    func liquidationThresholdById(_id: felt) -> (liquidation_threshold: Uint256) {
    }

    // Contracts

    func adapterToContract(adapter: felt) -> (contract: felt) {
    }

    func contractToAdapter(contract: felt) -> (adapter: felt) {
    }

    // Parameters

    func feeInterest() -> (fee_interest: Uint256) {
    }

    func feeLiquidation() -> (fee_liquidation: Uint256) {
    }

    func feeLiquidationExpired() -> (fee_liqudidation_expired: Uint256) {
    }

    func liquidationDiscount() -> (liquidation_discount: Uint256) {
    }

    func liquidationDiscountExpired() -> (liquidation_discount_expired: Uint256) {
    }

    func canLiquidateWhilePaused(liquidator: felt) -> (state: felt) {
    }

    // Dependencies

    func getPool() -> (pool: felt) {
    }

    func borrowTransit() -> (borrowTransit: felt) {
    }

    func borrowConfigurator() -> (configurator: felt) {
    }

    func oracleTransit() -> (oracleTransit: felt) {
    }

    // Container

    func getContainer(borrower: felt) -> (container: felt) {
    }

    func getContainerOrRevert(borrower: felt) -> (container: felt) {
    }

    func containerParameters(container: felt) -> (borrowedAmount: Uint256, cumulativeIndex: Uint256, currentCumulativeIndex: Uint256) {
    }

    // Calcul

    func calcContainerAccruedInterest(_container: felt) -> (borrowedAmount: Uint256, borrowedAmountWithInterest: Uint256, borrowedAmountWithInterestAndFees: Uint256) {
    }

    func calcClosePayments(_total_value: Uint256, _type: felt, _borrowed_amount: Uint256, _borrowed_amount_with_interests: Uint256) -> (amount_to_pool: Uint256, remaining_funds: Uint256, profit: Uint256, loss: Uint256) {
    }

    func calcEnabledTokens(_enabled_tokens: Uint256, _cum_total_tokens_enabled: Uint256) -> (total_tokens_enabled: Uint256){
    }

    func getMaxIndex(_mask: Uint256) -> (max_index: Uint256){
    }

}
