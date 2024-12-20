use core::starknet::ContractAddress;
use starknet::core::types::felt252;
use core::starknet::storage::{StoragePointerReadAccess, StoragePointerWriteAccess};

#[starknet::interface]
trait INFT<TContractState> {
    fn mint_nft(ref self: TContractState, recipient: ContractAddress);
    fn place_bid(ref self: TContractState, bidder: ContractAddress, amount: u256);
    fn finalize_auction(ref self: TContractState);
}

#[starknet::contract]
mod NFT {
    use openzeppelin_introspection::src5::SRC5Component;
    use openzeppelin_token::erc721::{ERC721Component, ERC721HooksEmptyImpl};
    use starknet::ContractAddress;
    use core::starknet::storage::{StoragePointerWriteAccess, StoragePointerReadAccess};

    component!(path: ERC721Component, storage: erc721, event: ERC721Event);
    component!(path: SRC5Component, storage: src5, event: SRC5Event);

    #[storage]
    struct Storage {
        token_id: u256,
        #[substorage(v0)]
        erc721: ERC721Component::Storage,
        #[substorage(v0)]
        src5: SRC5Component::Storage,
        highest_bid: u256,                // Highest bid amount
        highest_bidder: ContractAddress, // Address of the highest bidder
        auction_active: bool,            // Status of the auction
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ERC721Event: ERC721Component::Event,
        #[flat]
        SRC5Event: SRC5Component::Event,
        NewBid { bidder: ContractAddress, amount: u256 },
        AuctionFinalized { winner: ContractAddress, amount: u256 },
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
        let name = "Uniswap V1";
        let symbol = "DKT";
        let base_uri = "ipfs://bafkreie437frrvc5g4cy24vi7r64tfjtenedot7p7thqghrlvrnxsqm2la/";
        self.erc721.initializer(name, symbol, base_uri);

        self.highest_bid.write(0.into());
        self.highest_bidder.write(ContractAddress::default());
        self.auction_active.write(true);
    }

    #[abi(embed_v0)]
    impl NFT of super::INFT<ContractState> {
        fn mint_nft(ref self: ContractState, recipient: ContractAddress) {
            let mut token_id: u256 = self.token_id.read();
            self.erc721.mint(recipient, token_id);
            self.token_id.write(token_id + 1);
        }

        fn place_bid(ref self: ContractState, bidder: ContractAddress, amount: u256) {
            assert!(self.auction_active.read(), "Auction is not active!");
            let current_highest_bid: u256 = self.highest_bid.read();

            // Ensure the new bid is higher than the current highest bid
            assert!(amount > current_highest_bid, "Bid must be higher than the current highest bid!");

            // Update the highest bid and bidder
            self.highest_bid.write(amount);
            self.highest_bidder.write(bidder);

            // Emit a new bid event
            self.emit_event(Event::NewBid { bidder, amount });
        }

        fn finalize_auction(ref self: ContractState) {
            assert!(self.auction_active.read(), "Auction is not active!");

            // Get the highest bidder and bid
            let winner: ContractAddress = self.highest_bidder.read();
            let winning_bid: u256 = self.highest_bid.read();

            // Mint the NFT to the highest bidder
            self.mint_nft(winner);

            // Mark the auction as inactive
            self.auction_active.write(false);

            // Emit an auction finalized event
            self.emit_event(Event::AuctionFinalized { winner, amount: winning_bid });
        }
    }
}
