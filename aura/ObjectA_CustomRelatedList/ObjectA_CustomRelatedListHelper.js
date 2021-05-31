({
    //Define collumns and actions available for each record
    getColumnAndAction : function(component) {
        var actions = [
            {label: 'Edit', name: 'edit'},
            {label: 'View', name: 'view'}
        ];
        component.set('v.columns', [
            {label: 'Name', fieldName: 'Name', type: 'text'},
            {type: 'action', typeAttributes: { rowActions: actions } } 
        ]);
    },
    
    //Method responsible to retrieve from BE all records related to the parent (ObjectA)
    getRecords : function(component, helper, actionButton) {
        var action = component.get("c.getRecords");
        var pageSize = component.get("v.pageSize").toString();
        var pageNumber = component.get("v.pageNumber").toString();
        var recordId = component.get("v.recordId");
        let data = component.get("v.data");
        var lastRecordName = '';
        var firstRecordName = '';
        
        if (data != null) {
        	lastRecordName = data[data.length-1].Name;
			firstRecordName = data[0].Name;
        }
         
        action.setParams({
            'pageSize' 		 : pageSize,
            'recordObjAId'	 : recordId,
            'firstRecordName': firstRecordName,
            'lastRecordName' : lastRecordName,
            'action'		 : actionButton
        });
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var responseMap = JSON.parse(response.getReturnValue());
                //Check if we have more pages to show - in case of listOfRecords.length be lesser than pageSize, isLastPage should be true - button next is enable
                if(responseMap.listOfRecords.length < component.get("v.pageSize") || (responseMap.dataSize == pageSize)){
                    component.set("v.isLastPage", true);
                } else{
                    component.set("v.isLastPage", false);
                }
                component.set("v.dataSize", responseMap.listOfRecords.length);
                component.set("v.totalNumberRecords", responseMap.dataSize)
                component.set("v.data", responseMap.listOfRecords);
            }
        });
        $A.enqueueAction(action);
    },
    
    //Methods used to navigate to the selected record
    viewRecord : function(component, event) {
        var row = event.getParam('row');
        var recordId = row.Id;
        var navEvt = $A.get("event.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recordId,
            "slideDevName": "detail"
        });
        navEvt.fire();
    },

    //Method used to edit selected record
    editRecord : function(component, event) {
        var row = event.getParam('row');
        var recordId = row.Id;
        var editRecordEvent = $A.get("e.force:editRecord");
        editRecordEvent.setParams({
            "recordId": recordId
        });
        editRecordEvent.fire();
    }   
})