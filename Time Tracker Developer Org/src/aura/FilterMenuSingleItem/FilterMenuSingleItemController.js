({
    doInit : function(component, event, helper) { 
      
		//console.log('FilterMenuSingleItemController.doInit : entered');
		var filterMenu = component.get("v.filterMenu");
		var consts = helper.getConstants(component);
		component.set('v.consts',consts);
		//console.log('filterMenu',filterMenu);
    },

    toggleSelection : function(component, event, helper) {
      
	  //console.log('FilterMenuSingleItemController.toggleSelection : entered, event.target: ',event.currentTarget.parentNode);
      var selectElement = helper.filterElementByUniqueClass(event.currentTarget.parentNode.childNodes, 'filter-type-text');
      
	  //console.log('event.target.childNodes', event.currentTarget.parentNode.childNodes);
      //event.currentTarget.parentNode.childNodes.forEach(function(el) { if(el.className.includes('filter-type-text')) selectElement = el; });
      //console.log('selectElement',selectElement,'component.get("v.thisHandlesEvent"):',component.get("v.thisHandlesEvent"));
      
	  (!component.get("v.thisHandlesEvent"))? component.set("v.thisHandlesEvent", false):component.toggleSelectionet("v.thisHandlesEvent", true);
      $A.util.toggleClass(selectElement, 'slds-show');
      
	  //component.set('v.indexData', selectElement.data);
      //helper.toggleElement(component, 'filtermenuselect');
      /*
	  if(!component.get('v.isBinary')) {
        helper.toggleElement(component, 'dropDownDiv'); 
      }
	  //*/ 
    },

    populateIndexData: function(component, event, helper) {
      
	  /*
	  console.log('FilterMenuSingleItemController.populateIndexData: entered');
      console.log('event.currentTarget.childNodes',event.currentTarget.childNodes);
	  //*/
      var selectElement = helper.filterElementByUniqueClass(event.currentTarget.childNodes, 'filter-type-text');
      component.set('v.indexData', selectElement.data);
    },
    
    setSelectedValue : function(component, event, helper) {
		
		//console.log('FilterMenuSingleItemController.setSelectedValue:entered, event.currentTarget',event.currentTarget);
		//console.log('event src',event.getSource(),'Id', component.getLocalId());
		
		var filterMenu = component.get('v.filterMenu');
		var index = component.get('v.indexData');
		
		//console.log('event.currentTarget.parentNode:',event.currentTarget.parentNode,'index',index);
		//console.log('component',component, 'event', event);
		
		if(Number.isInteger(index))
		filterMenu[index].selectedValue = event.currentTarget.value;
		//console.log('filterMenu:',filterMenu);
    },
    
    sendFilters : function(component, event, helper) {
        
		//console.log('FilterMenuSingleItemController.sendFilters: entered');
        if(!component.get('v.thisHandlesEvent')) {
            //console.log('Inside sendFilters');
            helper.sendFilters(component, event);    
        } 
		else {
			//console.log('hellp');
			//do nothing
        } 
    },

    resetFilters: function(component, event, helper) {
        
		//console.log('FilterMenuSingleItemController.resetFilters: entered');
        var filterMenu = component.get("v.filterMenu");
        //console.log('filterMenu',filterMenu);
        
		var removedFilterEleList = event.getParam('removedFilterEleList');
        //console.log('removedFilterEleList',removedFilterEleList);
        
        var consts = helper.getConstants(component);
        var filterIndexListToReset = helper.resetFiltersToDefaultValues(component, removedFilterEleList, filterMenu);
        //console.log('filterIndexListToReset',filterIndexListToReset);
        
        //console.log('filterIndexListToReset',filterIndexListToReset);

        filterIndexListToReset.forEach( function(el, idx, arr) {
            
			/*
			var dataNode = component.find("filtermenulist").getElement().childNodes[el].childNodes;
            console.log('dataNode', dataNode);
			//*/
			
            //component.find("filtermenulist").get("v.value", consts.LBL_SELECT);
            component.find("filtermenulist").getElement().childNodes[el].getElementsByTagName('select')[0].selectedIndex = 0;
            filterMenu[el].selectedValue = consts.LBL_SELECT;
            var selectElement = helper.filterElementByUniqueClass(component.find("filtermenulist").getElement().childNodes[el].childNodes, 'filter-type-text');
            $A.util.toggleClass(selectElement, 'slds-show');
        })
    }
})