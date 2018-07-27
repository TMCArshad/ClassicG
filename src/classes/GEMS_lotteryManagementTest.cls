@IsTest
private class GEMS_lotteryManagementTest {
    
	static testMethod void GEMS_lotteryManagementTest1(){
    	HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Submitted');
    	
    	HexaBPM__Service_Request__c objSR = new HexaBPM__Service_Request__c();
    	objSR = GEMS_TestUtils.createSR('Enrollment');
    	
    	objSR = [select id, HexaBPM__Internal_SR_Status__c, HexaBPM__External_SR_Status__c,Lottery_Management__c,
    					HexaBPM__Record_Type_Name__c,Academic_Year__c, gradeLookup__c,School__c
				 from HexaBPM__Service_Request__c 
				 where id=:objSR.id];
    	
    	objSR.HexaBPM__Internal_SR_Status__c = srStatus.id;
        objSR.HexaBPM__External_SR_Status__c = srStatus.id;
        update objSR;
        
        Lottery_Management__c objLotTemp = new Lottery_Management__c();
    	objLotTemp.Academic_Year__c = objSR.Academic_Year__c;
    	objLotTemp.Gender__c = 'All';
    	objLotTemp.Grade__c = objSR.gradeLookup__c;
    	objLotTemp.Lot_Allocation__c = 'All'; 
    	objLotTemp.Lot_Capacity__c = 1;
    	objLotTemp.Lot_Number__c = 1;
    	objLotTemp.Lottery_Date__c = system.today();
    	objLotTemp.Lottery_Type__c = 'Short List';
    	objLotTemp.School__c = objSR.School__c;
    	objLotTemp.Stage__c = srStatus.id;
    	insert objLotTemp;
    	    	
    	Test.setCurrentPageReference(new PageReference('Page.GEMS_lotteryManagement'));
    	System.currentPageReference().getParameters().put('schoolId', objSR.School__c);
    	GEMS_lotteryManagementCtlr lotCtlr = new GEMS_lotteryManagementCtlr();  
    	lotCtlr.objLot = new Lottery_Management__c();
    	lotCtlr.objLot.Gender__c = 'All';
    	lotCtlr.objLot.Lot_Allocation__c = 'All';
    	lotCtlr.objLot.Lot_Capacity__c = 1;
    	lotCtlr.objLot.Lottery_Date__c = system.today();
    	lotCtlr.objLot.Academic_Year__c = objSR.Academic_Year__c;
    	lotCtlr.objLot.Grade__c = objSR.gradeLookup__c;
    	lotCtlr.objLot.School__c = objSR.School__c;
    	
    	lotCtlr.stage = srStatus.id;
    	
    	lotCtlr.generateLot();
    	
    	lotCtlr.saveLot();
    	lotCtlr.cancelLot();
    	
    	lotCtlr.objLot.Gender__c = 'Female';
    	lotCtlr.generateLot();
    	
    	lotCtlr.objLot.Lot_Allocation__c = 'Sibling Same School';
    	lotCtlr.generateLot();
    	
    	lotCtlr.objLot.Lot_Allocation__c = 'Sibling All School';
    	lotCtlr.generateLot();
    	
    	lotCtlr.objLot.Lot_Allocation__c = 'General Public';
    	lotCtlr.generateLot();
    	
    	lotCtlr.stage = 'Waitlist';
    	lotCtlr.generateLot();
    }
    
    static testMethod void GEMS_lotteryManagementTest2(){
    	school__c objSchool = GEMS_TestUtils.createSchool();
    	academic_year__c objAY = GEMS_TestUtils.createAcademicYear(objSchool);
    	grade__c objGrade = GEMS_TestUtils.createGrade(objSchool,objAY);
    	HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Submitted');
        
        list<Lottery_Management__c> lotList = new list<Lottery_Management__c>();
        Lottery_Management__c objLotTemp = new Lottery_Management__c();
    	objLotTemp.Academic_Year__c = objAY.id;
    	objLotTemp.Gender__c = 'All';
    	objLotTemp.Grade__c = objGrade.id;
    	objLotTemp.Lot_Allocation__c = 'All'; 
    	objLotTemp.Lot_Capacity__c = 50;
    	objLotTemp.Lot_Number__c = 1;
    	objLotTemp.Lottery_Date__c = system.today();
    	objLotTemp.Lottery_Type__c = 'Short List';
    	objLotTemp.School__c = objSchool.id;
    	objLotTemp.Stage__c = srStatus.id;
    	lotList.add(objLotTemp);
    	
    	Lottery_Management__c objLotTemp1 = new Lottery_Management__c();
    	objLotTemp1.Academic_Year__c = objAY.id;
    	objLotTemp1.Gender__c = 'All';
    	objLotTemp1.Grade__c = objGrade.id;
    	objLotTemp1.Lot_Allocation__c = 'All'; 
    	objLotTemp1.Lot_Capacity__c = 50;
    	objLotTemp1.Lot_Number__c = 1;
    	objLotTemp1.Lottery_Date__c = system.today();
    	objLotTemp1.Lottery_Type__c = 'Short List';
    	objLotTemp1.School__c = objSchool.id;
    	objLotTemp1.Stage__c = srStatus.id;
    	lotList.add(objLotTemp1);
    	
    	insert lotList;
    	    	
    	Test.setCurrentPageReference(new PageReference('Page.GEMS_lotteryManagement'));
    	System.currentPageReference().getParameters().put('schoolId', objSchool.id);
    	GEMS_lotteryManagementCtlr lotCtlr = new GEMS_lotteryManagementCtlr();  
    	lotCtlr.objLot = new Lottery_Management__c();
    	
    	
    	lotCtlr.deleteLot = objLotTemp.id;
    	lotCtlr.deleteLot();
    	
    	lotCtlr.generateLot();
    }
    
    static testMethod void GEMS_lotteryManagementTest3(){
    	school__c objSchool = GEMS_TestUtils.createSchool();
    	academic_year__c objAY = GEMS_TestUtils.createAcademicYear(objSchool);
    	grade__c objGrade = GEMS_TestUtils.createGrade(objSchool,objAY);
        HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Submitted');
        
    	Test.setCurrentPageReference(new PageReference('Page.GEMS_lotteryManagement'));
    	System.currentPageReference().getParameters().put('schoolId', objSchool.id);
    	GEMS_lotteryManagementCtlr lotCtlr = new GEMS_lotteryManagementCtlr();  
    	lotCtlr.objLot = new Lottery_Management__c();
    	lotCtlr.objLot.Lot_Capacity__c = 1;
    	lotCtlr.objLot.Lottery_Date__c = system.today();
    	lotCtlr.objLot.Academic_Year__c = objAY.id;
    	lotCtlr.objLot.Grade__c = objGrade.id;
    	lotCtlr.objLot.School__c = objSchool.id;
    	lotCtlr.objLot.Lot_Allocation__c = 'All';
    	lotCtlr.objLot.Gender__c = 'Female';
    	lotCtlr.stage = srStatus.id;
    	lotCtlr.generateLot();
    }
    
    static testMethod void GEMS_lotteryManagementTest4(){
    	school__c objSchool = GEMS_TestUtils.createSchool();
    	academic_year__c objAY = GEMS_TestUtils.createAcademicYear(objSchool);
    	grade__c objGrade = GEMS_TestUtils.createGrade(objSchool,objAY);
        HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Submitted');
        
    	Test.setCurrentPageReference(new PageReference('Page.GEMS_lotteryManagement'));
    	System.currentPageReference().getParameters().put('schoolId', objSchool.id);
    	GEMS_lotteryManagementCtlr lotCtlr = new GEMS_lotteryManagementCtlr();  
    	lotCtlr.objLot = new Lottery_Management__c();
    	lotCtlr.objLot.Lot_Capacity__c = 1;
    	lotCtlr.objLot.Lottery_Date__c = system.today();
    	lotCtlr.objLot.Academic_Year__c = objAY.id;
    	lotCtlr.objLot.Grade__c = objGrade.id;
    	lotCtlr.objLot.School__c = objSchool.id;
    	lotCtlr.objLot.Gender__c = 'All';
    	lotCtlr.objLot.Lot_Allocation__c = 'Sibling Same School';
    	lotCtlr.stage = srStatus.id;
    	lotCtlr.generateLot();
    	
    }
    
    static testMethod void GEMS_lotteryManagementTest5(){
    	school__c objSchool = GEMS_TestUtils.createSchool();
    	academic_year__c objAY = GEMS_TestUtils.createAcademicYear(objSchool);
    	grade__c objGrade = GEMS_TestUtils.createGrade(objSchool,objAY);
        HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Submitted');
        
    	Test.setCurrentPageReference(new PageReference('Page.GEMS_lotteryManagement'));
    	System.currentPageReference().getParameters().put('schoolId', objSchool.id);
    	GEMS_lotteryManagementCtlr lotCtlr = new GEMS_lotteryManagementCtlr();  
    	lotCtlr.objLot = new Lottery_Management__c();
    	lotCtlr.objLot.Lot_Capacity__c = 1;
    	lotCtlr.objLot.Lottery_Date__c = system.today();
    	lotCtlr.objLot.Academic_Year__c = objAY.id;
    	lotCtlr.objLot.Grade__c = objGrade.id;
    	lotCtlr.objLot.School__c = objSchool.id;
    	lotCtlr.objLot.Gender__c = 'All';
    	lotCtlr.objLot.Lot_Allocation__c = 'Sibling All School';
    	lotCtlr.stage = srStatus.id;
    	lotCtlr.generateLot();
    }
    
    static testMethod void GEMS_lotteryManagementTest6(){
    	school__c objSchool = GEMS_TestUtils.createSchool();
    	academic_year__c objAY = GEMS_TestUtils.createAcademicYear(objSchool);
    	grade__c objGrade = GEMS_TestUtils.createGrade(objSchool,objAY);
        HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Submitted');
        
    	Test.setCurrentPageReference(new PageReference('Page.GEMS_lotteryManagement'));
    	System.currentPageReference().getParameters().put('schoolId', objSchool.id);
    	GEMS_lotteryManagementCtlr lotCtlr = new GEMS_lotteryManagementCtlr();  
    	lotCtlr.objLot = new Lottery_Management__c();
    	lotCtlr.objLot.Lot_Capacity__c = 1;
    	lotCtlr.objLot.Lottery_Date__c = system.today();
    	lotCtlr.objLot.Academic_Year__c = objAY.id;
    	lotCtlr.objLot.Grade__c = objGrade.id;
    	lotCtlr.objLot.School__c = objSchool.id;
    	lotCtlr.objLot.Gender__c = 'All';
    	lotCtlr.objLot.Lot_Allocation__c = 'General Public';
    	lotCtlr.stage = srStatus.id;
    	lotCtlr.generateLot();
    }
    
    static testMethod void GEMS_lotteryManagementTest7(){
    	school__c objSchool = GEMS_TestUtils.createSchool();
    	academic_year__c objAY = GEMS_TestUtils.createAcademicYear(objSchool);
    	grade__c objGrade = GEMS_TestUtils.createGrade(objSchool,objAY);
        
    	Test.setCurrentPageReference(new PageReference('Page.GEMS_lotteryManagement'));
    	System.currentPageReference().getParameters().put('schoolId', objSchool.id);
    	GEMS_lotteryManagementCtlr lotCtlr = new GEMS_lotteryManagementCtlr();  
    	lotCtlr.objLot = new Lottery_Management__c();
    	lotCtlr.objLot.Lot_Capacity__c = 1;
    	lotCtlr.objLot.Lottery_Date__c = system.today();
    	lotCtlr.objLot.Academic_Year__c = objAY.id;
    	lotCtlr.objLot.Grade__c = objGrade.id;
    	lotCtlr.objLot.School__c = objSchool.id;
        lotCtlr.objLot.Gender__c = 'All';
        lotCtlr.objLot.Lot_Allocation__c = 'General Public';
    	lotCtlr.stage = 'Waitlist';
    	lotCtlr.generateLot();
    }
    
    static testMethod void GEMS_lotteryManagementTest8(){
    	school__c objSchool = GEMS_TestUtils.createSchool();
    	academic_year__c objAY = GEMS_TestUtils.createAcademicYear(objSchool);
    	grade__c objGrade = GEMS_TestUtils.createGrade(objSchool,objAY);
    	HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Submitted');
        
        list<Lottery_Management__c> lotList = new list<Lottery_Management__c>();
        Lottery_Management__c objLotTemp = new Lottery_Management__c();
    	objLotTemp.Academic_Year__c = objAY.id;
    	objLotTemp.Gender__c = 'All';
    	objLotTemp.Grade__c = objGrade.id;
    	objLotTemp.Lot_Allocation__c = 'All'; 
    	objLotTemp.Lot_Capacity__c = 50;
    	objLotTemp.Lot_Number__c = 1;
    	objLotTemp.Lottery_Date__c = system.today();
    	objLotTemp.Lottery_Type__c = 'Short List';
    	objLotTemp.School__c = objSchool.id;
    	objLotTemp.Stage__c = srStatus.id;
    	lotList.add(objLotTemp);
    	
    	insert lotList;
    	    	
    	Test.setCurrentPageReference(new PageReference('Page.GEMS_lotteryManagement'));
    	System.currentPageReference().getParameters().put('schoolId', objSchool.id);
    	GEMS_lotteryManagementCtlr lotCtlr = new GEMS_lotteryManagementCtlr();  
    	lotCtlr.objLot = new Lottery_Management__c();
    	
    	
    	lotCtlr.deleteLot = objLotTemp.id;
    	lotCtlr.deleteLot();
    	
    	lotCtlr.generateLot();
    }
    
    static testMethod void GEMS_lotteryManagementTest9(){
    	school__c objSchool = GEMS_TestUtils.createSchool();
    	academic_year__c objAY = GEMS_TestUtils.createAcademicYear(objSchool);
    	grade__c objGrade = GEMS_TestUtils.createGrade(objSchool,objAY);
    	HexaBPM__SR_Status__c srStatus = GEMS_TestUtils.createSRStatus('Submitted');
        
        list<Lottery_Management__c> lotList = new list<Lottery_Management__c>();
        Lottery_Management__c objLotTemp = new Lottery_Management__c();
    	objLotTemp.Academic_Year__c = objAY.id;
    	objLotTemp.Gender__c = 'All';
    	objLotTemp.Grade__c = objGrade.id;
    	objLotTemp.Lot_Allocation__c = 'All'; 
    	objLotTemp.Lot_Capacity__c = 50;
    	objLotTemp.Lot_Number__c = 2;
    	objLotTemp.Lottery_Date__c = system.today();
    	objLotTemp.Lottery_Type__c = 'Short List';
    	objLotTemp.School__c = objSchool.id;
    	objLotTemp.Stage__c = srStatus.id;
    	lotList.add(objLotTemp);
    	
    	Lottery_Management__c objLotTemp1 = new Lottery_Management__c();
    	objLotTemp1.Academic_Year__c = objAY.id;
    	objLotTemp1.Gender__c = 'All';
    	objLotTemp1.Grade__c = objGrade.id;
    	objLotTemp1.Lot_Allocation__c = 'All'; 
    	objLotTemp1.Lot_Capacity__c = 50;
    	objLotTemp1.Lot_Number__c = 1;
    	objLotTemp1.Lottery_Date__c = system.today();
    	objLotTemp1.Lottery_Type__c = 'Short List';
    	objLotTemp1.School__c = objSchool.id;
    	objLotTemp1.Stage__c = srStatus.id;
    	lotList.add(objLotTemp1);
    	
    	insert lotList;
    	    	
    	Test.setCurrentPageReference(new PageReference('Page.GEMS_lotteryManagement'));
    	System.currentPageReference().getParameters().put('schoolId', objSchool.id);
    	GEMS_lotteryManagementCtlr lotCtlr = new GEMS_lotteryManagementCtlr();  
    	lotCtlr.objLot = new Lottery_Management__c();
    	
    	
    	lotCtlr.deleteLot = objLotTemp.id;
    	lotCtlr.deleteLot();
    	
    	lotCtlr.generateLot();
    }
}