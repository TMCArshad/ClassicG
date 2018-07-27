public class GEMS_FeeServiceUtility {

    public static GEMS_FeeDetailService.BasicHttpBinding_IFEE_DETAILS service;
    
    /**
     * [checkStatusForTCClearance -Checks OASIS System and returns  TC Clearance ststus ]
     * @param  studentId [studentID information]
     * @return           [Status - YES/NO ]
     */
    public static TCClearanceWrapper checkStatusForTCClearance(String studentId) {
        TCClearanceWrapper tcw = new TCClearanceWrapper();

        String tcClearanceStatus;
        service = new GEMS_FeeDetailService.BasicHttpBinding_IFEE_DETAILS();
        try {
            tcClearanceStatus = service.CHECK_STATUS_FOR_TC_CLEARANCE(studentId);
        } catch (Exception e) {
            tcw.clearanceStatus = '';
            tcw.clearanceMessage = e.getMessage();
            return tcw;
        }
        system.debug('tc ClearanceStatus===>' + tcClearanceStatus);
        //Parse the result
        DOM.Document doc = new DOM.Document();
        doc.load(tcClearanceStatus);
        DOM.XMLNode root = doc.getRootElement();
        for (Dom.XmlNode node : root.getChildElements()) {
            if (node.getNodeType() == DOM.XmlNodeType.ELEMENT && node.getName() == 'Table') {


                tcw.clearanceStatus = node.getChildElement('STATUS', null).getText();
                tcw.clearanceMessage = node.getChildElement('RETURN_MESSAGE', null).getText();
            }
        }
        return tcw;

    }


    public static studentLDAWrapper getStudentLDA(String studentId, String ACDId) {
        String retStr = '';
        studentLDAWrapper obj = new studentLDAWrapper();
        service = new GEMS_FeeDetailService.BasicHttpBinding_IFEE_DETAILS();
        String studentLDA = service.GET_STUDENT_LDA(studentId, ACDId);
        System.debug('studentLDA==>'+studentLDA);
        //Parse the result
        DOM.Document doc = new DOM.Document();
        doc.load(studentLDA);
        DOM.XMLNode root = doc.getRootElement();
        for (Dom.XmlNode node : root.getChildElements()) {
            if (node.getNodeType() == DOM.XmlNodeType.ELEMENT && node.getName() == 'Table') {
                for (Dom.XmlNode child : node.getChildElements()) {
                    obj.LDA_DATE = (child.getName() == 'LDA_DATE') ? child.getText() : obj.LDA_DATE;
                    obj.TOT_DAYS = (child.getName() == 'TOT_DAYS') ? child.getText() : obj.TOT_DAYS;
                    obj.TOT_PRS_DAYS = (child.getName() == 'TOT_PRS_DAYS') ? child.getText() : obj.TOT_PRS_DAYS;

                }

            }
        }
        return obj;


    } 
    /*
    Wrapper class to capture parameters of LDA request
     */
    public Class studentLDAWrapper {
        public String LDA_DATE;
        public String TOT_DAYS;
        public String TOT_PRS_DAYS;

    }
    public class TCClearanceWrapper {
        public string clearanceStatus;
        public string clearanceMessage;
    }

    /*
    public String walkThrough(DOM.XMLNode node) {
        String result = '\n';
        if (node.getNodeType() == DOM.XMLNodeType.COMMENT) {
            return 'Comment (' + node.getText() + ')';
        }
        if (node.getNodeType() == DOM.XMLNodeType.TEXT) {
            return 'Text (' + node.getText() + ')';
        }
        if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {
            result += 'Element: ' + node.getName();
            if (node.getText().trim() != '') {
                result += ', text=' + node.getText().trim();
            }
            if (node.getAttributeCount() > 0) {
                for (Integer i = 0; i < node.getAttributeCount(); i++) {
                    result += ', attribute #' + i + ':' + node.getAttributeKeyAt(i) + '=' + node.getAttributeValue(node.getAttributeKeyAt(i), node.getAttributeKeyNsAt(i));
                }
            }
            for (Dom.XMLNode child: node.getChildElements()) {
                result += walkThrough(child);
            }
            return result;
        }
        return '';  //should never reach here
    }*/
}