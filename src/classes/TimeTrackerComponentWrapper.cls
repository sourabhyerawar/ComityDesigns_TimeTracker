/*
    @ PURPOSE : WRAPS ALL THE RESULT/DATA TO BE PROVIDED TO THE CLASS --> TimeTrackerComponentController.cls
*/
public without sharing class TimeTrackerComponentWrapper {
    
    // HOLDS TRUE IF TRANSACTION IS EXECUTED SUCCESSFULLY OTHERWISE FALSE.
    public Boolean isSucceeded;
    
    // HOLDS THE MESSAGE TO BE DISPLAYED TO AN END USER.
    public String strMessage;
    
    // HOLDS THE NAMESPACE OF THE PACKAGE.
    public String strNamespace;
    
    // HOLDS THE RECORD OF TIME TRACKER OBJECT.
    public Time_Tracker__c ttRecord;
    
    // HOLDS THE LIST OF STRATEGY SETTINGS.
    public List<TimeTrackerConfigSettings__c> listOfStrategySettings;
    
    // HOLDS THE LIST OF MISCELLANEOUS SETTINGS.
    public List<TimeTrackerConfigSettings__c> listOfMiscellaneousSettings;
    
    // HOLDS THE LIST OF OBJECT DETAILS SUCH AS API NAME, LABEL, PLURAL LABEL, AND PREFIX.
    public List<ObjectWrapper> listOfObjectWrappers;
    
    // HOLDS THE INSTANCE OF LOGGED-IN USER'S TIME TRACKER USER SETTINGS.
    public TimeTrackerUserSettings__c loggedInUserSettings;
    
    // HOLDS THE MAP OF LABEL API NAME WITH ITS VALUE.
    public Map<String,String> labelApiNameToValue;
    
    /*
        @ PURPOSE : INITIALIZES THE INSTANCES WITH DEFAULT VALUES.
    */
    public TimeTrackerComponentWrapper() {
            
        this.isSucceeded = FALSE;
        this.strMessage = 'Not initialized any states yet.';
        this.strNamespace = '';
        this.ttRecord = new Time_Tracker__c();
        
        this.listOfObjectWrappers = new List<ObjectWrapper>();
        this.listOfStrategySettings = new List<TimeTrackerConfigSettings__c>();
        this.listOfMiscellaneousSettings = new List<TimeTrackerConfigSettings__c>();
        this.loggedInUserSettings = TimeTrackerUserSettings__c.getInstance( UserInfo.getUserId() );
        
        this.setLabelsAndValues();
    }
    
    /*
        @ PURPOSE : SETS THE STATUS OF THE TRANSACTION/OPERATION.
    */
    public void setStatus( Boolean isSucceeded, String strMessage ) {
        
        this.isSucceeded = isSucceeded;
        this.strMessage = strMessage;
    }
    
    /*
        @ PURPOSE : SETS THE NAMESPACE IF AVAILABLE.
    */
    public void setNamespace() {
        
        this.strNamespace = TimeTrackerComponentController.class.getName().substringBefore( 'TimeTrackerComponentController' );
        if( String.isNotBlank( this.strNamespace ) ) {
            this.strNamespace = this.strNamespace.subString( 0, this.strNamespace.length() - 1 ) + '__';
        }
        this.setStatus( TRUE, this.strNamespace + ' ' + System.Label.SUCCESS_Namespace_Set_Successfully );
    }
    
    /*
        @ PURPOSE : SETS CUSTOM LABELS VALUES.
    */
    public void setLabelsAndValues() {
        
        this.labelApiNameToValue = new Map<String,String>
                                   {
                                    'ERR_Save_Time_Tracker_Record' => System.Label.ERR_Save_Time_Tracker_Record,
                                    'ERR_Object_Details_Or_Settings_Missing' => System.Label.ERR_Object_Details_Or_Settings_Missing,
                                    'ERR_Opening_Time_Tracker_Missing' => System.Label.ERR_Opening_Time_Tracker_Missing,
                                    'ERR_Invalid_Mode' => System.Label.ERR_Invalid_Mode,
                                    'ERR_Object_Details_Not_Found' => System.Label.ERR_Object_Details_Not_Found,
                                    'ERR_Strategy_Settings_Missing' => System.Label.ERR_Strategy_Settings_Missing,
                                    'ERR_Setting_Missing_For_An_Activity' => System.Label.ERR_Setting_Missing_For_An_Activity,
                                    'ERR_Action_Name_Missing' => System.Label.ERR_Action_Name_Missing,
                                    'ERR_Tab_Details_Missing' => System.Label.ERR_Tab_Details_Missing,
                                    'ERR_Not_Pushing' => System.Label.ERR_Not_Pushing
                                   };
    }
    
    /*
        @ PURPOSE : WRAPS THE DETAILS OF THE SOBJECT.
    */
    public class ObjectWrapper {
        
        // HOLDS API NAME OF THE OBJECT.
        public String objectName;
        
        // HOLDS LABEL OF THE OBJECT.
        public String objectLabel;
        
        // HOLDS PLURAL LABEL OF THE OBJECT.
        public String objectLabelPlural;
        
        // HOLDS PREFIX OF THE OBJECT.
        public String objectKeyPrefix;
        
        /*
            @ PURPOSE : INITIALIZES THE INSTANCES WITH DEFAULT VALUES.
        */
        public ObjectWrapper() {
            
            this.objectName = '';
            this.objectLabel = '';
            this.objectLabelPlural = '';
            this.objectKeyPrefix = '';
        }
        
        /*
            @ PURPOSE : INITIALIZES THE INSTANCES WITH PROVIDED VALUES.
        */
        public ObjectWrapper( String objectName, String objectLabel, String objectLabelPlural, String objectKeyPrefix ) {
            
            this();
            this.objectName = objectName;
            this.objectLabel = objectLabel;
            this.objectLabelPlural = objectLabelPlural;
            this.objectKeyPrefix = objectKeyPrefix;
        }
    }
}