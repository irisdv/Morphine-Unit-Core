%lang starknet

from starkware.cairo.common.uint256 import Uint256

@contract_interface
namespace IContainer {

    func connectTo(_borrow_manager: felt, _borrowed_amount: Uint256, _cumulative_index: Uint256) {
    }

    func updateParameters(_borrowed_amount: Uint256, _cumulative_index: Uint256) {
    }

    func approveToken(_token: felt, _contract: felt, _amount: Uint256) {
    }

    func cancelAllowance(_token: felt, _contract: felt) {
    }

    func safeTransfer(_token: felt, _to: felt, _amount: Uint256) {
    }

    func execute(_to: felt, _selector: felt, _calldata_len: felt, _calldata: felt*) -> (retdata_len: felt, retdata: felt*) {
    }


    func cumulativeIndex() -> (cumulative_index: Uint256) {
    }

    func borrowedAmount() -> (borrowed_amount: Uint256) {
    }

    func lastUpdate() -> (since: felt) {
    }


}
