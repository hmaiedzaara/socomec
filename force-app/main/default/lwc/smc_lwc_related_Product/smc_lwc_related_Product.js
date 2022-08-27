import { LightningElement , wire , track , api} from 'lwc';
import getRelatedProduct from '@salesforce/apex/SMC_RelatedProductController.getRelatedProduct'
import smc_cl_Produit_de_remplacement_Title_Label from '@salesforce/label/c.smc_cl_Produit_de_remplacement_Title_Label';



export default class smc_lwc_related_Product extends LightningElement {
    @track  lstRelatedProduct       ;
    @api    recordId                ; 
    @api    effectiveAccountId      ;
    @api    title                   ;
    @api    numberOfProductToDisplay;
            SKU                     ;
            showComponenet  =  false;

    label = 
    {
        smc_cl_Produit_de_remplacement_Title_Label
    }

    connectedCallback(){
        
        this.componenetTtitle() ; 
        getRelatedProduct({idProduct : this.recordId , numberOfProduct : this.numberOfProductToDisplay, effectiveAccountId: this.effectiveAccountId }).then(resp =>{
             this.lstRelatedProduct =  resp;
             if ( this.lstRelatedProduct.length > 0 )
             {
                this.showComponenet = true ; 
             }

        });
    }

    componenetTtitle () {
         if(this.title.length > 0 )
        {
            this.label.smc_cl_Produit_de_remplacement_Title_Label = this.title ; 
        }
    }

}