public without sharing class SMC_myCartController {
   // Important : all product presented  must be shared with all user that have access to the community 
    public SMC_myCartController() { 

    }

    @AuraEnabled
    public static Cart getCartInfo( String webCartId, String effectiveAccount , String ba  ){
        System.debug ('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> getCartInfo Start' ) ;

        String webstoreId                       =   SMC_CartUtiles.getWebCart (webCartId).webstoreId         ; 
        Map<String , cartitem> citem            =   SMC_CartUtiles.getCartItem( webCartId )                  ; 
        Map< String , String > l_ProductId      =   SMC_CartUtiles.getProductIdFromCartItem(citem.values () );
        
        List<smc_BA__c> l_ba = [    SELECT
                                    id,
                                    smc_type__c
                                    FROM
                                    smc_BA__c
                                    WHERE
                                    smc_type__c = : ba limit 1
                                ]; 
        if( l_ba.size () > 0 )
        {  
            if (  l_ProductId.size () > 0 ) 
            {
                Map < Id , ConnectApi.PricingResultLineItem >   l_productPricingConfig  = SMC_CartUtiles.getProductsPrice ( webCartId , effectiveAccount , new List<String> ( l_ProductId.keySet() ))   ;
                Map < String , ConnectApi.ProductDetail >       l_productInfo           = SMC_CartUtiles.getProductsInfo (  webstoreId , effectiveAccount , new List<String> ( l_ProductId.keySet() ))  ;
                
                List<Product> l_Product = new List <Product> () ; 

                Decimal cartQuantity = 0 ; 
                
                for ( String pr_Id :  l_ProductId.keySet () ) {

                    if ( Id.valueOf ( l_productInfo.get (pr_Id).fields.get('SMC_BA__c') ) == l_ba[0].Id ) {
                        
                        l_Product.Add (new Product (pr_Id ,  citem.get ( pr_Id ).Product2.name  , l_productInfo.get ( pr_Id ).defaultImage.url ,  l_productPricingConfig.get ( pr_Id ).listPrice  ,  l_productPricingConfig.get ( pr_Id ).unitPrice , String.valueOf( citem.get ( pr_Id ).Quantity) , citem.get ( pr_Id ).Product2.QuantityUnitOfMeasure  , String.valueOf(citem.get ( pr_Id ).totalAmount ) ,  String.valueOf ( citem.get ( pr_Id ).id ) , '/eorder/s/product/detail/'+pr_Id ) ) ; 
                        cartQuantity += citem.get ( pr_Id ).Quantity ; 
                    }
                
                }
                System.debug ('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> getCartInfo End' ) ;
                
                return new Cart(  l_Product , cartQuantity ) ; 
            }
        }
        System.debug ('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> getCartInfo End' ) ;
        return new Cart () ;   

    }

    @AuraEnabled
    public static String exportData ( String cartId ){
        Map <String , cartitem> cartItem =  SMC_CartUtiles.getCartItem( cartId ) ;
        List<String> file = new List <String>{ 'Nom Produit ; Code Produit ; Quantité ; Prix ; ' } ; 

        for ( cartitem ci : cartItem.values () ){
            file.add ( ci.Product2.Name + ' ; ' + ci.Product2.ProductCode + ' ; ' +  ci.Quantity +' ; ' + ci.totalAmount + ' ; ' ) ; 

        }
        return String.join ( file , '\n') ; 
    }

    @AuraEnabled
    public static ConnectApi.CartItem setCartItem ( String webCardId , String  effectiveAccountId , String activeCartOrId , String cartItemId , String productId , String quantity  ) {
        String webstoreId                               =   SMC_CartUtiles.getWebCart (webCardId).webstoreId  ; 
        ConnectApi.CartItemInput    cartItemInput       =   new ConnectApi.CartItemInput ()    ; 
        
        cartItemInput.productId = productId     ; 
        cartItemInput.quantity  = quantity      ; 

        return  ConnectApi.CommerceCart.updateCartItem( webstoreId,  effectiveAccountId, activeCartOrId, cartItemId, cartItemInput) ; 

    }

    @AuraEnabled
    public static void deleteCartItem ( String webCardId, String effectiveAccountId, String activeCartOrId, String cartItemId){
        String webstoreId  =   SMC_CartUtiles.getWebCart (webCardId).webstoreId  ; 
        ConnectApi.CommerceCart.deleteCartItem( webstoreId, effectiveAccountId, activeCartOrId, cartItemId ); 
    }

    @AuraEnabled
    public static void deleteCart ( String effectiveAccountId , String webCardId ){
        String webstoreId  =   SMC_CartUtiles.getWebCart (webCardId).webstoreId  ; 
        delete SMC_CartUtiles.getCartItem( webCardId  ).values ()  ; 
       // ConnectApi.CommerceCart.deleteCart(webstoreId, effectiveAccountId, webCardId) ; 
    }

    @AuraEnabled
    public static void createWhishList (String webCartId , String effectiveAccountId , String whishlistName ) {
        String webstoreId           =   SMC_CartUtiles.getWebCart (webCartId).webstoreId  ; 
        Set< String > l_products    =   SMC_CartUtiles.getCartItem( webCartId ).keySet() ;  

        if (  l_products.size () > 0 )
        {
            SMC_CartUtiles.createWishlist ( webstoreId, effectiveAccountId, whishlistName, l_products );
        }
    }
    
    @AuraEnabled(cacheable = true)
    public static  list < String > getBa () {
       
        List<String> pickListValuesList= new List<String>();
		Schema.DescribeFieldResult fieldResult = SMC_BA__c.smc_type__c.getDescribe();
		List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
		
        for( Schema.PicklistEntry pickListVal : ple){
			pickListValuesList.add(pickListVal.getValue());
		}  

		return  pickListValuesList ;

    }

    public class Product{

        @AuraEnabled
        public String productId     ; 

        @AuraEnabled
        public String name          ; 

        @AuraEnabled
        public String imageUrl      ; 

        @AuraEnabled
        public String listPrice     ; 

        @AuraEnabled
        public String price         ; 

        @AuraEnabled
        public String quantity      ; 

        @AuraEnabled
        public String sku           ; 
        
        @AuraEnabled
        public String totalAmount   ; 

        @AuraEnabled
        public String cartitemid    ;

        @AuraEnabled
        public String productUrl    ;

      
        public Product ( String productId , String name , String imageUrl ,  String listPrice ,  String price ,  String quantity , String sku , String totalAmount , String cartitemid , String productUrl) {
            this.productId  = productId     ; 
            this.name       = name          ; 
            this.imageUrl   = imageUrl      ; 
            this.listPrice  = listPrice     ; 
            this.price      = price         ; 
            this.quantity   = quantity      ; 
            this.sku        = sku           ; 
            this.totalAmount= totalAmount   ; 
            this.cartitemid = cartitemid    ;
            this.productUrl = productUrl    ;
        }
    }

    public class Cart{

        @AuraEnabled
        public Decimal quantity;

        @AuraEnabled
        public List < Product > cartItem ; 

        public Cart( list <Product> cartItem , Decimal quantity )
        {
            this.quantity = quantity ; 
            this.cartItem = cartItem ; 

        }

        public Cart ()
        {
            this.quantity = 0 ; 
            this.cartItem = new List <Product> () ;
        }
    }
}
