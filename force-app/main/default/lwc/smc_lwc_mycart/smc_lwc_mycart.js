import { LightningElement , api, track } from 'lwc';
import getCartInfo from '@salesforce/apex/SMC_myCartController.getCartInfo'
import setCartItem from '@salesforce/apex/SMC_myCartController.setCartItem'
import deleteCartItem from '@salesforce/apex/SMC_myCartController.deleteCartItem'
import smc_cl_Cart_ba from '@salesforce/label/c.smc_cl_Cart_ba';
import smc_cl_MyCartDecrementCounter from '@salesforce/label/c.smc_cl_MyCartDecrementCounter';
import smc_cl_MyCartIncrementcounter from '@salesforce/label/c.smc_cl_MyCartIncrementcounter';





export default class Smc_lwc_mycart extends LightningElement {
      
    @track  l_product   ;
            cartq       ;
    @api    displayimage        ;
    @api    displaybasubtotal   ;
    @api    displaysku          ;
    @api    effectiveaccountId  ;
    @api    cardId              ;
    @api    ba                  ;   
   

    showspinner = false ; 
    showComponenet   = false    ;
    label = 
    {
        smc_cl_Cart_ba,
        smc_cl_MyCartDecrementCounter,
        smc_cl_MyCartIncrementcounter
    }

    setIncrementCounter(event)
    {
        var source = event.target ;  
        
        this.cartq = this.cartq + 1 ; 

        for ( let index = 0  ; index < this.l_product.length ; index++ )
        {
            if ( this.l_product[index].productId == source.getAttribute("data-increment"))
            {
                this.l_product[index].quantity = ++this.template.querySelector('[data-quantity="'+source.getAttribute("data-increment")+'"]').value ; 
                break;
            }
        }
        
        this.updateCartItem ( source , "data-increment"  ) ; 
    }

    setDecrementCounter(event)
    {
        let source = event.target ; 

        if ( this.template.querySelector('[data-quantity="'+source.getAttribute("data-decrement")+'"]').value > 1 )
        {       
            this.cartq = this.cartq - 1 ; 

            for ( let index = 0  ; index < this.l_product.length ; index++ )
            {
                if ( this.l_product[index].productId == source.getAttribute("data-decrement"))
                {
                    this.l_product[index].quantity =  --this.template.querySelector('[data-quantity="'+source.getAttribute("data-decrement")+'"]').value ; 
                    break;
                }
            }
            this.updateCartItem ( source , "data-decrement"  ) ;
        }
       
    }

    setQuantityFromInput ( event ) {
        let source = event.target ;  
        let quantityTotal = 0 ; 

        if ( source.value > 0 )
        {        
            for ( let index = 0  ; index < this.l_product.length ; index++ )
            {
                if ( this.l_product[index].productId == source.getAttribute("data-quantity"))
                {
                    this.l_product[index].quantity = source.value ; 
                }
                quantityTotal = quantityTotal + parseInt(this.l_product[index].quantity , 10 )  ; 
            }
            this.cartq = quantityTotal ; 
            this.updateCartItem ( source , "data-quantity"  ) ;

        }

     
    }

    connectedCallback( )
    {
        getCartInfo({
            webCartId : this.cardId ,
            effectiveAccount : this.effectiveaccountId,
            ba : this.ba

        }).then(resp =>{

            this.l_product= resp.cartItem ; 
            this.cartq = resp.quantity ; 

            if ( this.l_product.length > 0 )
            {
                this.showComponent() ; 
                
            }else
            {
                this.hideComponent ();
            }
            
            
        });
    }

    async  updateCartItem ( source , dataAttribute , action )
    {
       let cartItem         =   this.template.querySelector('[data-quantity="'+source.getAttribute( dataAttribute )+'"]').getAttribute("data-cartitemid") ; 
       let product          =   source.getAttribute( dataAttribute ) ; 
       let quantityValue    =   this.template.querySelector('[data-quantity="'+source.getAttribute(dataAttribute)+'"]').value ; 
       this.displaySpinner (); 
        await setCartItem (
        { 
            webCardId : this.cardId,
            effectiveAccountId :  this.effectiveaccountId,
            activeCartOrId :  this.cardId,
            cartItemId : cartItem,
            productId : product,
            quantity : quantityValue
        
        }).then(resp =>{
            this.template.querySelector('[data-productidtotalprice="'+source.getAttribute( dataAttribute )+'"]').innerHTML  = resp["totalPrice"] + " €"  ; 
           // eval("$A.get('e.force:refreshView').fire()");
           this.hideSpinner(  );
        });

       // getRecordNotifyChange(  [{recordId: this.cardId}]) ; 
       
        // to refresh the cart total standard cmp
       /*setTimeout(() => {
            eval("$A.get('e.force:refreshView').fire()");
       }, 3000);*/
        
    }

    deltetItem ( event )
    {
        let source = event.target ;
        let cartItem         =   source.getAttribute( 'data-delete' ) ;
        this.displaySpinner (); 
        deleteCartItem(
        {
            webCardId : this.cardId  ,
            effectiveAccountId :  this.effectiveaccountId,
            activeCartOrId :  this.cardId  ,
            cartItemId : cartItem

        }  ).then(resp =>{

          this.deleteProduct ( cartItem ); 
          this.hideSpinner() ; 

        });
    }

    deleteProduct ( cartitemId ) 
    {
        let products = [] ; 
        let quantityTotal = 0 ; 

        for (let i  = 0 ; i < this.l_product.length ; i ++  )
        {
           if (this.l_product[i]['cartitemid'] != cartitemId )
           {
            products.push ( this.l_product[i] )  ; 
            quantityTotal = quantityTotal +    parseInt(this.l_product[i].quantity , 10 )
           } 
        }

        this.l_product  = products      ;
        this.cartq      = quantityTotal ; 
    }

    displaySpinner ()
    {
        this.showspinner = true  ; 
    }

    hideSpinner()
    {
        this.showspinner = false  ; 
    }

    hideComponent ()
    {
        this.showComponenet =  false ; 
    }

    showComponent () 
    {
        this.showComponenet =  true ; 

    }
}