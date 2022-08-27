public with sharing class SMC_CartUtiles {
    public SMC_CartUtiles() {

    }
    public static Map <String , ConnectApi.ProductDetail >  getProductsInfo ( String webstoreId , String effectiveAccount , List< String > l_ProductId ) {
        System.debug ('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> getProductsInfo Start' ) ;
        
        Map <String , ConnectApi.ProductDetail >  l_productsDetails = new Map <String , ConnectApi.ProductDetail > () ; 
       
        for (String productId : l_ProductId ){
              l_productsDetails.put ( productId ,  ConnectApi.CommerceCatalog.getProduct(webstoreId, productId , effectiveAccount , new List<String>{} , false , new List<String>{} , false , true, true,true,false , false ) ) ;
        }

        System.debug ('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> getProductsInfo End' ) ;
        return l_productsDetails ; 
        
    }

    public static Map <String , cartitem> getCartItem( String cartId ){
        System.debug ('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> getCartItem Start' ) ;

        Map < String , cartitem > l_productCartItem =   new Map < String , cartitem> () ; 
        
        List <cartitem > l_cartitem = [ SELECT 
                                        id,
                                        Product2Id,
                                        Product2.Name,
                                        Product2.ProductCode,
                                        Product2.StockKeepingUnit,
                                        Product2.QuantityUnitOfMeasure,
                                        Quantity,
                                        totalAmount  
                                        FROM 
                                        cartitem
                                        WHERE
                                        cartid = :cartId
                                        ];

        for ( cartitem ci : l_cartitem ){

            l_productCartItem.put( ci.Product2Id , ci  ) ;
        }

        System.debug ('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> getCartItem End'   ) ;

        return  l_productCartItem ; 
    }

    public static Map < String , String > getProductIdFromCartItem ( list<cartitem> cItem) {

        Map<String , String > l_ProductId = new Map < String , String > () ; 
        for ( cartitem ci  : cItem  ){

            l_ProductId.put ( ci.Product2Id , ci.id ) ; 

        }
        return l_ProductId ; 

    }

    public static Map < Id , ConnectApi.PricingResultLineItem > getProductsPrice ( String webCartId, String effectiveAccount , list<String> l_productId  ){
        System.debug ('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> getProductsPrice Start' ) ; 
        list < ConnectApi.PricingResultLineItem > result = ConnectApi.CommerceStorePricing.getProductPrices( (String) getWebCart ( webCartId ).webstoreId ,effectiveAccount , getPricingInput ( l_productId ) ).pricingLineItemResults ;
        Map < Id , ConnectApi.PricingResultLineItem > productPriceInfo = new Map < Id , ConnectApi.PricingResultLineItem > () ; 
        for (ConnectApi.PricingResultLineItem pr : result ){
            productPriceInfo.put ( (Id) pr.productId , pr ) ; 
        }

        System.debug ('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> getProductsPrice End' ) ; 
        return productPriceInfo ; 

    }

    public static ConnectApi.PricingInput  getPricingInput ( List<String> l_productId ){
        System.debug ('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> getPricingInput Start' ) ; 
        List<ConnectApi.PricingLineItemInput> l_pricingItem = new List< ConnectApi.PricingLineItemInput > () ;
        
        for (String productId : l_productId ){
            ConnectApi.PricingLineItemInput item = new ConnectApi.PricingLineItemInput () ; 
            item.productId  = productId;
            l_pricingItem.add ( item ) ; 
        }
        
        ConnectApi.PricingInput pi =  new  ConnectApi.PricingInput ()  ; 
        pi.pricingLineItems = l_pricingItem ; 
        System.debug ('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> getPricingInput End' ) ; 
        return pi;

    }

    public static webcart getWebCart (String cartid){
        System.debug ('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> getWebCart Start' ) ; 
        System.debug ('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> getWebCart End' ) ; 
        return [SELECT 
                id,
                webstoreId 
                FROM 
                webcart  
                WHERE 
                id = :cartid
                ]; 
    }

    public static List< ConnectApi.WishlistItemInput > createWishlistItemInput ( Set <String> l_products ){

        List< ConnectApi.WishlistItemInput > l_wishListProductItem = new List< ConnectApi.WishlistItemInput > () ; 
        
        for ( String productId :  l_products)
        {
            ConnectApi.WishlistItemInput wishListProductItem = new ConnectApi.WishlistItemInput () ;
            wishListProductItem.productId = Id.valueOf ( productId )  ; 
            l_wishListProductItem.add ( wishListProductItem ) ; 
        }

        return l_wishListProductItem ; 
    }

    public Static void createWishlist ( String webstoreId, String effectiveAccountId , String whishlistName , Set <String> l_products ) {
        List< ConnectApi.WishlistItemInput > l_wishListProductItem  =  createWishlistItemInput ( l_products ) ; 
        ConnectApi.WishlistInput wishlistInput = new ConnectApi.WishlistInput() ; 
        wishlistInput.name = whishlistName ;
        wishlistInput.products = l_wishListProductItem ; 
        ConnectApi.CommerceWishlist.createWishlist(webstoreId, effectiveAccountId , wishlistInput) ; 
    }
}
