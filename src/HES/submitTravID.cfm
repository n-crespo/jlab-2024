<cfif isDefined("form.travsearch")>
    <cfset trav_id="#form.travsearch#">

    <cfset delimiterPosition = Find("-", "#trav_id#")>
    <cfset CPname = Left('#trav_id#', delimiterPosition - 1)>

    <cfinvoke component = "TravIDBuilder" method = "getRevisionNumber" returnVariable = "revisionNum" trav_id = "#trav_id#">
    <cfset "trav_id_r" = #trav_id# & "-" & #revisionNum#>

    <cfquery name="GetMaxPage" datasource="#application.dsrc#">
        SELECT TRAV_MAX_PAGE as MAXPAGE 
        FROM TRAV_HEADER
        WHERE TRAV_REVISION = '#revisionNum#'
        AND TRAV_ID = '#trav_id#'
    </cfquery>
     
    <cfset redirectURL = "/" & application.area & "/Travelers/TRAVELER_FORM.cfm?project=" & CPName & "&area=" & CPName & "&system=" & cookie.wca & "&TRAV_ID=" & trav_id & "&TRAV_REVISION=" & revisionNum & "&page=1&maxpage=" & GetMaxPage.MAXPAGE & "&TRAV_SEQ_NUM=-1&travstat=n&serialnum=">
    <cflocation url="#redirectURL#" addtoken="no">  
<cfelse>
    <h2>Something went wrong...</h2>
</cfif>