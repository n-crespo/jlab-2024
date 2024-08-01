<!--- Area header bar table --->
<table id="sal2" height="20" border="0" cellpadding="0" cellspacing="0">
	<tr valign="top"><td align="center" class="style8">Keeping Transaction Logs</td></tr>
	<tr valign="top"><td><hr></td></tr>
</table>

<cfquery name="getLocations" datasource="#application.dsrc#">
  SELECT ACRONYM_ID || ' - ' || ACRONYM_DESC AS ID_DESC, ACRONYM_ID, ACRONYM_DESC
	FROM #application.schema#.TRAV_ACRONYMS
	WHERE ACRONYM_LEVEL = 'WCA'
	AND obs is null
	AND CLOSED IS NULL
	AND RETIRED IS NULL
	ORDER BY ACRONYM_ID
</cfquery>

<cfquery name="getActions" datasource="#application.dsrc#">
  SELECT ACRONYM_ID || ' - ' || ACRONYM_DESC AS ID_DESC, ACRONYM_ID, ACRONYM_DESC
	FROM #application.schema#.TRAV_ACRONYMS
	WHERE ACRONYM_LEVEL = 'ACTION'
	AND obs is null
	AND CLOSED IS NULL
	AND RETIRED IS NULL
	ORDER BY ACRONYM_ID
</cfquery>

<!--- NOTE: make this field requred later --->
<cfform name="Form1">
	Enter Transaction ID: <cfinput name = "tid_num" type = "text" autofocus required="No" message="Please enter a Transaction ID. "> </br>
	Select a location: <cfselect name="location_select" 
                  query="getLocations" 
                  display="ID_DESC" 
                  required="Yes" 
                  multiple="No"
                  value="ACRONYM_ID"
                  message="Please select a location."
                  selected = "#cookie.wca#">
	</cfselect> </br>
	Select an action:<cfselect name="action_select" 
                             queryPosition="below" 
                             query="getActions" 
                             display="ID_DESC"  
                             required="Yes" 
                             selected = "#cookie.action#"
                             message="Please select an action."
                             value="ACRONYM_ID"
                             multiple="No">
		<option value='NULL'>NULL</option>
	</cfselect></br>
	Enter manual trav id: <cfinput name = "manual_trav_id" type = "text" required="no" > </br>
	<br><input type="Submit" value="Submit">  
</cfform>

<cfif isDefined("tid_num")>
    <cfif "#tid_num#" neq "">
        <cfquery name="tid_lookup" datasource="#application.FacilityDSN#">
            SELECT t2.cpname, t3.vartype, t4.LOCATIONNAME, t5.BUILDINGNAME
            FROM #application.schema#.inv_transactions t1,
                 #application.schema#.inv_projectnames t2,
                 #application.schema#.inv_parts t3,
                 #application.schema#.INV_LOCATIONS t4,
                 #application.schema#.inv_buildings t5
            where t1.transactionID = <cfqueryparam value="#tid_num#" cfsqltype="cf_sql_integer">
            AND t1.cpnid = t2.cpnid
            AND t1.partid = t3.partid
            AND t1.LOCATIONID = t4.LOCATIONID
            AND t4.BUILDINGID = t5.BUILDINGID
        </cfquery>
    </cfif>
</cfif>


<cfif isDefined("action_select") AND isDefined("location_select")> 
  <!--- cookies --->
  <cfcookie name="action" value="#action_select#" expires="never">
  <cfcookie name="location" value="#location_select#" expires="never">
	<cfoutput>lc: #cookie.wca#</cfoutput> </br>
	<cfoutput>ac: #cookie.action#</cfoutput> </br>

  <!--- trav id --->
  <cfif isDefined("manual_trav_id")>
    <cfset "traveler_id"="#manual_trav_id#">
  <cfelse>
    <cfset "traveler_id" = "#tid_lookup.cpname#"& '-' & "#cookie.location#"& "-" & "#tid_lookup.vartype#" & '-' & "#cookie.action#">
  </cfif>
  </br></br><cfdump var="#traveler_id#">

  <cfquery name="getRevision" datasource="#application.dsrc#" maxrows="10">
    SELECT MAX(TRAV_REVISION)
    FROM #application.schema#.TRAV_CONFIG
    WHERE TRAV_ID = <cfqueryparam value="#traveler_id#" cfsqltype="cf_sql_varchar">
    AND obs is null
  </cfquery>

<!---
  <cfquery name="dumpConfig" datasource="#application.dsrc#">
    SELECT TRAV_ID, TRAV_REVISION, MOD_DATE, OBS
    FROM #application.schema#.TRAV_CONFIG
    -- WHERE obs is null
    ORDER BY MOD_DATE DESC
  </cfquery>
--->
  <!--- </br> max revision: <cfdump var="#getRevision.MAX_REVISION#"> ! --->
  <cfdump var="#getRevision#">
  <cfdump var="#dumpConfig#">

<cfelse>
  cookies are not set 
</cfif>

  
</br></br>
<!---  check if partID and serial number have a match in inventory TABLE--->