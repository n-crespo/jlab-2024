<!-- get transaction id -->
Enter Transaction ID:
<cfform format = "html" method = "post" preservedata = "no">
    <cfinput name = "tid" type = "text" autofocus>
</cfform><br>

<!-- ensure cookies are set -->
<cfif isDefined("tid") && isDefined("cookie.wca") && isDefined("cookie.action") && isDefined("cookie.loc_id")>

    <!-- build traveler ID-->
    <cfinvoke component="TravIDBuilder" method = "getTravID" returnVariable = "trav_id" 
              tid = "#tid#" workcenter = "#cookie.wca#" action = "#cookie.action#"> </cfinvoke>
    <!--- <br> Traveler ID: <cfdump var = "#trav_id#"> --->

    <!--- check if logs should be updated--->
    <cfinvoke component="TravIDBuilder" method="shouldUpdateLogs" returnvariable="shouldUpdateLogs" TID='#tid#'>
    <!--- if part isn't already in that location, update logs --->
    <cfif shouldUpdateLogs>

        <!-- update trav_id with revision number-->
        <cfinvoke component = "TravIDBuilder" method = "getRevisionNumber" returnVariable = "revisionNum" trav_id = "#trav_id#">

        <cfset "trav_id_r" = "#trav_id#" & "-" & "#revisionNum#"> <br><br>
        Revision Number: <cfdump var = "#revisionNum#"><br>
        New Traveler ID: <cfdump var = "#trav_id_r#"><br>

        <!--- update inventory --->
        <cfinvoke component = "TravIDBuilder" method = "updateInventory" returnVariable = "inv_query"
                  tid = "#tid#">

        <!--- update transaction log --->
        <cfinvoke component = "TravIDBuilder" method = "updateTransactionLog" trans_id = "#tid#">

        <cfquery name="GetMaxPage" datasource="#application.dsrc#">
            SELECT TRAV_MAX_PAGE as MAXPAGE 
            FROM TRAV_HEADER
            WHERE TRAV_REVISION = '#revisionNum#'
            AND TRAV_ID = '#trav_id#'
        </cfquery>

        <cfif "#revisionNum#" neq "">
            <!-- separate project name-->
            <cfset delimiterPosition = Find("-", "#trav_id#")>
            <cfset CPname = Left('#trav_id#', delimiterPosition - 1)>

            <!-- redirect to traveler URL-->
            <CFFORM NAME="instantiate" ACTION="/#application.area#/Travelers/TRAVELER_FORM.cfm?project=#CPName#&area=#CPName#&system=#cookie.wca#&TRAV_ID=#trav_id#&TRAV_REVISION=#revisionNum#&page=1&maxpage=#GetMaxPage.MAXPAGE#&TRAV_SEQ_NUM=-1&travstat=n&serialnum="METHOD="POST">
            <input type="submit" name="submit" value="Go to traveler!" style="font-family: Verdana; font-size: 15.0pt;">
            </CFFORM> 
        <cfelse> 
            <font size="3" color="red">
            Invalid Traveler! Ensure the Workcenter and Action cookies have been set correctly. 
        </cfif>
        <cfelse>
            <cfinvoke component = "TravIDBuilder" method = "getTravID" returnVariable = "trav_id"
            tid = "#tid#" workcenter = "#cookie.wca#" action = "#cookie.action#" comp = true>
            <br>
            <cfdump var = "#trav_id#">
    </cfifx
    
</cfif>
