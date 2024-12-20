use core::starknet::ContractAddress;
#[starknet::interface]
trait INFT<TContractState>{
fn mint_nft(ref self: TContractState, recipient: ContractAddress);
}

#[starknet::contract]
mod NFT {
    use openzeppelin_introspection::src5::SRC5Component;
    use openzeppelin_token::erc721::{ERC721Component, ERC721HooksEmptyImpl};
    use starknet::ContractAddress;
    use core::starknet::storage::{StoragePointerWriteAccess, StoragePointerReadAccess};

    component!(path: ERC721Component, storage: erc721, event: ERC721Event);
    component!(path: SRC5Component, storage: src5, event: SRC5Event);

    // ERC721 Mixin
    #[abi(embed_v0)]
    impl ERC721MixinImpl = ERC721Component::ERC721MixinImpl<ContractState>;
    impl ERC721InternalImpl = ERC721Component::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
    token_id: u256,
        #[substorage(v0)]
        erc721: ERC721Component::Storage,
        #[substorage(v0)]
        src5: SRC5Component::Storage
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ERC721Event: ERC721Component::Event,
        #[flat]
        SRC5Event: SRC5Component::Event
    }

    #[constructor]
    fn constructor(
        ref self: ContractState
    ) {
        let name = "Uniswap V1";
        let symbol = "DKT";
        let base_uri = "ipfs://bafkreie437frrvc5g4cy24vi7r64tfjtenedot7p7thqghrlvrnxsqm2la/";
        self.erc721.initializer(name, symbol, base_uri);
       
    }
    #[abi(embed_v0)]
    impl NFT of super::INFT<ContractState>{
    fn mint_nft(ref self: ContractState, recipient: ContractAddress) {
    let mut tokenId:u256= self.token_id.read();
    self.erc721.mint(recipient, tokenId);
    self.token_id.write(tokenId + 1);
    }
    }
}