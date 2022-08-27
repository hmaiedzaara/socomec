import { LightningElement, track , api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import smc_cl_demandeDisponibilite_AddLine from '@salesforce/label/c.smc_cl_demandeDisponibilite_AddLine';
import smc_cl_DemandeDisponibilite_Calculer from '@salesforce/label/c.smc_cl_DemandeDisponibilite_Calculer';
import smc_cl_Product from '@salesforce/label/c.smc_cl_Product';
import smc_cl_Quantity from '@salesforce/label/c.smc_cl_Quantity';


export default class Smc_demande_disponibilite extends LightningElement {


    @api numberOfRow ; 
    @api MaxNumberOfRow;
    @track l_Element = [];

    label = 
    {
        smc_cl_demandeDisponibilite_AddLine,
        smc_cl_DemandeDisponibilite_Calculer,
        smc_cl_Product,
        smc_cl_Quantity
    };


    connectedCallback( ){
        
        for (let rows = 1 ; rows <= this.numberOfRow && rows <= this.MaxNumberOfRow ; rows++ ){
            this.createElement();
        }
        
    }

    createElement(){

        if ( this.l_Element.length < this.MaxNumberOfRow){
            this.l_Element.push(
                {
                    id : this.l_Element.length,
                    productSkuId    : 'productSKU_'+this.l_Element.length,
                    quantityId      : 'quantity_'+this.l_Element.length
                });
        }else{
            this.showNotification();
        }
    }


    showNotification() {
        const evt = new ShowToastEvent({
            title: 'Info',
            message: 'Vous ne pouvez pas rajouter plus que '+ this.MaxNumberOfRow + ' produits',
            variant: 'info'
        });
        this.dispatchEvent(evt);
    }
}