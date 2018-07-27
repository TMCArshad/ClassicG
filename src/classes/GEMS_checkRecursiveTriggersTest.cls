@isTest
private class GEMS_checkRecursiveTriggersTest {
    static testMethod void GEMS_checkRecursiveTriggersTest1(){
    	GEMS_checkRecursiveTriggers.runOnceForSR = true;
    
	    GEMS_checkRecursiveTriggers.runOnceForLeadBI = true;
	    GEMS_checkRecursiveTriggers.runOnceForLeadBU = true;
	    GEMS_checkRecursiveTriggers.runOnceForLeadAI = true;
	    GEMS_checkRecursiveTriggers.runOnceForLeadAU = true;
	    GEMS_checkRecursiveTriggers.runOnceForLeadBD = true;
	    
	    
	    GEMS_checkRecursiveTriggers.runOnceForEnquiryBI = true;
	    GEMS_checkRecursiveTriggers.runOnceForEnquiryBU = true;
	    GEMS_checkRecursiveTriggers.runOnceForEnquiryAI = true;
	    GEMS_checkRecursiveTriggers.runOnceForEnquiryAU = true;
	    GEMS_checkRecursiveTriggers.runOnceForEnquiryBD = true;
    	 	
    }
}