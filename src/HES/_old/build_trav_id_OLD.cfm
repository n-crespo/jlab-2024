<!-- input number form -->
Transaction ID:
<!--- NOTE: this `preservedata` parameter might be the reason cookies are doing weird things - nick --->
<!-- oh hm I'll try getting rid of it -->
<cfform format = "html" method = "post" preservedata = "no">
    <cfinput name = "tid_num" type = "text" autofocus>
</cfform>

<!-- get traveler id -->
<cfif isDefined("tid_num") && isDefined("cookie.wca") && isDefined("cookie.action")>
    <cfquery name = "trav_data" datasource = "#application.FacilityDSN#">
        SELECT t2.CPNAME, t3.VARTYPE
        FROM #application.schema#.INV_TRANSACTIONS t1,
            #application.schema#.INV_PROJECTNAMES t2,
            #application.schema#.INV_PARTS t3
        WHERE t1.TRANSACTIONID = <cfqueryparam value=#tid_num# cfsqltype="cf_sql_integer">
        AND t2.CPNID = t1.CPNID
        AND t3.PARTID = t1.PARTID
    </cfquery>
    <cfset "trav_id" = "">
    <cfif "#trav_data.CPNAME#" != ''>
        <cfset "trav_id" = "#trav_id#" & "#trav_data.CPNAME#">
        Project Name: <cfdump var = "#trav_data.CPNAME#"><br>
        <cfelse>
            Project Name Not Found.<br>
    </cfif>
    <cfif "#cookie.wca#" != "NULL">
        <cfset "trav_id" = "#trav_id#" & "-" & "#cookie.wca#">
        WCA: <cfdump var = "#cookie.wca#"> <br>
        <cfelse>
            WCA Not Found. <br>
    </cfif>
    <cfif "#trav_data.VARTYPE#" != "">
        <cfset "trav_id" = "#trav_id#" & "-" & mid(#trav_data.VARTYPE#,1,len(#trav_data.VARTYPE#)-2)>
        Part Name: <cfdump var = "#trav_data.VARTYPE#"> <br>
        <cfelse>
            Part Name Not Found. <br>
    </cfif>
    <cfif "#cookie.action#" != "NULL">
        <cfset "trav_id" = "#trav_id#" & "-" & "#cookie.action#">
        Action: <cfdump var = "#cookie.action#"> <br>
        <cfelse>
            Action Not Found.<br>
    </cfif>

    <cfquery name="getRevision" datasource="#application.dsrc#" >
        SELECT MAX(TRAV_REVISION) AS MAX_REVISION
        FROM #application.schema#.TRAV_CONFIG
        WHERE TRAV_ID = <cfqueryparam value="#trim(trav_id)#" cfsqltype="cf_sql_varchar">
    </cfquery>

    <cfif getRevision.MAX_REVISION neq "">
        <cfset trav_id = "#trav_id#" & "-" & "#getRevision.MAX_REVISION#">
    </cfif>
    <cfoutput>#getRevision.MAX_REVISION#</cfoutput>

    <br>Traveler ID:<br>
    <cfdump var = "#trav_id#">

</cfif>