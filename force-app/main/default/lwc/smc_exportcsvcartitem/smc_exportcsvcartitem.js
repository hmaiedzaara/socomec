import { LightningElement , api} from 'lwc';
import exportData from '@salesforce/apex/SMC_myCartController.exportData'
import smc_cl_ExportCartItemButton from '@salesforce/label/c.smc_cl_ExportCartItemButton';

export default class Smc_exportcsvcartitem extends LightningElement {

    @api cartId ;

    label = 
    {
        smc_cl_ExportCartItemButton
    }

    exportCsv (){

        exportData({ 
            cartId :  this.cartId
        })
            .then(data => {
                let docName='MyCart.csv';
                let doc = data;
                var element = 'data:application/csv,' + encodeURIComponent(doc);
                let downloadElement = document.createElement('a');
                downloadElement.href = element;
                downloadElement.target = '_self';
                downloadElement.download = docName;
                document.body.appendChild(downloadElement);
                downloadElement.click();
            })
            .catch(error => {
                console.error('Error: \n ', error);
            });

    }
}