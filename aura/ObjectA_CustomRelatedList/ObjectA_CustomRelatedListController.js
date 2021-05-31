({
    doInit : function(component, event, helper) {        
        helper.getColumnAndAction(component);
        var action = component.get("c.getPageSize");
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.pageSize",response.getReturnValue());
            }
            //In case of error, the pageSize will keep the default value define in cmp attribute
            //The process should now proceeed and the records should be loaded
            helper.getRecords(component, helper);
        });
        $A.enqueueAction(action);
    },
     
    handleNext : function(component, event, helper) { 
        var pageNumber = component.get("v.pageNumber");
        component.set("v.pageNumber", pageNumber+1);
        helper.getRecords(component, helper, event.getSource().getLocalId());
    },
     
    handlePrev : function(component, event, helper) {        
        var pageNumber = component.get("v.pageNumber");
        component.set("v.pageNumber", pageNumber-1);
        helper.getRecords(component, helper, event.getSource().getLocalId());
    },
 
    handleRowAction: function (component, event, helper) {
        var action = event.getParam('action');
        switch (action.name) {
            case 'edit':
                helper.editRecord(component, event);
                break;
            case 'delete':
                helper.deleteRecord(component, event);
                break;
            case 'view':
                helper.viewRecord(component, event);
                break;
        }
    }
})