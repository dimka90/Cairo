/// Interface representing `HelloContract`.
/// This interface allows modification and retrieval of the contract balance.
#[starknet::interface]
pub trait IPointTracker<TContractState> {
    fn add_points(ref self: TContractState, points: u128);
    fn Redeem_point(ref self: TContractState, amount: u128)->u128;
    fn get_points(self: @TContractState) -> u128;
}


/// Simple contract for managing balance.
#[starknet::contract]
mod PointTracker {
    use core::starknet::{ ContractAddress, get_caller_address};
    use core::starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess, StoragePathEntry,Map};
    

    #[storage]
    struct Storage {
        balance: felt252,
        userPoints: Map<ContractAddress, u128>,
    }
    
    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event{
    AddPoint: AddPoint,
    RedeemPoint: RedeemPoint,
    }

    #[derive(Drop, starknet::Event)]
    pub struct AddPoint {
       owner:ContractAddress,
       point: u128,
    }

    #[derive(Drop, starknet::Event)]
    pub struct RedeemPoint {
       owner:ContractAddress,
       point: u128,
    }



    #[abi(embed_v0)]
    impl PointImplentation of super::IPointTracker<ContractState> {

        fn add_points(ref self: ContractState, points: u128) {
            let caller = get_caller_address();
            let previousPoint = self.userPoints.entry(caller).read();
            let newPoints = previousPoint+points;
            self.userPoints.entry(caller).write(newPoints);

            self.emit(AddPoint{owner: caller, point: points});
        }

        fn Redeem_point(ref self: ContractState, amount: u128) -> u128{
            assert(amount != 0, 'Amount cannot be 0');
            
            let caller = get_caller_address();
            let points = self.userPoints.entry(caller).read();
            
            // assert(points >= amount, 'Invalid amount');
            
            self.userPoints.entry(caller).write(amount);
            self.emit(RedeemPoint{owner: caller, point: amount});
            return points; 
        }

         fn get_points(self: @ContractState) -> u128{
        let caller = get_caller_address();
         return self.userPoints.entry(caller).read();

         }
    }
}
