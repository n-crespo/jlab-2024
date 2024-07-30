<!-- input number form -->
Transaction ID:
<cfform format = "html" method = "post" preservedata = "yes">
    <cfinput name = "tid_num" type = "text" autofocus>
</cfform>

<cfif isDefined("tid_num")>
<cfquery name = "practicequery" datasource = "#application.FacilityDSN#">
    SELECT t1.SERIALNUMBER, t2.CPNAME, t3.VARTYPE
    FROM #application.schema#.INV_TRANSACTIONS t1,
        #application.schema#.INV_PROJECTNAMES t2,
        #application.schema#.INV_PARTS t3
    WHERE t1.TRANSACTIONID = #tid_num#
    AND t2.CPNID = t1.CPNID
    AND t3.PARTID = t1.PARTID
</cfquery>
<cfdump var = "#practicequery#">
</cfif>
