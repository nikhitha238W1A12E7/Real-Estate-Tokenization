module SendMessage::RealEstateTokenization {
    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;

    
    struct RealEstateProperty has store, key {
        total_tokens: u64,        
        tokens_sold: u64,        
        price_per_token: u64,     
        property_value: u64,      
        owner: address,           
    }

   
    public fun tokenize_property(
        owner: &signer, 
        property_value: u64, 
        total_tokens: u64
    ) {
        let owner_addr = signer::address_of(owner);
        let price_per_token = property_value / total_tokens;
        
        let property = RealEstateProperty {
            total_tokens,
            tokens_sold: 0,
            price_per_token,
            property_value,
            owner: owner_addr,
        };
        
        move_to(owner, property);
    }

   
    public fun buy_property_tokens(
        investor: &signer, 
        property_owner: address, 
        token_amount: u64
    ) acquires RealEstateProperty {
        let property = borrow_global_mut<RealEstateProperty>(property_owner);
        
        
        assert!(
            property.tokens_sold + token_amount <= property.total_tokens, 
            
        );
        
        
        let total_cost = token_amount * property.price_per_token;
        
       
        let payment = coin::withdraw<AptosCoin>(investor, total_cost);
        coin::deposit<AptosCoin>(property_owner, payment);
        
        
        property.tokens_sold = property.tokens_sold + token_amount;
    }

}
