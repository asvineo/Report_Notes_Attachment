public class ReportNotesExt{
    
Public String SelectedObject{get;set;}
    public String sSelecetdObjName {get;set;}
    public String sSelectedType {get;set;}
    public String SelectedType {get;set;}
    public boolean DeleteFirst {get;set;}
    public String sSelDate{get;set;}

    public List<Attachment> AttachmentTable;
    public List<Note> NoteTable;
    public List<Attachment> CompAttachList = new List <Attachment>();
    
    public boolean showAttachTable {get;set;}
    public boolean showNoteTable {get;set;}
    
    public boolean showArrows {get;set;}
    
    public Date CreateDate {get;set;}
    
    public integer Attachcount {get;set;}
    public integer Notecount {get;set;}
    
    public static NotesnAttachment__c NnA;
    
    public String BQuery;
    public String dateTimeFilterGT;
    
    public String selectedCriteria {get;set;}
    
    private integer counter;  //keeps track of the offset
        private integer list_size=20; //sets the page size or number of rows
        public integer total_size; //used to show user the total size of the list
    public integer iterate;
    
    public List<SelectOption> getSelObject() 
    {
        Map<String, ObjectsToSelect__c> ObjSel_CS = ObjectsToSelect__c.getAll();
        List<SelectOption> objToSel = new List<SelectOption>();
                List<String> SelObjectList = new List<String>();
        for(ObjectsToSelect__c ObjSelLoop : ObjSel_CS.values())
            SelObjectList.add(ObjSelLoop.Object_Name__c);
		List<Schema.SObjectType> allObjects = Schema.getGlobalDescribe().Values();
        
		objToSel.add(new SelectOption('None','None'));
        for(String SelObjectLoop : SelObjectList)
        {
            //objToSel.add(new SelectOption(SelObjectLoop,SelObjectLoop));
			for(Schema.SObjectType objName: allObjects){
                system.debug('--- Object Name is '+ objName.getDescribe().getName());

                if(SelObjectLoop == objName.getDescribe().getLabel()){
                    //objToSel.add(new SelectOption(SelObjectLoop,SelObjectLoop));
                    objToSel.add(new SelectOption(objName.getDescribe().getName(),objName.getDescribe().getName()));
                }
            }
        }
        return objToSel ;
    }
    
    public List<SelectOption> GetSelectType()
    {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('Note','Note')); 
        options.add(new SelectOption('Attachment','Attachment')); 
        return options; 
    }
    
    public pagereference GetSelectedListValue()
    {
        showNoteTable = false;
        showAttachTable = false;
        system.debug('The object selected is : ' + this.sSelecetdObjName);
        system.debug('The Type selected is : ' + this.sSelectedType);
        system.debug('The Delete flag is : ' + DeleteFirst);
        system.debug('The Selected date is : ' + this.sSelDate);
        if(this.sSelecetdObjName.equals('')||this.sSelecetdObjName.equals('None') || this.sSelectedType <> null)
        {
            Apexpages.Message Msg = new ApexPages.Message(Apexpages.severity.ERROR,'Please select an object to continue...');
            Apexpages.addMessage(Msg);
            return null;
        }
        if(this.sSelectedType.equalsIgnoreCase('note'))
        {
                showNoteTable = true;
            showAttachTable = false;
        }
        else if(this.sSelectedType.equalsIgnoreCase('Attachment'))
        {
            showAttachTable = true;
            showNoteTable = false;
        }
        if(this.sSelDate <> null)
        {
          CreateDate = Date.parse(this.sSelDate);
            dateTimeFilterGT = GetFormattedDate(CreateDate);
        }
        total_size = GetCount(this.sSelectedType,this.sSelecetdObjName,CreateDate);
        if(total_size > 2000)
            total_size = 2000;
        system.debug(' The total size is : ' + total_size);
        showArrows = true;
        counter = 0;
        return null;
    }
    
    public List<Attachment> GetAttachmentTable()
    {
        string SQL;
        AttachmentTable = new List<Attachment>();
        try
        {    
                        if(dateTimeFilterGT <> null)
            {
                 SQL = 'select Parent.Type,BodyLength,ContentType,CreatedById,CreatedDate,Description,Id,IsPartnerShared,IsPrivate,LastModifiedById,LastModifiedDate,Name,OwnerId,ParentId from Attachment where Parent.Type =  \'' +  this.sSelecetdObjName + '\' and day_only(CreatedDate) '+ selectedCriteria  + ' ' + dateTimeFilterGT + ' order by CreatedDate limit '+ list_size + ' OFFSET '+ counter;
                 AttachmentTable = database.query(SQL);
                 system.debug('------ SOQL query is '+ SQL);
             }
            else
            {
                SQL = 'select Parent.Type,BodyLength,ContentType,CreatedById,CreatedDate,Description,Id,IsPartnerShared,IsPrivate,LastModifiedById,LastModifiedDate,Name,OwnerId,ParentId from Attachment where Parent.Type =  \'' +  this.sSelecetdObjName + '\' order by CreatedDate limit '+ list_size + ' OFFSET '+ counter;
                AttachmentTable = database.query(SQL); 
            }
        
        }
        catch(QueryException e)
        {
            Apexpages.Message Msg = new ApexPages.Message(Apexpages.severity.ERROR,'More than 2000 records...');
            Apexpages.addMessage(Msg);
            
        }
        return AttachmentTable; 
    }
    public List<Note> GetNoteTable()
    {
        string SQL;
        NoteTable = new List<Note>();
        try
        {    
                        if(dateTimeFilterGT <> null)
            {
                 SQL = 'select Parent.Type,Body,CreatedById,CreatedDate,Id,IsPrivate,LastModifiedById,LastModifiedDate,OwnerId,ParentId,Title from Note where Parent.Type =  \'' +  this.sSelecetdObjName + '\' and day_only(CreatedDate) '+ selectedCriteria  + ' ' + dateTimeFilterGT + ' order by CreatedDate limit '+ list_size + ' OFFSET '+ counter;
                 NoteTable = database.query(SQL);
                 system.debug('------ SOQL query is '+ SQL);
             }
            else
            {
                SQL = 'select Parent.Type,Body,CreatedById,CreatedDate,Id,IsPrivate,LastModifiedById,LastModifiedDate,OwnerId,ParentId,Title from Note where Parent.Type =  \'' +  this.sSelecetdObjName + '\' order by CreatedDate limit '+ list_size + ' OFFSET '+ counter;
                NoteTable = database.query(SQL); 
            }
        
        }
        catch(QueryException e)
        {
            Apexpages.Message Msg = new ApexPages.Message(Apexpages.severity.ERROR,'More than 2000 records...');
            Apexpages.addMessage(Msg);
            
        }
        return NoteTable;
    }
 
   public PageReference Previous() 
   {
      counter -= list_size;
       System.debug('The counter size in Previous is: ' + counter);
      return null;
   }
 
   public PageReference Next() 
   { 
      counter += list_size;
       System.debug('The counter size in Next is: ' + counter);
      return null;
   }
    public PageReference First() 
    { 
        counter = 0;
        return null;
        }
 
        public PageReference Last() 
    { //user clicked end
      counter = total_size - math.mod(total_size, list_size);
        system.debug('The Last value is : ' + counter);
      return null;
   }
 
   public Boolean getDisablePrevious() 
   { 
                if (counter>0) return false; else return true;
   }
 
   public Boolean getDisableNext() 
   { 
      System.debug(' The total size in disable next is : ' + total_size);
      System.debug(' The counter size in disable next is : ' + counter);
        if ((counter < total_size) && (total_size > list_size)) 
           return false; 
       else return true;
   }
   
    public Integer getTotal_size() 
    {
      return total_size;
    }
 
   public Integer getPageNumber() 
   {
       if(counter ==0)
           return 1;
       else if ((counter == total_size) || ((counter+list_Size) == total_size))
           return counter/list_size;
       else 
           return counter/list_size + 1;
   }
 
   public Integer getTotalPages() 
   {
      if (math.mod(total_size, list_size) > 0) 
      {
         System.debug('The Total Pages are: ' + (total_size/list_size + 1));
         return total_size/list_size + 1;
      } else 
      {
         System.debug('The Total Pages are: ' + (total_size/list_size));
         return (total_size/list_size);
      }
   }
    
    public void PushSelectedListValue()
    {
        String UserId = UserInfo.getUserId();
        List<NotesnAttachBatch__c> CheckNotesnAttachBatch = [select BatchId__c from NotesnAttachBatch__c where createdbyid =: UserId];
        
        if(CheckNotesnAttachBatch.size() > 0)
        {
                Apexpages.Message Msg = new ApexPages.Message(Apexpages.severity.ERROR,'A batch is being processed already');
            Apexpages.addMessage(Msg);
        }
        else
        {
        
            if(CreateDate <> null)
            {
                dateTimeFilterGT = GetFormattedDate(CreateDate);
            }
            System.debug('The created date inside getNotesAttachQuery is: ' + dateTimeFilterGT);
            BQuery = getNotesAttachQuery(this.sSelectedType,this.sSelecetdObjName);
            if(DeleteFirst == true)
            {
                String batchId = database.executeBatch(new BatchDelNotesnAttach(BQuery,this.sSelectedType,this.sSelecetdObjName));
                NotesnAttachBatch__c NnAb = new NotesnAttachBatch__c(BatchId__c = batchId,BatchStatus__c = 'started');
                insert NnAb;
            }
            else if(DeleteFirst == false)
            {
                String batchId = database.executeBatch(new BatchProc(BQuery,this.sSelectedType,this.sSelecetdObjName));
                NotesnAttachBatch__c NnAb = new NotesnAttachBatch__c(BatchId__c = batchId,BatchStatus__c = 'started');
                insert NnAb;
            }
        }
    }
    
    public String getNotesAttachQuery(String ObjectType,String SelObjName)
    {
        String NnAQuery;
        if(dateTimeFilterGT <> null)
        {
            if(ObjectType.equalsIgnoreCase('Attachment'))
            {
                NnAQuery = 'select Parent.Type,Body,BodyLength,ContentType,CreatedById,CreatedDate,Description,Id,IsPartnerShared,IsPrivate,LastModifiedById,LastModifiedDate,Name,OwnerId,ParentId from Attachment where Parent.Type =  \'' +  SelObjName + '\' and day_only(CreatedDate) '+ selectedCriteria  + ' ' + dateTimeFilterGT + ' order by CreatedDate';
            }
            else if(ObjectType.equalsIgnoreCase('Note'))
            {
                NnAQuery = 'select Parent.Type,Body,CreatedById,CreatedDate,Id,IsPrivate,LastModifiedById,LastModifiedDate,OwnerId,ParentId,Title from Note where Parent.Type =  \'' +  SelObjName + '\' and day_only(CreatedDate) '+ selectedCriteria  + ' ' + dateTimeFilterGT + ' order by CreatedDate';
                
            }
        }
        else
        {
            if(ObjectType.equalsIgnoreCase('Attachment'))
            {
                NnAQuery = 'select Parent.Type,Body,BodyLength,ContentType,CreatedById,CreatedDate,Description,Id,IsPartnerShared,IsPrivate,LastModifiedById,LastModifiedDate,Name,OwnerId,ParentId from Attachment where Parent.Type = \'' + SelObjName + '\' order by CreatedDate';
            }
            else if(ObjectType.equalsIgnoreCase('Note'))
            {
                NnAQuery = 'select Parent.Type,Body,CreatedById,CreatedDate,Id,IsPrivate,LastModifiedById,LastModifiedDate,OwnerId,ParentId,Title from Note where Parent.Type = \'' + SelObjName + '\' order by CreatedDate';
            }
        }
        return NnAQuery;
    }
    public Integer GetCount(String ObjectType,String SelObjName,datetime crdate)
    {
        Integer Count=0;
        String SQL;
        if(ObjectType.equalsIgnoreCase('Attachment'))
        {
                if(crdate <> null)
                {
                SQL = 'select count() from Attachment where Parent.Type = \'' + SelObjName + '\' and day_only(CreatedDate) '+ selectedCriteria  + ' ' + dateTimeFilterGT + ' limit 20000';
            }
            else
            {
                SQL = 'select count() from Attachment where Parent.Type = \'' + SelObjName + '\' limit 20000';
            }
            System.debug('The Count query is : '+SQL);
            count = database.countQuery(SQL);
        }
        else if(ObjectType.equalsIgnoreCase('Note'))
        {
                if(crdate <> null)
                {
                SQL = 'select count() from Note where Parent.Type = \'' + SelObjName + '\' and day_only(CreatedDate) '+ selectedCriteria  + ' ' + dateTimeFilterGT + ' limit 20000';
            }
            else
            {
                SQL = 'select count() from Note where Parent.Type = \'' + SelObjName + '\' limit 20000';
            }
            System.debug('The Count query is : '+SQL);
            count = database.countQuery(SQL);
        }
        return count;
    }
    public String GetFormattedDate(DateTime CreatedDate)
    {
        String FormattedDate;
                    Datetime dt1 = CreatedDate.addDays(1);
        system.debug('+++dt 1 is '+ dt1);
        FormattedDate  = dt1.format('yyyy-MM-dd');
        system.debug('+++dateTimeFilterGT is '+ FormattedDate);
        return FormattedDate;
    }
 }