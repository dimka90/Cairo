#[starknet::interface]
trait INFT<TContractState> {
    fn mint_nft(ref self: TContractState, recipient: ContractAddress);
}

#[starknet::contract]
mod NFT {
    use openzeppelin_introspection::src5::SRC5Component;
    use openzeppelin_token::erc721::{ERC721Component, ERC721HooksEmptyImpl};
    use openzeppelin_utils::pausable::PausableComponent;
    use starknet::ContractAddress;
    use core::starknet::storage::{StoragePointerWriteAccess, StoragePointerReadAccess};

    // Define components
    component!(path: ERC721Component, storage: erc721, event: ERC721Event);
    component!(path: SRC5Component, storage: src5, event: SRC5Event);
    component!(path: PausableComponent, storage: pausable, event: PausableEvent);

    #[abi(embed_v0)]
    impl ERC721MixinImpl = ERC721Component::ERC721MixinImpl<ContractState>;
    impl ERC721InternalImpl = ERC721Component::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        token_id: u256,
        #[substorage(v0)]
        erc721: ERC721Component::Storage,
        #[substorage(v0)]
        src5: SRC5Component::Storage,
        #[substorage(v0)]
        pausable: PausableComponent::Storage,
        highest_bid: u256, // Track the highest bid amount
        highest_bidder: ContractAddress, // Track the highest bidder
        bidding_active: bool, // Tracks if bidding is ongoing
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ERC721Event: ERC721Component::Event,
        #[flat]
        SRC5Event: SRC5Component::Event,
        #[flat]
        PausableEvent: PausableComponent::Event,
        BiddingStarted,
        BiddingEnded { winner: ContractAddress, amount: u256 },
        NewBid { bidder: ContractAddress, amount: u256 },
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
        let name = "NFT Bidding";
        let symbol = "NFTB";
        let base_uri = "ipfs://example-uri/";
        self.erc721.initializer(name, symbol, base_uri);
        self.pausable.initialize(); // Initialize pausable component

        // Initialize bidding state
        self.highest_bid.write(0);
        self.highest_bidder.write(ContractAddress::zero());
        self.bidding_active.write(false);
    }

    #[abi(embed_v0)]
    impl NFT of super::INFT<ContractState> {
        fn mint_nft(ref self: ContractState, recipient: ContractAddress) {
            let mut token_id: u256 = self.token_id.read();
            self.erc721.mint(recipient, token_id);
            self.token_id.write(token_id + 1);
        }
    }

    impl NFT {
        /// Allows the contract owner to pause all operations.
        fn pause(ref self: ContractState) {
            self.pausable.pause();
        }

        /// Allows the contract owner to unpause operations.
        fn unpause(ref self: ContractState) {
            self.pausable.unpause();
        }

        /// Starts the bidding process. Can only be called by the owner.
        fn start_bidding(ref self: ContractState) {
            self.pausable.ensure_not_paused();
            assert!(self.bidding_active.read() == false, "Bidding is already active");
            self.bidding_active.write(true);
            emit!(BiddingStarted {});
        }

        /// Ends the bidding process and mints an NFT to the highest bidder.
        fn end_bidding(ref self: ContractState) {
            self.pausable.ensure_not_paused();
            assert!(self.bidding_active.read() == true, "Bidding is not active");
            self.bidding_active.write(false);

            let winner = self.highest_bidder.read();
            let highest_bid = self.highest_bid.read();

            // Mint the NFT to the highest bidder
            if winner != ContractAddress::zero() {
                self.mint_nft(winner);
                emit!(BiddingEnded { winner, amount: highest_bid });
            }
        }

        /// Place a bid in the auction.
        fn place_bid(ref self: ContractState, bidder: ContractAddress, bid_amount: u256) {
            self.pausable.ensure_not_paused();
            assert!(self.bidding_active.read() == true, "Bidding is not active");
            assert!(bid_amount > self.highest_bid.read(), "Bid amount must be higher than the current highest bid");

            // Update highest bid and bidder
            self.highest_bid.write(bid_amount);
            self.highest_bidder.write(bidder);
            emit!(NewBid { bidder, amount: bid_amount });
        }
    }
}
