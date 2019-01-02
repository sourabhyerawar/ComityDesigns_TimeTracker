({
    createFilterMenuItems : function(component, displayFieldsMetadata, customSettingList){
        
		//console.log('FilterMenuHelper.createFilterMenuItems: entered');
        //console.log('displayFieldsMetadata',displayFieldsMetadata,'customSettingList',customSettingList); 
		
        var filterMenu = JSON.parse(JSON.stringify(displayFieldsMetadata)); 
        for(var i=0; i<filterMenu.length; i++) {
            var uniqueValuesInCustomSettingList = new Set();
            for(var j=0; j<customSettingList.length; j++) {
				
                var value = customSettingList[j][(filterMenu[i]['apiName'])];
                (value===undefined || value==='')? value = 'NA' : value;
                uniqueValuesInCustomSettingList.add(value);
            }
			
            if(uniqueValuesInCustomSettingList.size>1) 
                filterMenu[i].uniqueValues = Array.from(uniqueValuesInCustomSettingList);
        }
		
        //console.log('filterMenu: ',filterMenu);
        return filterMenu;
    },

    createFilterMenuItemsComponent : function(component, filterMenu){
        
		//console.log('FilterMenuHelper.createFilterMenuItemsComponent: entered');
        var customSettingList = component.get("v.customSettingList");
        //console.log('customSettingList',customSettingList,'filterMenu',filterMenu);
        
		$A.createComponent(
            "c:FilterMenuSingleItem",
            {
                "customSettingList": customSettingList,
                "filterMenu": filterMenu,
                "namespace": component.get( 'v.namespace')
            },
            function(newComponent, status, errorMessage){
                //Add the new button to the body array
                if (status === "SUCCESS") {
                    var body = component.get("v.body");
                    body.push(newComponent);
                    component.set("v.body", body);
                } 
				else if (status === "INCOMPLETE") {
                    //console.log("No response from server or client is offline.");
                    component.set('v.errorMsg', 'No response from server or client is offline.');
                    //this.showElement(component, 'errorMsgID');
                    // Show offline error
                } 
				else if (status === "ERROR") {
                    //console.log("Error: " + errorMessage);
                    //console.log("Error status: " , status);
                    component.set('v.errorMsg',errorMessage);
                }
            }
        );
    },

    fetchFilters : function(component){
        
		var fetchFilters = $A.get("e.c:fetchFilters");
        //console.log('fetchFilters:', fetchFilters);
        fetchFilters.fire();
    },

    // Funnction to clear all maps and lists after 1 click of Done filter.
    // This will help to apply fresh filter for next click of done filter button.
    clearAllValues : function(component){
        
		var filteringAttributeList=component.get('v.filteringAttributeList');
        filteringAttributeList=[];
        component.set('v.filteringAttributeList', filteringAttributeList);
        
		//console.log('filteringAttributeList afte clearing in clearAllvalues : ' , component.get('v.filteringAttributeList'));
        var fieldAPINameToValueMap=component.get('v.fieldAPINameToValueMap');
        component.set('v.fieldAPINameToValueMap_Backup' , fieldAPINameToValueMap);	//Taking backup to use later in case of filter after pills removal
        fieldAPINameToValueMap={};
        component.set('v.fieldAPINameToValueMap', fieldAPINameToValueMap);
    },

    createAPINameToValueMap: function(component, filteringAttribute, removeMe) {
        
		//console.log('filteringAttribute',filteringAttribute);
        /*Creating list of filtering attribute labels to show later as pills*/
        this.createPillsList(component, filteringAttribute);
    },

    createPillsList : function(component, filteringAttribute, filteringAttributeValue) {
        
		//console.log('filteringAttribute : ' + filteringAttribute + 'filteringAttributeValue : ' + filteringAttributeValue);
        var filteringAttributeList=component.get('v.filteringAttributeList');
        var consts = this.getConstants(component);
        
		//console.log('filteringAttributeList : ' , filteringAttributeList);
        if(filteringAttributeValue === false && filteringAttribute !== consts.LBL_FLAG3) {
            if(filteringAttribute === consts.LBL_FLAG4) {
                filteringAttribute = 'Do Not ' + filteringAttribute;
            } else {
                filteringAttribute='Non-' + filteringAttribute;
            }
        }
		
        if(filteringAttribute === consts.LBL_FLAG3 && filteringAttributeValue === false) {
            filteringAttribute ='Reportable';
        }
		
        filteringAttributeList.push(filteringAttribute);
        component.set('v.filteringAttributeList', filteringAttributeList);
    },

    changeButtonToLoading: function(component, isDone) {
        
		//console.log('Inside done filtering');
        var consts = this.getConstants(component);
        var doneButton = component.find('doneFilterButton');
        if(isDone) {
            component.set('v.doneLabel', consts.LBL_FILTERING);
            doneButton.set('v.disabled', true);
        } 
		else {
            component.set('v.doneLabel', consts.LBL_APPLY);
            doneButton.set('v.disabled', false);
        }
    },

    filterCustomSettings: function(customSettingList, filteringAttribute) {
        
		//console.log('FilterMenuHelper.filterCustomSettings: entered','customSettingList',customSettingList,'filteringAttribute',filteringAttribute);
        var fiteredList = customSettingList;
        var selectedValue;

        for(var i=0; i<filteringAttribute.length; i++) {
            //console.log('filteringAttribute[i].apiName',filteringAttribute[i].apiName);
			//console.log('filteringAttribute[i].selectedValue',filteringAttribute[i].selectedValue);
            switch(filteringAttribute[i].selectedValue) {
                case 'NA' : selectedValue = undefined ;
							break;
                case 'true': selectedValue = true;
							 break;
                case 'false': selectedValue = false;
							  break;
                default:
						selectedValue = filteringAttribute[i].selectedValue;
            } ; 
            //console.log('selectedValue: ',selectedValue)
            fiteredList = fiteredList.filter(function(el) {
                return el[(filteringAttribute[i].apiName)]===selectedValue;
            });
            //console.log('fiteredList',fiteredList);
        }
        //console.log('fiteredList',fiteredList);
        return fiteredList;
    },

    getDisplayPills: function(currentPillList, filteringAttribute) {
        
		//console.log('FilterMenuHelper.getDisplayPills: entered');
        //console.log('currentPillList',currentPillList,'filteringAttribute',filteringAttribute);
        var displayPills = JSON.parse(JSON.stringify(filteringAttribute));
        if(!currentPillList||currentPillList.length<1) return displayPills;
        
		/*
		for(var i=0; i<currentPillList.length; i++) {
            displayPills.forEach( function(el, idx, arr) {
                //console.log('el.apiName',el.apiName,'currentPillList[i].apiName',currentPillList[i].apiName);
                if(el.apiName===currentPillList[i].apiName)  arr.splice(idx, 1);
            });
        }
		//*/

        currentPillList.forEach( function(el1) {
            displayPills.forEach( function(el, idx, arr) {
                //console.log('el.apiName',el.apiName,'currentPillList[i].apiName',currentPillList[i].apiName);
                if(el.apiName === el1.apiName)  arr.splice(idx, 1);
            });
        }) 
		
        //console.log('displayPills',displayPills);
        return displayPills;  
    },

    doFiltering : function(component ){
        
		//console.log('FilterMenuHelper.doFiltering: entered');
    },

    fireFilterTableEvent: function(filteredCustomSettingList) {
        
		//console.log('FilterMenuHelper.callFilterTableEvent: entered');
        //console.log('filteredCustomSettingList',filteredCustomSettingList);
		
        var evt = $A.get('e.c:FilterTableEvent');
        evt.setParams({ "filteredCustomSettingList": filteredCustomSettingList });
        evt.fire();
    },

    fireResetFilterEvent: function(component, removedElementList) {
        
		//console.log('FilterPillComponentHelper.fireResetFilterEvent: entered');
        //console.log('removedElementList',removedElementList);
		
        var evt = $A.get('e.c:resetFilterEvent');
        evt.setParams({ 'removedFilterEleList': removedElementList});
        evt.fire();
    },

    showFilterPills : function(component, filteringAttribute) {
        
		//console.log('FilterMenuHelper.showFilterPills: entered');
        var filterPillFacet = component.get('v.filterPillFacet');
        
		//console.log('filteringAttribute',filteringAttribute,'filterPillFacet',filterPillFacet);
        $A.createComponent
		(
            "c:FilterPillComponent", {
                pillDetailsList : filteringAttribute
            }, 
			function(newComponent, status, errorMessage){
                //Add the new button to the body array
                if (status === "SUCCESS") {
                    filterPillFacet.push(newComponent);
                    component.set('v.filterPillFacet', filterPillFacet);
                } 
				else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.");
                    // Show offline error
                } 
				else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                    // Show error message
                }
            }
        );
    },


    //Method to clear the check on corrosponding filter field in filter menu , when pill is cleared
    clearCheckIcon : function(component, pillLabel){
        
		var bodyFacet=component.get('v.body');
        for(var i=0; i<bodyFacet.length ; i++) {
            var singleFilterValue = bodyFacet[i].get('v.singleFilter');
            
			if(singleFilterValue === pillLabel) {
                this.hideElement(bodyFacet[i], 'checkIconID');
                bodyFacet[i].set('v.thisHandlesEvent', false);
                
				if(!(bodyFacet[i].get('v.isBinary'))) {
                    this.hideElement(bodyFacet[i], 'dropDownDiv');
                }
            } 
        }
    },

    toggleMenu : function(component, menuDiv) {
        
		var divElement=component.find(menuDiv);
        $A.util.toggleClass(divElement, 'slds-is-open');
    },

    showElement : function(component, id) {
        
		var divElement=component.find(id);
        $A.util.removeClass(divElement, 'slds-hide');
        $A.util.addClass(divElement, 'slds-show');
    },

    hideElement : function(component, id) {
        
		var divElement=component.find(id);
        $A.util.removeClass(divElement, 'slds-show');
        $A.util.addClass(divElement, 'slds-hide');
    },
    
    closeDropdown: function(component,menuDiv) {
        
		var divElement=component.find(menuDiv);
        $A.util.removeClass(divElement, 'slds-is-open');
        
		/*
        var dropdown = cmp.find( 'filterDropDownSection' );
        if( dropdown ) {
            $A.util.removeClass(dropdown[index], 'slds-is-open');
        }
        //*/
    },
	
	getConstants: function(component) {
        
        var consts = {
        				'LBL_FILTER': 'Filter',
        				'LBL_FILTER_BY': 'Filter By :',
        				'LBL_APPLY': 'Apply',
        				'LBL_FILTERING': 'Filtering ...',
        				'LBL_CLEAR_ALL': 'Clear All',
        				'LBL_FLAG4':'Create Staging Record',
        				'LBL_FLAG3':'Non-Reportable'
        			 };
            
        if(component.get('v.namespace')){
        	consts['LBL_SELECT'] =  $A.get("$Label.timetracker.LBL_Select_DropDown");
        }
        else {
        	consts['LBL_SELECT'] =  $A.get("$Label.c.LBL_Select_DropDown");
        }
        return consts;
    }
})