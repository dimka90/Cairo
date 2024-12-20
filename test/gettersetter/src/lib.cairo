/// Interface representing `HelloContract`.
/// This interface allows modification and retrieval of the contract balance.
#[starknet::interface]
pub trait ISetterGetter<TContractState> {
    
    fn set_number(ref self: TContractState, number: u256);
    fn get_number(self: @TContractState) -> u256;
}

/// Simple contract for managing balance.
#[starknet::contract]
mod SetterGetter {
    use core::starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};

    #[storage]
    struct Storage {
        number: u256,
    }

    #[abi(embed_v0)]
    impl SetterGetter of super::ISetterGetter<ContractState> {
        fn set_number(ref self: ContractState, number: u256) {
         
            self.number.write(self.number.read() + number);
        }

        fn get_number(self: @ContractState) -> u256 {
            self.number.read()
        }
    }
}
