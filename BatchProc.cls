global class BatchProc implements Database.Batchable<sObject>{
    
    public String BatchQuery;
    public String ObjectType;
    public String ObjectName;
    
    public BatchProc(String query,String objType,String objName)
    {
        BatchQuery = query;
        ObjectType = objType;
        ObjectName = objName;
    }

     global Database.QueryLocator start(Database.BatchableContext BC)
     {
         return Database.getQueryLocator(BatchQuery);
     }
    global void execute(Database.BatchableContext BC,List<sObject> scope)
    {
        system.debug(' Inside execute of the batch : --->' + ObjectType);
        try
        {
            if(ObjectType.endsWithIgnoreCase('Attachment'))
            {
                
                List <NotesnAttachment__c> lstNotesnAttach = new list<NotesnAttachment__c>();
                
                for(Sobject s : scope)
                {
                    attachment a = (attachment)s; 
                    NotesnAttachment__c NnA = new NotesnAttachment__c(AttachOrNoteType__c = ObjectType,BodyLength__c = a.BodyLength,ContentType__c = a.ContentType,CreatedById__c = a.CreatedById,Created_Date__c = a.CreatedDate,Description__c = a.Description,IsPartnerShared__c = a.IsPartnerShared,IsPrivate__c = a.IsPrivate,Last_Modified_By__c = a.LastModifiedById,	Last_Modified_Date__c = a.LastModifiedDate,Object_Type__c = ObjectName,OwnerId__c = a.OwnerId,Parent_Id__c = a.ParentId,RecordId__c = a.Id,TitleOrName__c = a.Name);
                	lstNotesnAttach.add(NnA);
                }
                insert lstNotesnAttach;
            }
            else if(ObjectType.endsWithIgnoreCase('Note'))
            {
                List <NotesnAttachment__c> lstNotesnAttach = new list<NotesnAttachment__c>();
                
                for(Sobject s : scope)
                {
                    note n = (note)s; 
                    NotesnAttachment__c NnA = new NotesnAttachment__c(AttachOrNoteType__c = ObjectType,CreatedById__c = n.CreatedById,Created_Date__c = n.CreatedDate,IsPrivate__c = n.IsPrivate,Last_Modified_By__c = n.LastModifiedById,	Last_Modified_Date__c = n.LastModifiedDate,Object_Type__c = ObjectName,OwnerId__c = n.OwnerId,Parent_Id__c = n.ParentId,RecordId__c = n.Id,TitleOrName__c = n.Title);
                    lstNotesnAttach.add(NnA);
                }
                insert lstNotesnAttach;
            }
        }
        catch(queryException qe)
        {
            System.debug(' Query exceeded 50,000 rows!!! ');
        }
        
        //Delete lstAccount; 
    }
    global void finish(Database.BatchableContext BC)
    {
        String UserEmail = UserInfo.getUserEmail();
        String UserId = UserInfo.getUserId();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {UserEmail};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Apex Batch Job is done');
        mail.setPlainTextBody('The batch Apex job processed');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        list<notesnattachbatch__c> NnAb = [Select id from notesnattachbatch__c where CreatedById =: UserId];
        if(NnAb.size() > 0)
        delete NnAb;        
    }

}