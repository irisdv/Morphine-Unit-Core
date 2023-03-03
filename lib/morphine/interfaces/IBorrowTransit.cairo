%lang starknet

from starkware.cairo.common.uint256 import Uint256

struct Call {
    to: felt,
    selector: felt,
    calldata_len: felt,
    calldata: felt*,
}

// Tmp struct introduced while we wait for Cairo
// to support passing `[AccountCall]` to __execute__
struct AccountCallArray {
    to: felt,
    selector: felt,
    data_offset: felt,
    data_len: felt,
}

struct tokenAndBalance {
    token: felt,
    balance: Uint256,
}

@contract_interface
namespace IBorrowTransit {


    // 
    // Externals
    //


    // Container

    func openContainer(_amount: Uint256, _on_belhalf_of: felt, _leverage_factor: Uint256){
    }

    func openContainerMultiCall(_borrowed_amount: Uint256, _on_belhalf_of: felt, _call_array_len: felt, _call_array: AccountCallArray*, _calldata_len: felt, _calldata: felt*){
    }

    func closeContainer(_to: felt, _call_array_len: felt, _call_array: AccountCallArray*, _calldata_len: felt, _calldata: felt*){
    }

    func liquidateContainer(_borrower: felt, _to: felt, _call_array_len: felt, _call_array: AccountCallArray*, _calldata_len: felt, _calldata: felt*){
    }

    func liquidateExpiredContainer(_borrower: felt, _to: felt, _call_array_len: felt, _call_array: AccountCallArray*, _calldata_len: felt, _calldata: felt*){
    }

    // Container Management

    func increaseDebt(_amount: Uint256){
    }

    func decreaseDebt(_amount: Uint256){
    }

    func addCollateral(_on_belhalf_of: felt, _token: felt, _amount: Uint256){
    }

    func multicall(_call_array_len: felt, _call_array: AccountCallArray*, _calldata_len: felt, _calldata: felt*){
    }

    func enableToken(_token: felt){
    }

    func approve(_target: felt, _token: felt, _amount: Uint256){
    }

    func transferContainerOwnership(_to: felt){
    }

    func approveContainerTransfers(_from: felt, _state: felt){
    }

    // Configurator

    func setIncreaseDebtForbidden(state: felt) {
    }

    func setMaxBorrowedAmountPerBlock(max_borrowed_amount_per_block: Uint256) {
    }

    func setBorrowLimits(minimum_borrowed_amount: Uint256, maximum_borrowed_amount: Uint256) {
    }

    func setExpirationDate(expiration_date: felt) {
    }


    //
    // Views
    //

    // Dependencies

    func borrowManager() -> (borrow_manager: felt) {
    }  

    func getNft() -> (nft: felt) {
    }       

    // Expiration

    func isExpired() -> (state: felt) {
    }  

    // Calcul

    func calcTotalValue(_container: felt) -> (total: Uint256, twv: Uint256){
    }

    func calcContainerHealthFactor(_container: felt) -> (health_factor: Uint256){
    }

    // Control

    func hasOpenedContainer(borrower: felt) -> (state: felt) {
    }  

    func isTokenAllowed(token: felt) -> (state: felt) {
    }  

    // Parameters

    func isIncreaseDebtForbidden() -> (is_increase_debt_forbidden: felt) {
    }
     
    func maxBorrowedAmountPerBlock() -> (max_borrowed_amount_per_block: Uint256) {
    }

    func expirationDate() -> (expiration_date: felt) {
    }

    func isExpirable() -> (state: felt) {
    }   

    func limits() -> (minimum_borrowed_amount: Uint256, max_borrowed_amount: Uint256) {
    }         

    func lastLimitSaved() -> (last_limit_saved: Uint256){
    }
    
    func lastBlockSaved() -> (last_block_saved: felt){
    }

    func isTransferAllowed(_from: felt, to: felt) -> (is_allowed : felt){
    }

}
