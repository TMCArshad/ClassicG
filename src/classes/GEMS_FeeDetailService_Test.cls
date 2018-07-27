/**
 * Created by bilalnazir on 5/31/17.
 */

@IsTest 
global class GEMS_FeeDetailService_Test{
    
    static testMethod void testTC_ClearanceService() {
        Test.setMock(WebServiceMock.class, new GEMS_FeeDetailTC_ClearanceServiceMockImpl());
        GEMS_FeeServiceUtility.checkStatusForTCClearance('2838839393');
        //GEMS_FeeServiceUtility.getStudentLDA('292992', '2929292');
    }

    static testMethod void testOutstandingFeeService() {
        Test.setMock(WebServiceMock.class, new GEMS_FeeDetailStudentFee_OutstandingServiceMockImpl());
        GEMS_FeeServiceUtility.getStudentLDA('2838839393', '229299292');
        //GEMS_FeeServiceUtility.getStudentLDA('292992', '2929292');
    }

    static testMethod void testFeeDetails(){
        Test.setMock(WebServiceMock.class, new GEMS_IFEE_DETAILS_ServiceMockImpl());
        GEMS_FeeDetailService.BasicHttpBinding_IFEE_DETAILS basicHttpBindingIfeeDetails = new GEMS_FeeDetailService.BasicHttpBinding_IFEE_DETAILS();
        basicHttpBindingIfeeDetails.GET_STUDENT_FEE_OUTSTANDING('2838839393', '229299292');
    }


    global class GEMS_FeeDetailTC_ClearanceServiceMockImpl implements WebServiceMock {
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

            GEMS_FeeDetailService.CHECK_STATUS_FOR_TC_CLEARANCEResponse_element respElement =
                    new GEMS_FeeDetailService.CHECK_STATUS_FOR_TC_CLEARANCEResponse_element();
            respElement.CHECK_STATUS_FOR_TC_CLEARANCEResult = '<NewDataSet> <xs:schema id="NewDataSet" xmlns="" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:msdata="urn:schemas-microsoft-com:xml-msdata"> <xs:element name="NewDataSet" msdata:IsDataSet="true" msdata:MainDataTable="Table" msdata:UseCurrentLocale="true"> <xs:complexType> <xs:choice minOccurs="0" maxOccurs="unbounded"> <xs:element name="Table"> <xs:complexType> <xs:sequence> <xs:element name="STUDENTID" type="xs:string" minOccurs="0" /> <xs:element name="STATUS" type="xs:string" minOccurs="0" /> <xs:element name="RETURN_MESSAGE" type="xs:string" minOccurs="0" /> </xs:sequence> </xs:complexType> </xs:element> </xs:choice> </xs:complexType> </xs:element> </xs:schema> <Table> <STUDENTID>28828282</STUDENTID> <STATUS>YES</STATUS> <RETURN_MESSAGE /> </Table> </NewDataSet>';
            response.put('response_x', respElement);

            //respElement.EchoStringResult = 'Mock response';
            //response.put('response_x', respElement);
        }
    }

    global class GEMS_FeeDetailStudentFee_OutstandingServiceMockImpl implements WebServiceMock {
        
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

            GEMS_FeeDetailService.GET_STUDENT_LDAResponse_element respElement =
                    new GEMS_FeeDetailService.GET_STUDENT_LDAResponse_element();
                  
            respElement.GET_STUDENT_LDAResult = '<NewDataSet> <xs:schema id="NewDataSet" xmlns="" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:msdata="urn:schemas-microsoft-com:xml-msdata"> <xs:element name="NewDataSet" msdata:IsDataSet="true" msdata:MainDataTable="Table" msdata:UseCurrentLocale="true"> <xs:complexType> <xs:choice minOccurs="0" maxOccurs="unbounded"> <xs:element name="Table"> <xs:complexType> <xs:sequence> <xs:element name="STUDENTID" type="xs:string" minOccurs="0" /> <xs:element name="STATUS" type="xs:string" minOccurs="0" /> <xs:element name="RETURN_MESSAGE" type="xs:string" minOccurs="0" /> </xs:sequence> </xs:complexType> </xs:element> </xs:choice> </xs:complexType> </xs:element> </xs:schema> <Table> <STUDENTID>28828282</STUDENTID> <STATUS>YES</STATUS> <RETURN_MESSAGE /> </Table> </NewDataSet>';
        
                
            
            response.put('response_x', respElement);

            //respElement.EchoStringResult = 'Mock response';
            //response.put('response_x', respElement);
        }
    }
    global class GEMS_FeeDetailStudentFee_OutstandingServiceMockImpl1 implements WebServiceMock {
      
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

            GEMS_FeeDetailService.GET_STUDENT_LDAResponse_element respElement =
                    new GEMS_FeeDetailService.GET_STUDENT_LDAResponse_element();
                    respElement.GET_STUDENT_LDAResult = '<NewDataSet> <xs:schema id="NewDataSet" xmlns="" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:msdata="urn:schemas-microsoft-com:xml-msdata"> <xs:element name="NewDataSet" msdata:IsDataSet="true" msdata:MainDataTable="Table" msdata:UseCurrentLocale="true"> <xs:complexType> <xs:choice minOccurs="0" maxOccurs="unbounded"> <xs:element name="Table"> <xs:complexType> <xs:sequence> <xs:element name="LDA_DATE" type="xs:string" minOccurs="0" /> <xs:element name="TOT_DAYS" type="xs:int" minOccurs="0" /> <xs:element name="TOT_PRS_DAYS" type="xs:int" minOccurs="0" /> </xs:sequence> </xs:complexType> </xs:element> </xs:choice> </xs:complexType> </xs:element> </xs:schema> <Table> <TOT_DAYS>0</TOT_DAYS> <TOT_PRS_DAYS>0</TOT_PRS_DAYS> </Table> </NewDataSet>';
            response.put('response_x', respElement);

            //respElement.EchoStringResult = 'Mock response';
            //response.put('response_x', respElement);
        }
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