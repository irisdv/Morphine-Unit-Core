%lang starknet

@contract_interface
namespace IRegistery {

    func owner() -> (owner: felt) {
    }

    func getTreasury() -> (treasuary: felt) {
    }

    func containerFactory() -> (container_factory: felt) {
    }

    func containerHash() -> (container_hash: felt) {
    }

    func oracleTransit() -> (oracle: felt) {
    }
    
    func isPool(_pool: felt) -> (state : felt) {
    }

    func isBorrowManager(_borrow_manager: felt) -> (state : felt) {
    }
    
    func idToPool(_id: felt) -> (pool : felt) {
    }
    
    func poolsLength() -> (poolsLength : felt) {
    }
    
    
    // setters

    func setTreasury(new_tresuary: felt) {
    }

    func setOwner(new_owner: felt) {
    }

    func setOracleTransit(new_oracle_transit: felt) -> () {
    }

    func setContainerHash(new_borrow_hash: felt) -> () {
    }

    func setContainerFactory(new_container_factory: felt) -> () {
    }

    func addPool(_pool : felt) -> () {
    }

}
