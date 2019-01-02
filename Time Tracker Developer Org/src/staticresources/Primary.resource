class PrimaryTab {
    constructor(result, callback) {
        this.tabId = result && result.id ? result.id : null;
        this.objectId = result && result.objectId ? result.objectId : null;
        this.activeSecondaryTabId = null;
        this.secondaryTabs = [];

        this.getSecondaryTabs(callback);
    }

    // Loop thru the all the Subtabs for the primary tab and create instances on the Secondary tabs and then update the secondaryTabs property
    getSecondaryTabs(callback) {
        sforce.console.getSubtabIds(this.tabId, result => {
            console.log('getSecondaryTabs', result)
            if (!result.success) return;
            result.ids.map((id) => {
                const st = new SecondaryTab({ id });
                this.secondaryTabs.push(st);
                sforce.console.addEventListener(sforce.console.ConsoleEvent.CLOSE_TAB
                                    , onEnclosingSecondaryTabClose, { tabId : id });
            callback();
            });
        });
    }
}

function onEnclosingSecondaryTabClose(result) {
    console.log('onEnclosingSecondaryTabClose', result);
    const primaryTab = getPrimaryTabBySecondaryTabId(result);
    const secondaryTab = getSecondaryTabById(result);
    secondaryTab.objectId = result.objectId == "null" ? null : result.objectId;
    secondaryTab.createEvent();
    consoleState.lastClosedTab = { tabId: result.id, objectId: secondaryTab.objectId };
    _.remove(primaryTab.secondaryTabs, { tabId: secondaryTab.tabId });

    if(primaryTab.secondaryTabs.length == 0) {
        _.remove(consoleState.primaryTabs, { tabId: primaryTab.tabId });
    }

    trackListNavigation();
}
