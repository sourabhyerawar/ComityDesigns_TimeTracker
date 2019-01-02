({
   filterElementByUniqueClass: function(listOfNodes, className){
        
		var element;
        listOfNodes.forEach(function(el) { 
           if(el.className.includes(className)) element = el; 
        });
        return element;
    },

    sendFilters: function(component, event){
        
		//console.log('FilterMenuSingleItemHelper.sendFilters: entered');
        //send value and filter back to parent
		
        var SendFilter = component.getEvent("SendFilter");
        var filterMenu = component.get("v.filterMenu");
        var consts = this.getConstants(component);
        //console.log('filterMenu',filterMenu);
		
        var filteringAttribute = filterMenu.filter( function(el) { 
            //console.log('el.selectedValue',el.selectedValue);
            return el.selectedValue&&el.selectedValue!==consts.LBL_SELECT;
        });
		
        //console.log('filteringAttribute',filteringAttribute);
        SendFilter.setParams({ "filteringAttribute": filteringAttribute });
        SendFilter.fire();
    },

    resetFiltersToDefaultValues: function(component, removedFilterEleList, filterMenu) {
        
		//console.log('FilterMenuSingleItemHelper. resetFiltersToDefaultValues: entered');
        var filterIndexListToReset =[];
        if(!filterMenu||filterMenu.length<1||!removedFilterEleList||removedFilterEleList.length<1) return;
		
        filterMenu.forEach( function(el1, idx1, arr1) {
            removedFilterEleList.forEach( function(el2, idx2, arr2) {
                if(el1.labelName===el2.labelName) {
                    filterIndexListToReset.push(idx1);
                }
            });
        });
		
        return filterIndexListToReset;
    },
    
    toggleElement : function(component, elementDiv) {
        
		//console.log('FilterMenuSingleItemHelper.toggleElement: entered');
        var divElement = component.find(elementDiv);
		
        //console.log(divElement,':divElement');
        $A.util.toggleClass(divElement, 'slds-show');
    },
	
	getConstants: function(component) {
       
       var consts = {
       				'LBL_FLAG3':'Non-Reportable',
       				'LBL_FLAG4':'Create Staging Record',
       				};
       	if(component.get('v.namespace')) {
       		consts['LBL_SELECT'] = $A.get("$Label.timetracker.LBL_Select_DropDown");
       	}
        else {
        	consts['LBL_SELECT'] = $A.get("$Label.c.LBL_Select_DropDown");
        }
       return consts;
    }
})