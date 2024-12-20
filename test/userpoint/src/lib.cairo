use core::starknet::ContractAddress;
#[starknet::interface]
trait IPoint<TContractState>{
fn add_point(ref self: TContractState, userAddress: ContractAddress,  point: u128); 
fn get_point(self: @TContractState, userAddress:ContractAddress) ->u128;
}


#[starknet::contract]
mod Point{
use core::starknet::{ContractAddress, get_caller_address,};
use core::starknet::storage::{Map, StoragePathEntry, StoragePointerWriteAccess, StoragePointerReadAccess};

#[storage]
struct Storage{
balance: Map<ContractAddress, u128>,
}

#[abi(embed_v0)]
impl Point of super::IPoint<ContractState> {
fn add_point(ref self: ContractState, userAddress: ContractAddress, point: u128)
{

self.balance.entry(userAddress).write(point);
}

fn get_point(self:@ContractState,  userAddress: ContractAddress) -> u128{

return self.balance.entry(userAddress).read();
}

}

}
