let consoleState = { primaryTabs: [], lastClosedTab: {}, navigation: null, Settings: {}, chats: []};
// Error Handling
const onErrorHandler = function (msg, url, lineNo, columnNo, error) {
    console.log('Error Occured', msg);
    if(msg.indexOf('Visualforce Remoting Exception') >= 0) {
        window.postMessage({ 
        	type: 'SHOW_ERROR', 
            body: {
				type: "basic",
                title: "Time Tracker: Unexcepted Error",
				message: "Please refresh your Salesforce console tab and try again.",
                appIconMaskUrl: "../../icons/comity_tt_128_white.png",
                iconUrl: "../../icons/error_red_72x72.png"
             } }
          	, location.origin);
    }
    
}

$(document).ready(function() {
	 window.onerror = onErrorHandler;
    sforce.console.getPrimaryTabIds(getPrimaryTabIdsHandler);

    if (navigator.userAgent.toLowerCase().indexOf('chrome') < 0) return;

    Visualforce.remoting.timeout = 120000;

    if (typeof timetracker === 'undefined') {
        // It doesn't, so create an object with that name
        window['timetracker'] = {};

        timetracker.TimeTrackerController = TimeTrackerController;
    }
    timetracker.TimeTrackerController.getSettings(null, function(result, event) {
        const settings = JSON.parse(result);
        consoleState.Settings = settings;
        consoleState.Settings.Origin = location.origin;
        window.postMessage({ type: 'SETTINGS', body: settings }, location.origin);
        setLoggingLevel();
    }, { escape: false });

    window.addEventListener('message', onMessageReceived, false);
});

function onMessageReceived(event) {
    if (event.source != window || (event && event.origin && event.origin != location.origin) || (!event.data.type))
        return;

    switch (event.data.type) {
        case 'SAVE_TIME_TRACKER':
            pushTimeTracker(event.data.body);
            break;
        case 'NEW_RECORD_DOCUMENT_ID':
            updateFocusedSecondaryTabWithNewRecordDocumentId(event.data.body);
            break;
        case 'TRACK_LIST_NAVIGATION':
            console.log('SF Received TRACK_LIST_NAVIGATION');
            trackListNavigation();
            break;
        case 'TRACK_CHAT':
            console.log('SF Received TRACK_CHAT', event.data.body);
            trackChat(event.data.body);
            break;
        default:
            break;
    }
}

function setLoggingLevel() {
    if (!consoleState.Settings.UserSettings) return;
    const fieldName = consoleState.Settings.Namespace ?
        consoleState.Settings.Namespace + '__' + 'ClientDebugLevel__c' : 'ClientDebugLevel__c';
    const debugLevel = consoleState.Settings.UserSettings[fieldName];
    let methods = [];
    switch (debugLevel) {
        case 'INFO':
            methods = [''];
            break;
        case 'DEBUG':
            methods = ['info'];
            break;
        case 'ERROR':
            methods = ['info', 'log'];
            break;
        default:
            methods = ['info', 'log', 'error'];
        break;
    }
    if (!window.console) window.console = {};
    methods.map(function(method) {
        console[method] = function() {};
    });
}

 function isTrackingActivity(data) {
    let isTrackingActivity = false;
    const actionFieldName = getFieldName('Action__c');
    const openingActionFieldName = getFieldName('Opening_Action__c');
    const action = data[openingActionFieldName] ? data[openingActionFieldName] : data[actionFieldName];
    if(!action) {
      console.log('Not Pushing Message to SF: Action is null', data);
      return isTrackingActivity;
    }
    const typeFieldName = getFieldName('Type__c', consoleState.Settings);
    const text1FieldName = getFieldName('Text1__c', consoleState.Settings);
    const isActiveFieldName = getFieldName('IsActive__c', consoleState.Settings);
    Object.keys(consoleState.Settings.ConfigSettings).map((key, index) => {
      if(consoleState.Settings.ConfigSettings[key][typeFieldName] == "Strategy" && consoleState.Settings.ConfigSettings[key][text1FieldName] == action && consoleState.Settings.ConfigSettings[key][isActiveFieldName]) { isTrackingActivity = true; return; }
    });
    return isTrackingActivity;
  }

  function getFieldName(name){
    if(!name) return;

    return (consoleState.Settings.Namespace ? consoleState.Settings.Namespace + '__' + name : name);
  }

function pushTimeTracker(body) {
    if(!consoleState || (consoleState && !consoleState.Settings) || (consoleState && consoleState.Settings && !consoleState.Settings.ConfigSettings)) {
        setTimeout( () => { pushTimeTracker(body)}, 2000);
        return;
    }
    if(consoleState.Settings.Namespace) {
      let newData = {};
      Object.keys(body).map((key, index) => {
        newData[consoleState.Settings.Namespace + '__' + key] = body[key];
      });
      body = newData;
    }
    if(isTrackingActivity(body)) {
        console.log('Before pushing to SF', body);
        timetracker.TimeTrackerController.insertTimeTracker(JSON.stringify(body), function(result, e) {
            console.log(e);
        }, { escape: false });
    } else {
        console.log('Not Pushing Message to SF: Due to the Activity is either not active or not defined in custom settings.', body);
    }
}

function updateFocusedSecondaryTabWithNewRecordDocumentId(body) {
    const activeTab = getActiveSecondaryTab();
    activeTab.newRecordDocumentIds.push(body.DocumentId__c);
    console.log('Updated the Active Tab  New Record Document Id', consoleState.primaryTabs);
}

function trackChat(chatData) {
    const chat = getChat(chatData);
    if(chatData.type == 'CHAT_ENTER') {
        chat.activeTimestamps.push(chatData.activityTime);
    	return;
    }
   	if(chatData.type == 'CHAT_EXIT') {
        chat.inActiveTimestamps.push(chatData.activityTime);
    	return;
    }
}

const getPrimaryTabIdsHandler = function(result) {
    console.log('Primary Ids', result);
    if (!result.success) return;
    result.ids.map((id) => {
        if (!id) return;
        const pt = new PrimaryTab({ id }, onPrimaryTabsCreated);
        consoleState.primaryTabs.push(pt);
    });

    trackListNavigation();
}

const onPrimaryTabsCreated = function() {
    sforce.console.getFocusedSubtabId(getSecondaryTabIdHandler);
}

const getSecondaryTabIdHandler = function(result) {
    console.log('Secondary Id', result);
    if (!result.success || !result.id) return;

    const primaryTab = getPrimaryTabBySecondaryTabId(result);
    const secondaryTab = getSecondaryTabById(result);
    const activeSecondaryTab = getActiveSecondaryTab();
    console.log('getSecondaryTabIdHandler Primary Tab', primaryTab);
    console.log('getSecondaryTabIdHandler Secondary Tab', secondaryTab);
    if (!primaryTab || !secondaryTab || (activeSecondaryTab && secondaryTab && activeSecondaryTab.tabId == secondaryTab.tabId)) return;

    secondaryTab.active = true;
    secondaryTab.startTimer();
    primaryTab.activeSecondaryTabId = secondaryTab.tabId;

    // Get the Object Id and update the objectId on the currently active secondary tab in the consoleState.
    sforce.console.getFocusedSubtabObjectId(result => {
        if (!result.success) return;
        console.log('getFocusedSubtabObjectId===', result.id);
        secondaryTab.objectId = result.id == "null" ? null : result.id;
    });
}

const onSecondaryTabFocusedHandlerContinue = function(result) {
    sforce.console.getFocusedPrimaryTabId(primaryTabResult => {
        if (!primaryTabResult.success || !primaryTabResult.id) return;

        let primaryTab = getPrimaryTabById(primaryTabResult);
        console.log('Primary Tab on Secondary Tab Focused', primaryTab);

        // Create a new primary tab obj
        if (!primaryTab) {
            primaryTab = new PrimaryTab(primaryTabResult, onPrimaryTabsCreated);
            consoleState.primaryTabs.push(primaryTab);

            trackListNavigation();
        } else {
            // Get the secondaryTab based on the tabId from consoleState, create if does't exist: Make it active,  start the timer, set the tab as activeSecondary tab for Primary Tab and add the close tab event listener.
            let secondaryTab = getSecondaryTabById(result);
            console.log('secondaryTab===', secondaryTab);
            if (!secondaryTab) {
                secondaryTab = new SecondaryTab(result);
                primaryTab.secondaryTabs.push(secondaryTab);
                sforce.console.addEventListener(sforce.console.ConsoleEvent.CLOSE_TAB, onEnclosingSecondaryTabClose, { tabId: secondaryTab.tabId });
            }
            secondaryTab.active = true;
            secondaryTab.startTimer();
            primaryTab.activeSecondaryTabId = secondaryTab.tabId;

            // Get the Object Id and update the objectId on the currently active secondary tab in the consoleState.
            sforce.console.getFocusedSubtabObjectId(objResult => { secondaryTab.objectId = objResult.id; });
        }
    });
}

const onSecondaryTabFocusedHandler = function(result) {
    console.log('onSecondaryTabFocusedHandler ', result);
    if ((result && !result.id) || !result) return;

    // Get the active secondary from the consoleState: Make it inactive and stop the timer
    const activeSecondaryTab = getActiveSecondaryTab();
    console.log('activeSecondaryTab===', activeSecondaryTab);
    if (activeSecondaryTab && activeSecondaryTab.tabId != result.id) {
        activeSecondaryTab.active = false;
        activeSecondaryTab.stopTimer();
    }

    // Continue if the lastClosedTab is not same as the focused tab. This is special case where SF calls the onFocus method after the tab is closed.
    if (consoleState.lastClosedTab.tabId != result.id)
        onSecondaryTabFocusedHandlerContinue(result);
}

const onPrimaryTabFocusedHandler = function(result) {
    if ((result && !result.id) || !result) return;
    console.log('onPrimaryTabFocusedHandler', result);

    // Get existing primary tab
    const primaryTab = getPrimaryTabById(result);

    // New tab will not have the activeSecondaryTabId so return
    if ((primaryTab && !primaryTab.activeSecondaryTabId) || !primaryTab) return;

    // If the existing primary tab already has the activeSecondaryTabId populated
    // Get the current active tab and verify it's not the same as activeSecondaryTabId and then call the onSecondaryTabFocusedHandler method since the sfocre.onFocusedSubtab method is not executed.
    const activeTab = getActiveSecondaryTab();
    console.log('activeTab', activeTab);
    if (activeTab && activeTab.tabId && activeTab.tabId == primaryTab.activeSecondaryTabId) return;
    onSecondaryTabFocusedHandler({ id: primaryTab.activeSecondaryTabId });
}

const onSecondaryTabClosedHandler = function(result) {
    console.log('onSecondaryTabClosedHandler', result);
    const secondaryTab = getSecondaryTabById(result);
    console.log('Secondary tab Closed', secondaryTab);
    if ((secondaryTab && !secondaryTab.activeSecondaryTabId) || !secondaryTab) return;
    //secondary.createEvent();
}

const getActivePrimaryTab = function() {
    return _.find(consoleState.primaryTabs, { active: true });
}

const getActiveSecondaryTab = function() {
    return _.find(_.flatten(_.map(consoleState.primaryTabs, 'secondaryTabs')), { active: true });
}

const getSecondaryTabById = function(result) {
    return _.find(_.flatten(_.map(consoleState.primaryTabs, 'secondaryTabs')), { tabId: result.id });
}

const getPrimaryTabById = function(result) {
    return _.find(consoleState.primaryTabs, { tabId: result.id });
}

const getPrimaryTabBySecondaryTabId = function(result) {
    return _.find(consoleState.primaryTabs, _.flow(
        _.property('secondaryTabs'),
        _.partialRight(_.some, { tabId: result.id })
    ));
}

const getChat = function(data) {
    return _.find(consoleState.chats, { chatKey: data.chatKey });
}

const onChatStartHandler = function(result) {
    if(!result.success) return;
    console.log('Start Chat', result);
    const chat = new Chat({ chatKey: result.chatKey });
    consoleState.chats.push(chat);
}

const onChatEndedHandler = function(result) {
     if(!result.success) return;
     console.log('End Chat', result);
     const chat = getChat(result);
     chat.createEvent();
     _.remove(consoleState.chats, { chatKey: result.chatKey });
}

sforce.console.onFocusedSubtab(onSecondaryTabFocusedHandler);

sforce.console.onFocusedPrimaryTab(onPrimaryTabFocusedHandler);

// Chat Start Event
sforce.console.chat.onChatStarted(onChatStartHandler);

// Chat End Event
sforce.console.chat.onChatEnded(onChatEndedHandler);
