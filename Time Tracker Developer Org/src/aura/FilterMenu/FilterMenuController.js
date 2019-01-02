({
    doInit : function(component, event, helper) {
		
		var displayFieldsMetadata, customSettingList, filterMenu, selectedFilterMenu, consts;
		displayFieldsMetadata = component.get('v.displayFieldsMetadata');
		customSettingList = component.get('v.customSettingList');
		filterMenu = helper.createFilterMenuItems(component, displayFieldsMetadata, customSettingList);
		selectedFilterMenu = filterMenu.filter(function(el) { 
			return el.uniqueValues;
		});
		
		consts = helper.getConstants(component);
		//console.log('consts',consts,'selectedFilterMenu',selectedFilterMenu);
		helper.createFilterMenuItemsComponent(component, selectedFilterMenu);
		component.set('v.consts', consts);
    },

    showMenu : function(component, event, helper) {
		
		//console.log('FilterMenuController.showMenu: entered');
		helper.changeButtonToLoading(component, false);
		helper.toggleMenu(component,'menuDiv');
    },

    handleDone:function(component, event, helper){
		
		//console.log('FilterMenuController.handleDone: entered');
		helper.changeButtonToLoading(component, true);

		//Following logic is to add delay to show the waiting text to user when done is clicked.
		window.setTimeout($A.getCallback(function() {
			if(component.isValid()) {
				helper.fetchFilters(component);//---1
				helper.doFiltering(component);	//---3
				helper.toggleMenu(component,'menuDiv');
				helper.clearAllValues(component);
			}
		}),1000);
    },

    receiveSentFilter: function(component, event, helper) {	//---2
        
		//console.log('FilterMenuController.receiveSentFilter: entered');
        var customSettingList, filteringAttribute, currentPillList, filteredSettings, displayPills;
        customSettingList = component.get('v.customSettingList');
        filteringAttribute = event.getParam('filteringAttribute');
        currentPillList = component.get('v.currentPillList');
        
		filteredSettings = helper.filterCustomSettings(customSettingList, filteringAttribute);
        displayPills = helper.getDisplayPills(currentPillList, filteringAttribute);
        //console.log('customSettingList',customSettingList,'filteringAttribute',filteringAttribute);
		//console.log('currentPillList',currentPillList,'displayPills',displayPills);
		
        helper.fireFilterTableEvent(filteredSettings);
        helper.showFilterPills(component, displayPills);
        component.set('v.currentPillList', filteringAttribute)
        //console.log('FilterMenuController.receiveSentFilter: exit');
    },

    clearAllFilters: function(component, event, helper) {
        
		//console.log('FilterMenuController.clearAllFilters');
        var currentPillList = component.get('v.currentPillList');
        component.set('v.filterPillFacet', []);
        component.set('v.currentPillList',[]);
        
		var filteringAttribute = [];
        var customSettingList = component.get('v.customSettingList');
        var filteredSettings = helper.filterCustomSettings(customSettingList, filteringAttribute);
        
		//console.log('customSettingList',customSettingList,'filteredSettings',filteredSettings,'currentPillList',currentPillList);
        helper.fireFilterTableEvent(filteredSettings);
        helper.fireResetFilterEvent(component, currentPillList);
        
		/*
		currentPillList.forEach( function(el) {
          console.log('el', el);
        });
		//*/
    },
   
    handlePillClear : function(component, event, helper) {
        
		//console.log('FilterMenuController.handlePillClear: entered');
        var customSettingList = component.get('v.customSettingList');
        var removedPillEleList = event.getParam('pillDetailsList');
        var currentPillList = component.get('v.currentPillList');
        var filteringAttribute = helper.getDisplayPills(removedPillEleList, currentPillList);

        //console.log('currentPillList',currentPillList,'customSettingList',customSettingList);
		//console.log('removedPillEleList',removedPillEleList,'filteringAttribute',filteringAttribute);
        
        var filteredSettings = helper.filterCustomSettings(customSettingList, filteringAttribute);
        helper.fireFilterTableEvent(filteredSettings);
        
		//helper.showFilterPills(component, filteringAttribute);
        component.set('v.currentPillList', filteringAttribute);
        //console.log('customSettingList',customSettingList,'filteringAttribute',filteringAttribute,'pillAttribute',pillAttribute);
        //console.log('event',event);
        //helper.handlePillClear(component, event.getParam('pillLabel'));
    },
    
    /*
	hideFilter : function(component, event, helper){
    	console.log('Filter div clicked');
        if(!component.get('v.isDropDownOpen')){
         	helper.closeDropdown(component,'menuDiv');   
        }
    	component.set('v.isDropDownOpen',false);
    },
    
    dropDownClick : function(component, event, helper){
        component.set('v.isDropDownOpen', true);
        console.log('isDropDownOpen >>'+component.get('v.isDropDownOpen'));
    }
	//*/
})