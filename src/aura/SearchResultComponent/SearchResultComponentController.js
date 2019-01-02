/*
  	@ PURPOSE : CONTROLS THE LIGHTNING COMPONENT --> SearchResultComponent.cmp
	@ NAME 	  : SearchResultComponentController.js
*/
({    
	/*
		@ PURPOSE : FIRES AN APPLICATION EVENT WITH SELECTED LABEL, VALUE, TARGET COMPONENT'S AURA ID, 
					AND THE NAME OF THE ATTRIBUTE THAT HOLDS LIST OF VALUES.
	*/
    setSelection : function( component, event, helper ) {
        
        var selectedRecord = { 
            				  'label' : component.get( "v.selectLabel" ),
            				  'value' : component.get( "v.selectValue" ),
            				  'fieldAuraId' : component.get( "v.fieldAuraId" ),
            				  'fieldNameOfListOfSourceRecords' : component.get( "v.fieldNameOfListOfSourceRecords" )
							 };
        
        var setSelection = $A.get( "e.c:SetSelection" );
        setSelection.setParams({ "selectedRecord" : selectedRecord });
        setSelection.fire();
    }
})