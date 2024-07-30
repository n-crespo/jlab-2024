<!-- get transaction id -->
<div id = "tid_input">
<cfform format = "html" method = "post" preservedata = "no" align="left">
Enter Transaction ID: <cfinput name = "tid" type = "text" maxlength = "9" autofocus>
</cfform>
</div>
<script>
    var theDiv = document.getElementById("tid_input");
    theDiv.style.display = '';
</script>

<!-- ensure cookies are set -->
<cfif isDefined("tid") && #tid# neq "" && isNumeric("#tid#") && isDefined("cookie.wca") && isDefined("cookie.action") && isDefined("cookie.loc_id")>

    <!-- build traveler ID-->
    <cfinvoke component="TravIDBuilder" method = "getTravID" returnVariable = "trav_id"
    tid = "#tid#">

    <!--- make sure this only happens if form to select traveler ID has been submitted --->
    <!-- update trav_id with revision number-->
    <cfinvoke component = "TravIDBuilder" method = "getRevisionNumber" returnVariable = "revisionNum" trav_id = "#trav_id#">
    <cfset "trav_id_r" = #trav_id# & "-" & #revisionNum#>

    <!--- check if logs should be updated--->
    <cfinvoke component="TravIDBuilder" method="shouldUpdateLogs" returnvariable="shouldUpdateLogs" TID="#tid#">
    <!--- only update the logs if needed --->
    <cfif shouldUpdateLogs>
        <!--- update inventory --->
        <cfinvoke component = "TravIDBuilder" method = "updateInventory" returnVariable = "inv_query"
                tid = "#tid#">
        <!--- update transaction log --->
        <cfinvoke component = "TravIDBuilder" method = "updateTransactionLog" TID = "#tid#">
    </cfif>

    <!--- this is needed for redirection --->
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
        <cfset redirectURL = "/" & application.area & "/Travelers/TRAVELER_FORM.cfm?project=" & CPName & "&area=" & CPName & "&system=" & cookie.wca & "&TRAV_ID=" & trav_id & "&TRAV_REVISION=" & revisionNum & "&page=1&maxpage=" & GetMaxPage.MAXPAGE & "&TRAV_SEQ_NUM=-1&travstat=n&serialnum=">
        <cflocation url="#redirectURL#" addtoken="no">
    <cfelse>
        <!--- needs mike's query to search/select desired traveler --->
        <cfinvoke component="TravIDBuilder" method="getTravIDExtended" tid="#tid#">
    </cfif>
</cfif>
