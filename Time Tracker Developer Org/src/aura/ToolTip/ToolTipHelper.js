({
    toggleMenu : function(component, menuDiv) {
        var divElement=component.find(menuDiv);
        //$A.util.removeClass(divElement, 'slds-hide');
        $A.util.toggleClass(divElement, 'slds-hide');
    },
})