module SendMessage::RealEstateTokenization {
    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;

    /// Struct representing a tokenized real estate property.
    struct RealEstateProperty has store, key {
        total_tokens: u64,        // Total tokens representing the property
        tokens_sold: u64,         // Number of tokens sold to investors
        price_per_token: u64,     // Price per token in APT
        property_value: u64,      // Total value of the property
        owner: address,           // Original property owner
    }

    /// Function to tokenize a real estate property.
    /// Creates tokens representing fractional ownership of the property.
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

    /// Function for investors to buy property tokens.
    /// Allows fractional ownership investment in real estate.
    public fun buy_property_tokens(
        investor: &signer, 
        property_owner: address, 
        token_amount: u64
    ) acquires RealEstateProperty {
        let property = borrow_global_mut<RealEstateProperty>(property_owner);
        
        // Check if enough tokens are available
        assert!(
            property.tokens_sold + token_amount <= property.total_tokens, 
            1 // Error code for insufficient tokens
        );
        
        // Calculate total cost
        let total_cost = token_amount * property.price_per_token;
        
        // Transfer payment from investor to property owner
        let payment = coin::withdraw<AptosCoin>(investor, total_cost);
        coin::deposit<AptosCoin>(property_owner, payment);
        
        // Update tokens sold
        property.tokens_sold = property.tokens_sold + token_amount;
    }
}