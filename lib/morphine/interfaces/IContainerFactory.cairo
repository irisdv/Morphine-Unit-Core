%lang starknet

from starkware.cairo.common.uint256 import Uint256

@contract_interface
namespace IContainerFactory {

    func addContainer() {
    }

    func takeContainer(_borrowed_amount: Uint256, _cumulative_index: Uint256) -> (address: felt) {
    }

    func returnContainer(_used_container: felt) {
    }

    func takeOut(_prev: felt, _container: felt, _to: felt) {
    }
    
    func nextContainer(_container: felt) -> (container: felt) {
    }

    func containersLength() -> (containerLength: felt) {
    }

    func idToContainer(_id: felt) -> (container: felt) {
    }

    func containerToId(_container: felt) -> (id: felt) {
    }

    func isContainer(_container: felt) -> (state: felt) {
    }

    func containerStockLength() -> (length: felt) {
    }
}
