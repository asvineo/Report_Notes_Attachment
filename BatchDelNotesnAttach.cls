global class BatchDelNotesnAttach implements Database.Batchable<sObject>{
    
    public String BatchQuery;
    public String ObjectType;
    public String ObjectName;
    public String BatchDelQuery;
    
    public BatchDelNotesnAttach(String query,String objType,String objName)
    {
        BatchQuery = query;
        ObjectType = objType;
        ObjectName = objName;
        String UserId = UserInfo.getUserId();
        BatchDelQuery = 'select id from NotesnAttachment__c where CreatedById = \'' + UserId + '\'';
    }

     global Database.QueryLocator start(Database.BatchableContext BC)
     {
         return Database.getQueryLocator(BatchDelQuery);
     }
    global void execute(Database.BatchableContext BC,List<sObject> scope)
    {
        system.debug(' Inside execute of the batch : --->' + ObjectType);
        
        try
        {
            if(!scope.isEmpty())
                delete scope;
            DataBase.emptyRecycleBin(scope);
        }
        catch(queryException qe)
        {
            System.debug(' Query exceeded 50,000 rows!!! ');
        }
        
    }
    global void finish(Database.BatchableContext BC)
    {
        String UserEmail = UserInfo.getUserEmail();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {UserEmail};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Apex Batch Job to Delete NotesnAttachment is done');
        mail.setPlainTextBody('The batch Apex job processed');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        String batchId = database.executeBatch(new BatchProc(BatchQuery,ObjectType,ObjectName));
        NotesnAttachBatch__c NnAb = new NotesnAttachBatch__c(BatchId__c = batchId,BatchStatus__c = 'started');
        insert NnAb;
        
    }

}