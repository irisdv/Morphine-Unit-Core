%lang starknet

from starkware.cairo.common.uint256 import Uint256

struct AllowedToken {
    address: felt,  // Address of token
    liquidation_threshold: Uint256,  // LT for token in range 0..1,000,000 which represents 0-100%
}

@contract_interface
namespace IBorrowConfigurator {

    //
    // externals
    //

    // Token Management

    func setMaxEnabledTokens(new_max_enabled_tokens: Uint256) {
    }

    func addToken(_token: felt, _liquidation_threshold: Uint256){
    }

    func setLiquidationThreshold(_token: felt, _liquidation_threshold: Uint256){
    }

    func allowToken(_token: felt){
    }

    func forbidToken(_token: felt){
    }

    // Allowed Contracts Management

    func allowContract(_contract: felt, _adapter: felt){
    }

    func forbidContract(_contract: felt){
    }

    // Parameters Management

    func setLimits(_minimum_borrowed_amount: Uint256, _maximum_borrowed_amount: Uint256){
    }

    func setFees(_fee_interest: Uint256, _fee_liquidation: Uint256, _liquidation_premium: Uint256, fee_liquidation_expired: Uint256, liquidation_premium_expired: Uint256){
    }

    func setIncreaseDebtForbidden(_state: felt){
    }

    func setLimitPerBlock(_new_limit: Uint256){
    }

    func setExpirationDate(_new_expiration_date: felt){
    }

    func addEmergencyLiquidator(_liquidator: felt){
    }

    func removeEmergencyLiquidator(_liquidator: felt){
    }


    // Dependencies Management

    func upgradeOracleTransit(){
    }

    func upgradeBorrowTransit(_borrow_transit: felt, _migrate_parameters: felt){
    }

    func upgradeBorrowConfigurator(_borrow_configurator: felt){
    }


    //
    // View
    //

    // Allowed contracts 

    func allowedContractsLength() -> (allowedContractsLength: felt){
    }

    func idToAllowedContract(id: felt) -> (allowedContract: felt){
    }

    func allowedContractToId(_allowed_contract: felt) -> (id: felt){
    }

    func isAllowedContract(_contract: felt) -> (state: felt){
    }

    // Dependencies 

    func borrowManager() -> (borrowManager: felt){
    }

}
