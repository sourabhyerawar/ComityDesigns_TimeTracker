({
	doInit: function(component, event, helper) {
		
		//console.log('FilterPillComponentController.doInit: entered');
		var pillDetailsList = component.get('v.pillDetailsList');
		//console.log('pillDetailsList',pillDetailsList);
	},

	removeFilter : function(component, event, helper) {
		
		//console.log('FilterPillComponentController.removeFilter: entered');
		//console.log(event.currentTarget.parentNode,event.currentTarget.parentNode.parentNode);
		
		var pillElement = event.currentTarget.parentNode.parentNode;
		var indexData = event.currentTarget.data;
		//console.log('pillElement', pillElement, 'indexData', indexData);

        helper.hideElement(component, pillElement);
        var removedElementList = helper.getRemovedElementListFromPillDetailsList(component, indexData);
        helper.fireClearFilterPillEvent(component, removedElementList);
        helper.fireResetFilterEvent(component, removedElementList);
        
		//helper.enableSpinnerOnTable(component);
        //console.log('FilterPillComponentController.removeFilter: exit');
	}
})