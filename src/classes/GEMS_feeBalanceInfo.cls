public without sharing class GEMS_feeBalanceInfo {
	
	
	public list<studentBalanceWrapper> getStudentBalance(string studentId, string dateParam){
		
		try{
			map<string,list<studentBalanceWrapper>> mapToReturn = new map<string,list<studentBalanceWrapper>>();
			GEMS_FeeDetailService.BasicHttpBinding_IFEE_DETAILS studentBalance = new GEMS_FeeDetailService.BasicHttpBinding_IFEE_DETAILS();
			string GET_STUDENT_FEE_OUTSTANDINGResult = '';
				
			if(string.isNotBlank(studentId)){
				string dateToPass = '';
				if(string.isNotBlank(dateParam)){
					dateToPass = dateParam; 
				}else{
					dateToPass = system.now().format('d/MMM/YYYY');	
				}
				GET_STUDENT_FEE_OUTSTANDINGResult = studentBalance.GET_STUDENT_FEE_OUTSTANDING(studentId,dateToPass);
			}
			
			list<studentBalanceWrapper> studentBalanceList = new list<studentBalanceWrapper>();
	        if(string.isNotBlank(GET_STUDENT_FEE_OUTSTANDINGResult)){
		    	studentBalanceList = parseElementNames(GET_STUDENT_FEE_OUTSTANDINGResult);
	        }
	        
	        if(studentBalanceList!=null && studentBalanceList.size()>0){
	        	return studentBalanceList;	
	        }   
		}catch(exception ex){
				
		}
		return null;
	}
	
	private list<studentBalanceWrapper> parseElementNames(String retVal) {
	    list<studentBalanceWrapper> elements = new list<studentBalanceWrapper>();
	    Dom.Document doc = new Dom.Document();
	    doc.load(retVal);
	    Dom.XmlNode root = doc.getRootElement();
	    for(Dom.XmlNode objTable : root.getChildElements()){
	        studentBalanceWrapper obj = new studentBalanceWrapper();
	        for(Dom.XmlNode temp : objTable.getChildElements()){
	            if(temp.getName() == 'STUDENTID'){
	            	obj.studentId = temp.getText();	    
	            }
	            if(temp.getName() == 'ASON_DATE'){
	            	obj.dateParam = temp.getText();	    
	            }
	            if(temp.getName() == 'FEE_TYPE'){
	            	obj.feeType = temp.getText();	    
	            }
	            if(temp.getName() == 'FEE_DUE'){
	            	obj.amount = temp.getText();	    
	            }
	    	}
	        elements.add(obj);
	    }
	    return elements;
	}

	
	public class studentBalanceWrapper{
	
		public string studentId {get; set;}
		public string dateParam {get; set;}
		public string feeType {get; set;}
		public string amount {get; set;}
		
		public studentBalanceWrapper(){
			studentId = '';
			dateParam = '';
			feeType = '';
			amount = '';
			
		}
	}
	
}