%lang starknet

from starkware.cairo.common.uint256 import Uint256

struct TokenAllocation {
    address: felt,  // Address of token
    allocation: felt,  // token allocation in range 0..1,000,000 which represents 0-100%
}

@contract_interface
namespace IMinterStrategies {
    func nftContract() -> (nftContract: felt) {
    }

    func mint(tokens_len: felt, tokens: felt*, allocation_len: felt, allocation: felt*) {
    }
}

@contract_interface
namespace IStrategies {
    func balanceOf(owner: felt) -> (balance: Uint256) {
    }

    func ownerOf(tokenId: Uint256) -> (owner: felt) {
    }

    func totalSupply() -> (totalSupply: Uint256) {
    }

    func baseURI() -> (baseURI: felt) {
    }

    func tokenByIndex(index: Uint256) -> (tokenId: Uint256) {
    }

    func tokenOfOwnerByIndex(owner: felt, index: Uint256) -> (tokenId: Uint256) {
    }

    func setMinter(_minter: felt) {
    }

    func mint(
        _to: felt, tokens_len: felt, tokens: felt*, allocations_len: felt, allocations: felt*
    ) {
    }

    func burn(_from: felt, token_id_: Uint256) {
    }

    func setBaseURI(baseURI: felt) {
    }

    func transferFrom(_from: felt, _to: felt, token_id_: Uint256) {
    }

    func safeTransferFrom(_from: felt, _to: felt, token_id_: Uint256, data_len: felt, data: felt*) {
    }

    func approve(_to: felt, token_id_: Uint256) {
    }

    func setApprovalForAll(_operator: felt, _approved: felt) {
    }
}
