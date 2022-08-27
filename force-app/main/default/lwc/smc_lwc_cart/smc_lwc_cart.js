import { LightningElement  , api, wire } from 'lwc';
import getBa from '@salesforce/apex/SMC_myCartController.getBa';
import deleteCart from '@salesforce/apex/SMC_myCartController.deleteCart';
import createWhishList from '@salesforce/apex/SMC_myCartController.createWhishList';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import smc_cl_WishListCreated from '@salesforce/label/c.smc_cl_WishListCreated';
import smc_cl_WishListLink from '@salesforce/label/c.smc_cl_WishListLink';
import smc_cl_ClearCart from '@salesforce/label/c.smc_cl_ClearCart';
import smc_cl_CreateWishListModalHeader from '@salesforce/label/c.smc_cl_CreateWishListModalHeader';
import smc_cl_CancelButton from '@salesforce/label/c.smc_cl_CancelButton';
import smc_cl_CreateButton from '@salesforce/label/c.smc_cl_CreateButton';
import smc_cl_WishListName from '@salesforce/label/c.smc_cl_WishListName';




export default class Smc_lwc_cart extends LightningElement {

    @api    ba                      ; 
    @api    effectiveaccountId      ;
    @api    cardId                  ;
    @api    showSKU                 ;
    @api    showImage               ;
    @api    showSubtoTal            ;
    @api    showModalCreateWishList = false ;


    label = 
    {
        smc_cl_WishListName                 ,
        smc_cl_WishListCreated              ,
        smc_cl_WishListLink                 ,
        smc_cl_ClearCart                    ,
        smc_cl_CancelButton                 ,
        smc_cl_CreateButton                 ,
        smc_cl_CreateWishListModalHeader    ,

    };

    @wire(getBa ) business ({ error, data }) {
        if ( data )
        {
            this.ba = data ;
            console.log ( 'ba wired ' + JSON.stringify (data) ) ; 
        }
        if (error)
        {
            console.log( ' error == ' + JSON.stringify(error))
        }
    }

    clearCart ( )
    {
        deleteCart(
            {
                webCardId : this.cardId  ,
                effectiveAccountId :  this.effectiveaccountId
    
            }  ).then(resp =>{

                eval("$A.get('e.force:refreshView').fire()");
    
            //  this.deleteProduct ( cartItem ); 
    
            });
    }

    createNewWishList () {

        createWhishList(
        {
            webCartId : this.cardId ,
            effectiveAccountId : this.effectiveaccountId,
            whishlistName : this.template.querySelector('[data-id="wishlistName"]').value
        }).then(resp=>{
            this.hideModal () ;
            this.showNotification ('Success' , this.label.smc_cl_WishListCreated , 'Success' );
        });
    }

    diplayModal(){
        this.showModalCreateWishList = true ; 
    }

    hideModal (){
        this.showModalCreateWishList = false; 
    }

    showNotification(title , message , variant) {
        const evt = new ShowToastEvent({
            title   :   title   ,
            message :   message ,
            variant :   variant
        });
        this.dispatchEvent(evt);
    }


}