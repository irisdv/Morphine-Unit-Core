%lang starknet

from starkware.cairo.common.uint256 import Uint256
from morphine.interfaces.IBorrowConfigurator import AllowedToken

@contract_interface
namespace IDripInfraFactory {


func deployDripInfra(
        _drip_infra_factory: felt, 
        _pool: felt, 
        _nft: felt,
        _expirable: felt,
        _minimum_borrowed_amount: Uint256,
        _maximum_borrowed_amount: Uint256,
        _allowed_tokens_len: felt,
        _allowed_tokens: AllowedToken*,
        _salt: felt) {
}

func getDripInfraAddresses() -> (
        drip_manager: felt, drip_transit: felt, drip_configurator: felt) {
}


}
