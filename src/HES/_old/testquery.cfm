<cfoutput>
	<cfquery name="testquery" datasource="#application.dsrc#">
		SELECT * FROM #application.schema#.CAV_TYPE_PARAMS 
		WHERE CHANGE_COMMENT <> '[empty string]'
		/* ORDER BY CAVTYPE */
	</cfquery>
</cfoutput>
<cfdump var = "#testquery#">