import { LightningElement, api } from "lwc";
import { loadScript } from "lightning/platformResourceLoader";
import workbook from "@salesforce/resourceUrl/xlsx";

export default class Smc_lwc_utils_export_to_excel extends LightningElement {
  @api headerList;
  @api filename;
  @api worksheetNameList;
  @api sheetData;
  librariesLoaded = false;

  renderedCallback() {
    if (this.librariesLoaded) {
      return;
    }
    this.librariesLoaded = true;
    Promise.all([loadScript(this, workbook + "/xlsx/xlsx.full.min.js")])
      .then(() => {
        console.log("renderedCallback xlsx : SUCCESS");
        this.dispatchEvent(
          new CustomEvent("loadxlsx", {
            detail: true
          })
        );
      })
      .catch(error => {
        console.log("renderedCallback xlsx : FAILURE");
        this.dispatchEvent(
          new CustomEvent(loadxlsx, {
            detail: false
          })
        );
      });
  }
  @api download() {
    const XLSX = window.XLSX;
    let xlsData = this.sheetData;
    let xlsHeader = this.headerList;
    let ws_name = this.worksheetNameList;
    let createXLSLFormatObj = Array(xlsData.length).fill([]);
    /* form header list */
    let itemListApiName = [];
    xlsHeader.forEach((item, index) => {
      let itemList = [];
      let itemListValue = [];
      item.forEach(idx => {
        itemList.push(idx.label);
        if (idx.type === "number") {
          itemListValue.push({ name: idx.fieldName, type: "n" });
        } else if (idx.type === "date") {
          itemListValue.push({ name: idx.fieldName, type: "d" });
        } else {
          itemListValue.push({ name: idx.fieldName, type: null });
        }
      });
      itemListApiName.push(itemListValue);
      createXLSLFormatObj[index] = [itemList];
    });

    /* form data key list */
    xlsData.forEach((item, index) => {
      item.forEach(elmt => {
        var innerRowData = [];
        itemListApiName[index].forEach(selectedRow => {
          if (selectedRow.type === "d") {
            innerRowData.push(
              elmt[selectedRow.name] !== null
                ? new Date(elmt[selectedRow.name])
                : ""
            );
          } else {
            innerRowData.push(
              elmt[selectedRow.name] !== null ? elmt[selectedRow.name] : ""
            );
          }
        });
        createXLSLFormatObj[index].push(innerRowData);
      });
    });

    /* creating new Excel */
    var wb = XLSX.utils.book_new();

    /* creating new worksheet */
    var ws = Array(createXLSLFormatObj.length).fill([]);
    for (let i = 0; i < ws.length; i++) {
      /* converting data to excel format and puhing to worksheet */
      let data = XLSX.utils.aoa_to_sheet(createXLSLFormatObj[i]);
      ws[i] = [...ws[i], data];

      /* Add worksheet to Excel */
      XLSX.utils.book_append_sheet(wb, ws[i][0], ws_name[i]);
    }

    /* Write Excel and Download */
    XLSX.writeFile(wb, this.filename);
  }
}