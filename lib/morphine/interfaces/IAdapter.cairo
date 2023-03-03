%lang starknet

from starkware.cairo.common.uint256 import Uint256

@contract_interface
namespace IAdapter {

    func borrowManager() -> (drip_manager: felt) {
    }

    func borrowTransit() -> (drip_transit: felt) {
    }

    func targetContract() -> (target: felt) {
    }
}
