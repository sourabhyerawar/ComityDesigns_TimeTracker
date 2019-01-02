/**
    @ Purpose : Holds the response to be sent to lightning component --> LexManualTimeTracker.
*/
public class LexManualTimeTrackerWrapper {
    
    public Boolean isSucceeded;
    
    public String strMessage;
    
    public String strNamespace;
    
    public TimeTrackerUserSettings__c loggedInUserSettings;
    
    public List<TimeTrackerConfigSettings__c> listOfMiscellaneousSettings;
    
    public List<ManualActivityWrapper> listOfManualActivityWrappers;
    
    public Time_Tracker__c ttRecord;
     
    public LexManualTimeTrackerWrapper() {
        
        this.isSucceeded = FALSE;
        this.strMessage = '';
        this.strNamespace = '';
        
        this.loggedInUserSettings = TimeTrackerUserSettings__c.getInstance( UserInfo.getUserId() );
        this.listOfMiscellaneousSettings = new List<TimeTrackerConfigSettings__c>();
        this.listOfManualActivityWrappers = new List<ManualActivityWrapper>();
        
        this.ttRecord = new Time_Tracker__c();
    }
    
    public void setStatus( Boolean isSucceeded, String strMessage ) {
        
        if( isSucceeded != NULL ) {
            this.isSucceeded = isSucceeded;
        }
        
        if( strMessage != NULL ) {
            this.strMessage = strMessage;
        }
    }
    
    /*
        @ Purpose : Sets the namespace if available.
    */
    public void setNamespace() {
        
        try {
            ApexClass timeTrackerControllerClass = [ SELECT NameSpacePrefix 
                                                     FROM ApexClass 
                                                     WHERE Name = 'TimeTrackerController' 
                                                     LIMIT 1 
                                                   ];
            if( String.isNotBlank( timeTrackerControllerClass.NameSpacePrefix ) ) {
                this.strNamespace = timeTrackerControllerClass.NameSpacePrefix + '__';
            }
            this.setStatus( TRUE, this.strNamespace + ' namespaceprefix is set successfully.' );
        }
        catch( Exception e ) {
            String strErrorMessage = 'Sorry, an unexpected error occurred while fetching namespaceprefix.';
            System.debug( strErrorMessage + ' ' + e.getMessage() );
            this.setStatus( FALSE, strErrorMessage + ' Please contact System Administrator.' );
        }
    }
    
    public class ManualActivityWrapper {
        
        public String manualActivityType;
        
        public List<String> listOfShowFields;
        
        public String sObjectLabel;
        
        public String sObjectApiName;
        
        public String sObjectKeyPrefix;
        
        public String sObjectSearchField;
            
        public Boolean isSobjectRequired;
            
        public Boolean isCommentRequired;
        
        public ManualActivityWrapper() {
            
            this.manualActivityType = '';
            this.listOfShowFields = new List<String>();
            this.sObjectLabel = '';
            this.sObjectApiName = '';
            this.sObjectKeyPrefix = '';
            this.sObjectSearchField = '';
            this.isSobjectRequired = FALSE;
            this.isCommentRequired = FALSE;
        }
        
        public ManualActivityWrapper( String manualActivityType, List<String> listOfShowFields, String sObjectLabel, 
                                      String sObjectApiName, String sObjectSearchField, Boolean isSobjectRequired,
                                      Boolean isCommentRequired
        ) {
            
            this();
            if( String.isNotBlank( manualActivityType ) ) {
                this.manualActivityType = manualActivityType;
                
                if( listOfShowFields != NULL ) {
                    this.listOfShowFields = listOfShowFields;
                }
                
                if( sObjectLabel != NULL ) {
                    this.sObjectLabel = sObjectLabel;
                }
                
                if( sObjectApiName != NULL ) {
                    this.sObjectApiName = sObjectApiName;
                }
                
                if( sObjectSearchField != NULL ) {
                    this.sObjectSearchField = sObjectSearchField;
                }
                
                if( isSobjectRequired != NULL ) {
                    this.isSobjectRequired = isSobjectRequired;
                }
                
                if( isCommentRequired != NULL ) {
                    this.isCommentRequired = isCommentRequired;
                }
            }
        }
    }
    
    public class TimeTrackerWrapper {
        
        public String strTrackedTime;
        
        public String strTrackedDuration;
        
        public String strActivityDateTime;
        
        public String strActivitySubType;
        
        public String strObjectId;
        
        public String strComments;
        
		public List<ManualLineItem__c> listOfManualLineItems;
		
        public TimeTrackerWrapper() {
            
            this.strTrackedTime = '';
            this.strTrackedDuration = '';
            this.strActivityDateTime = '';
            this.strActivitySubType = '';
            this.strObjectId = '';
            this.strComments = '';
			this.listOfManualLineItems = new List<ManualLineItem__c>();
        }
    }
}