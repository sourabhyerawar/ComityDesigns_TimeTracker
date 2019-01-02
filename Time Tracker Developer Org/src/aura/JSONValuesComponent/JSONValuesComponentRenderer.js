({
    afterRender : function( component, helper ) {
        
        this.superAfterRender();
        //console.log('Inside afterRenderer');
        var isField=component.get("v.isField");
        if(isField){
            //console.log('B4 showing jsonvalue');
            helper.showElement(component, 'fieldDiv');
            if(component.get('v.disableEntryEdit')){
                //console.log('Inside disableEntryEdit of jsonvalue');
                component.find('fieldNameID').set('v.disabled', true);
                component.find('isSearched').set('v.disabled', true);
                component.find('isShown').set('v.disabled', true);
                //console.log('B4 hideElement');
                helper.hideElement(component, 'addFieldButtonID');
            }
        }
        else{
            if(component.get('v.disableEntryEdit')){
                component.find('filterID').set('v.disabled', true);
                helper.hideElement(component, 'addFilterButtonID');
            }
            helper.showElement(component,  'filterDiv');
        }
    }
})