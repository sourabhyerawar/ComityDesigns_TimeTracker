<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Timesheet_Decrement_No_of_Submissions</fullName>
        <field>Number_of_Submission_for_Approval__c</field>
        <name>Timesheet - Decrement No. of Submissions</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>PreviousValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Timesheet_Increment_No_of_Submissions</fullName>
        <field>Number_of_Submission_for_Approval__c</field>
        <name>Timesheet - Increment No. of Submissions</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>NextValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Timesheet_Number_of_Rejections</fullName>
        <field>Number_of_Rejections__c</field>
        <name>Timesheet - Number of Rejections</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>NextValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Timesheet_Update_Status_Approved</fullName>
        <field>Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Timesheet - Update Status Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Timesheet_Update_Status_Recalled</fullName>
        <field>Status__c</field>
        <literalValue>Recalled</literalValue>
        <name>Timesheet - Update Status Recalled</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Timesheet_Update_Status_Rejected</fullName>
        <field>Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Timesheet - Update Status Rejected</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Timesheet_Update_Status_Submitted</fullName>
        <field>Status__c</field>
        <literalValue>Submitted</literalValue>
        <name>Timesheet - Update Status Submitted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Timesheet_Update_Submission_Date</fullName>
        <field>Latest_Submission_Date__c</field>
        <formula>Now()</formula>
        <name>Timesheet - Update Submission Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
</Workflow>
