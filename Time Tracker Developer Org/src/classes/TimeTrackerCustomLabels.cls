/**
    @ Purpose : 1. Holds the details of all the custom labels used in TimeTracker package.
                2. Refers them explicitly in code in order to include them in package.
*/

public class TimeTrackerCustomLabels {
    
    public static Map<String,String> getCustomLabelNameToValue( String strCustomLabelCategory ) {
        
        Map<String,String> customLabelNameToValue;
        if( String.isNotBlank( strCustomLabelCategory ) ) {
                
            if( strCustomLabelCategory.equalsIgnoreCase( 'AP Label' ) ) {
                customLabelNameToValue = new Map<String,String> 
                                         {
                                          'LBL_ConfigSetting_Custom_Event' => System.Label.LBL_ConfigSetting_Custom_Event,
                                          'LBL_ConfigSetting_Miscellaneous' => System.Label.LBL_ConfigSetting_Miscellaneous,
                                          'LBL_ConfigSetting_Object' => System.Label.LBL_ConfigSetting_Object,
                                          'LBL_ConfigSetting_Strategy' => System.Label.LBL_ConfigSetting_Strategy,
                                          'LBL_ConfigSetting_URLPattern' => System.Label.LBL_ConfigSetting_URLPattern,
                                          'LBL_Select_DropDown' => System.Label.LBL_Select_DropDown,
                                          'LBL_URL_VF_Page' => System.Label.LBL_URL_VF_Page,
                                          'LBL_Manual_Activity' => System.Label.LBL_Manual_Activity,
                                          'LBL_Custom_Events' => System.Label.LBL_Custom_Events
                                         };
            }
            else if( strCustomLabelCategory.equalsIgnoreCase( 'Error' ) ) {
                customLabelNameToValue = new Map<String,String> 
                                         {
                                          'ERR_Save_TimeTracker_Message' => System.Label.ERR_Save_TimeTracker_Message,
                                          'ERR_Save_TimeTracker_Title' => System.Label.ERR_Save_TimeTracker_Title,
                                          'ERR_Approved_Timesheet' => System.Label.ERR_Approved_Timesheet,
                                          'ERR_Cannot_Create_Timesheet' => System.Label.ERR_Cannot_Create_Timesheet,
                                          'ERR_Activity_Required' => System.Label.ERR_Activity_Required,
                                          'ERR_Invalid_duration' => System.Label.ERR_Invalid_duration,
                                          'ERR_Invalid_Activity_Date' => System.Label.ERR_Invalid_Activity_Date,
                                          'ERR_Comment_Required' => System.Label.ERR_Comment_Required,
                                          'LBL_Submit' => System.Label.LBL_Submit,
                                          'Err_TimeTracker_Edit' => System.Label.Err_TimeTracker_Edit,
                                          'ERR_SObject_Required' => System.Label.ERR_SObject_Required,
                                          'ERR_Invalid_SObject' => System.Label.ERR_Invalid_SObject,
                                          'ERR_Missing_Custom_Settings' => System.Label.ERR_Missing_Custom_Settings,
                                          'ERR_Bulk_Approval_Timesheet' => System.Label.ERR_Bulk_Approval_Timesheet,
                                          'ERR_Bulk_Rejection_Timesheet' => System.Label.ERR_Bulk_Rejection_Timesheet,
                                          'ERR_Account_Required' => System.Label.ERR_Account_Required,
                                          'ERR_Bulk_Approval_Permission' => System.Label.ERR_Bulk_Approval_Permission,
                                          'ERR_Case_Required' => System.Label.ERR_Case_Required,
                                          'ERR_Invalid_Case_Number' => System.Label.ERR_Invalid_Case_Number,
                                          'LEX_Controller_Exception' => System.Label.LEX_Controller_Exception,
                                          'LEX_Insert_Failed' => System.Label.LEX_Insert_Failed,
                                          'ERR_Invalid_comment' => System.Label.ERR_Invalid_comment,
                                          'ERR_Not_Authorize_to_Edit_Time_Tracker' => System.Label.ERR_Not_Authorize_to_Edit_Time_Tracker
                                         };
            }
            else if( strCustomLabelCategory.equalsIgnoreCase( 'Label' ) ) {
                customLabelNameToValue = new Map<String,String> 
                                         {
                                          'LBL_Time_Tracker' => System.Label.LBL_Time_Tracker,
                                          'LBL_Edit_Manual_entry' => System.Label.LBL_Edit_Manual_entry,
                                          'LBL_TT_Widget_Stop' => System.Label.LBL_TT_Widget_Stop,
                                          'LBL_TT_Widget_Start' => System.Label.LBL_TT_Widget_Start,
                                          'LBL_TT_Widget_Pause' => System.Label.LBL_TT_Widget_Pause,
                                          'LBL_Activity' => System.Label.LBL_Activity,
                                          'LBL_Duration' => System.Label.LBL_Duration,
                                          'LBL_Activity_Date' => System.Label.LBL_Activity_Date,
                                          'LBL_Get_from_Active_Tab' => System.Label.LBL_Get_from_Active_Tab,
                                          'LBL_Comment' => System.Label.LBL_Comment,
                                          'LBL_No_Timesheet_Records_found' => System.Label.LBL_No_Timesheet_Records_found,
                                          'LBL_Select_Timesheet' => System.Label.LBL_Select_Timesheet,
                                          'LBL_Account_Name' => System.Label.LBL_Account_Name,
                                          'LBL_Case_Number' => System.Label.LBL_Case_Number,
                                          'LBL_ConfigSetting_Manual' => System.Label.LBL_ConfigSetting_Manual,
                                          'LBL_Edit_TimeTracker_entry' => System.Label.LBL_Edit_TimeTracker_entry
                                         };
            }
            else if( strCustomLabelCategory.equalsIgnoreCase( 'Success' ) ) {
                customLabelNameToValue = new Map<String,String> 
                                         {
                                          'SUCCESS_Successfully_Saved_TT_Record' => System.Label.SUCCESS_Successfully_Saved_TT_Record,
                                          'SUCCESS_Bulk_Approval_Timesheet' => System.Label.SUCCESS_Bulk_Approval_Timesheet,
                                          'SUCCESS_Bulk_Rejection_Timesheet' => System.Label.SUCCESS_Bulk_Rejection_Timesheet
                                         };
            }
        }
        System.debug( 'customLabelNameToValue:-\n' + JSON.serialize( customLabelNameToValue ) );
        return customLabelNameToValue;
    }
}