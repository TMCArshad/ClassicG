@isTest
global class GEMS_feeBalanceInfoTest {
    static testMethod void GEMS_feeBalanceInfoTest(){
    	
    	Account objStudent = GEMS_TestUtils.createStudentAccount('Test');
    	objStudent.student_id__c = '111111111';
    	update objStudent;
    	
    	Test.startTest();
    	GEMS_feeBalanceInfo obj = new GEMS_feeBalanceInfo();
    	
    	Test.setMock(WebServiceMock.class, new GEMS_IFEE_DETAILS_ServiceMockImpl());
        GEMS_FeeDetailService.BasicHttpBinding_IFEE_DETAILS basicHttpBindingIfeeDetails = new GEMS_FeeDetailService.BasicHttpBinding_IFEE_DETAILS();
    	obj.getStudentBalance(objStudent.student_id__c, string.valueOf(system.today()));
    	Test.stopTest();
    }
    
    
    global class GEMS_IFEE_DETAILS_ServiceMockImpl implements WebServiceMock {
        global void doInvoke(
                Object stub,
                Object request,
                Map<String, Object> response,
                String endpoint,
                String soapAction,
                String requestName,
                String responseNS,
                String responseName,
                String responseType) {

            GEMS_FeeDetailService.GET_STUDENT_FEE_OUTSTANDINGResponse_element respElement =
                    new GEMS_FeeDetailService.GET_STUDENT_FEE_OUTSTANDINGResponse_element();
                     
            respElement.GET_STUDENT_FEE_OUTSTANDINGResult = '<NewDataSet> <xs:schema id="NewDataSet" xmlns="" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:msdata="urn:schemas-microsoft-com:xml-msdata"> <xs:element name="NewDataSet" msdata:IsDataSet="true" msdata:MainDataTable="Table" msdata:UseCurrentLocale="true"> <xs:complexType> <xs:choice minOccurs="0" maxOccurs="unbounded"> <xs:element name="Table"> <xs:complexType> <xs:sequence> <xs:element name="STUDENTID" type="xs:string" minOccurs="0" /> <xs:element name="STATUS" type="xs:string" minOccurs="0" /> <xs:element name="RETURN_MESSAGE" type="xs:string" minOccurs="0" /> </xs:sequence> </xs:complexType> </xs:element> </xs:choice> </xs:complexType> </xs:element> </xs:schema> <Table> <STUDENTID>28828282</STUDENTID> <STATUS>YES</STATUS> <RETURN_MESSAGE /> </Table> </NewDataSet>';
            
            
            response.put('response_x', respElement);

            //respElement.EchoStringResult = 'Mock response';
            //response.put('response_x', respElement);
        }
    }
}