({ /*
    afterRender : function( component, helper ) {
        
        this.superAfterRender();
        // this is done in renderer because we don't get
        // access to the window element in the helper js.
        
        // per John Resig, we should not take action on every scroll event
        // as that has poor performance but rather we should take action periodically.
        // http://ejohn.org/blog/learning-from-twitter/
        
        var didScroll = false
        
        window.onscroll = function() {
            if( window['scrollY'] === 0	){
                didScroll = false;
            } else {
                didScroll = true;   
            }
        };
        
        // periodically attach the scroll event listener
        // so that we aren't taking action for all events
        var idOfSetInterval = window.setInterval( $A.getCallback( function() {
            
            // Since setInterval happens outside the component's lifecycle
            // We need to check if component exist, only then logic needs to be processed
            if ( didScroll && component.isValid()) {
                //helper.showElement(component,'scrollSpinnerDiv');
                didScroll = false;
                // adapted from stackoverflow to detect when user has scrolled sufficiently to end of document
                // http://stackoverflow.com/questions/4841585/alternatives-to-jquery-endless-scrolling
                if ( window['scrollY'] >= document.body['scrollHeight'] - window['outerHeight'] + 150 ) {
                    if(!(component.get("v.customSetting").length === 0)){
                        helper.showSpinner(component, true, 'scrollSpinnerDiv');   
                        helper.showNextBatch( component );
                    }
                    else{
                        helper.hideElement(component, 'scrollTextDiv');   
                    }
                }
            }
        }), 1000 );
        
        // Save the id.We need to use in unrender to remove the setInterval()
        component.set( "v.setIntervalId", idOfSetInterval );
    },
    
    unrender: function(component,helper) {
        
        this.superUnrender();
        // Since setInterval() will be called even after component is destroyed
        // we need to remove it in the unrender
        window.clearInterval( component.get("v.setIntervalId") );
    }*/
})