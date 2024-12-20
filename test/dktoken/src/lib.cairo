use starknet::ContractAddress;
/// This interface allows modification and retrieval of the contract balance.
#[starknet::interface]
pub trait IDimkaToken<TContractState> {
    fn mint(ref self: TContractState, recipent: ContractAddress, amount: u256);
}

/// Simple contract for managing balance.
#[starknet::contract]
mod DimkaToken {
    use core::starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};
    use openzeppelin::erc20::{ERC20Component, ERC20HooksEmptyImpl};
    use starknet::ContractAddress;

    component!(path: ERC20Component, storage: erc20, event: ERC20Event);
    #[storage]
    struct Storage {
        #[substorage(v0)]
         erc20: ERC20Component::Storage,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ERC20Event: ERC20Component::Event
    }

 #[abi(embed_v0)]
  impl ERC20MixinImpl = ERC20Component::ERC20MixinImpl<ContractState>;
   impl ERC20InternalImpl = ERC20Component::InternalImpl<ContractState>;

#[constructor]
    fn constructor(
        ref self: ContractState
    ) {
        self.erc20.initializer("Dimka token", "DKT");
    }


    #[abi(embed_v0)]
    impl DimkaToken of super::IDimkaToken<ContractState> {
        fn mint(ref self: ContractState, recipent: ContractAddress, amount: u256){
        self.erc20.mint(recipient, amount);
        }
    
}
}
