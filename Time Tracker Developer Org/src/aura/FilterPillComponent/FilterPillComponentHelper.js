({
    hideElement : function(component, element) {
        $A.util.addClass(element, 'slds-hide');
        $A.util.removeClass(element,'slds-show');
    },

    getRemovedElementListFromPillDetailsList: function(component, index) {
        
		var pillDetailsList = component.get('v.pillDetailsList');
        var removedElementList = [];
        removedElementList.push(pillDetailsList[index]);
        //console.log('pillDetailsList',pillDetailsList);
        return removedElementList;
    },
    
    fireClearFilterPillEvent : function(component, removedElementList) { 
        
		//console.log('FilterPillComponentHelper.fireClearFilterPillEvent: entered');
        //console.log('removedElementList', removedElementList);
		
        var evt = component.getEvent('ClearFilterPillEvent');
        evt.setParams({ pillDetailsList : removedElementList });
        evt.fire();
    },

    fireResetFilterEvent: function(component, removedElementList) {
        
		//console.log('FilterPillComponentHelper.fireResetFilterEvent: entered');
        //console.log('removedElementList',removedElementList);
		
        var evt = $A.get('e.c:resetFilterEvent');
        evt.setParams({ 'removedFilterEleList': removedElementList});
        evt.fire();
    },
    
    enableSpinnerOnTable : function(component){
		
        var evt = $A.get('e.c:SpinnerToggle');
        evt.fire();
    },
})