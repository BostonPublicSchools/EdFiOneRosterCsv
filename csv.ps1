#Variable to hold variable  
#$MsSQLServerConnection= "Server=.; Database=v3.4.0_AMT_EdFi_Ods_Populated_Template; Integrated Security=True;"
$MsSQLServerConnection= "Server=STAGEDFISQL01; Database=v34_EdFi_BPS_Staging_Ods; Integrated Security=True;"
#$MsSQLServerConnection= "Server=EDFISQL01; Database=v34_EdFi_BPS_Production_Ods; Integrated Security=True;"
$delimiter = ","

Function createCSV($qo){
    $SqlConnection = New-Object System.Data.SqlClient.SqlConnection  
    $SqlConnection.ConnectionString = $MsSQLServerConnection;  
    $SqlCmd = New-Object System.Data.SqlClient.SqlCommand  
    Write-Host $qo.query
    $SqlCmd.CommandText = $qo.query
    $SqlCmd.Connection = $SqlConnection  
    $SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter  
    $SqlAdapter.SelectCommand = $SqlCmd   
    #Creating Dataset  
    $DataSet = New-Object System.Data.DataSet  
    $SqlAdapter.Fill($DataSet) 
    
    $destPath = "C:\temp\" + $qo.csvName
    $DataSet.Tables[0] | export-csv -Delimiter $delimiter -Path $destPath  -NoTypeInformation
}

#$edorgId=255901001;
$edorgId=Read-Host 'What is the school id? To generate for all School Enter "0" ';
#$edorgIdWhere= "WHERE EducationOrganizationId=$edorgId;";
#if($edorgId -eq $null)
if($edorgId -eq "0")
{
   $edorgIdWhere= ";";
   $edorgIdWhereAs=";";
} 
else {
   $edorgIdWhere= "WHERE EducationOrganizationId=$edorgId;";
   $edorgIdWhereAs= "WHERE EducationOrganizationId=$edorgId OR EducationOrganizationId=0;";
   $edorgIdWhereCr= "WHERE CO.SchoolId=$edorgId;";
}

#SQL Query  
$OneRosterQueries = @(
#orgs
    @{csvName="orgs.csv"; query=-join("SELECT sourcedId,status,dateLastModified,name,type,identifier,parentSourcedId FROM onerosterv11csv.getAllOrgs ", "$edorgIdWhere") }
#academicSessions
    @{csvName="academicSessions.csv"; query=-join("SELECT sourceId,status,dateLastModified,title,startDate,endDate,type,parent AS parentSourcedId,schoolYear from onerosterv11csv.getAllAcademicSessions ", "$edorgIdWhereAs") }
#Classes
    @{csvName="getAllClasses.csv";  query=-join("SELECT sourceId,
       status,
       dateLastModified,
       metadata,
       title,
	   grades,
	   course AS courseSourcedId,
       classCode,
       classType,
       location,
       school AS schoolSourcedId,	          
       terms AS termSourcedIds,
	   subjects,
       subjectCodes,periods  from onerosterv11csv.getAllClasses ", "$edorgIdWhere")}
#Courses
    @{csvName="getAllCourses.csv"; query=-join("SELECT DISTINCT VW.sourceId,
                VW.status,
                VW.dateLastModified,
				VW.schoolYearSourcedId,
                VW.title,                
                VW.courseCode,
                VW.grades,
				VW.org AS orgSourcedId,
                VW.subjects,
                VW.subjectCodes 
				FROM onerosterv11csv.getAllCourses AS VW
JOIN edfi.CourseOffering As CO ON CO.CourseCode = VW.courseCode AND CO.SchoolYear = VW.schoolYear ", "$edorgIdWhereCr") }
#Demographics
    @{csvName="getAllDemographics.csv"; query=-join("SELECT sourceId,
                  status,
                  dateLastModified,
                  birthDate,
                  sex,
                  americanIndianOrAlaskaNative,
                  asian,
                  blackOrAfricanAmerican,
                  nativeHawaiianOrOtherPacificIslander,
                  white,
                  demographicRaceTwoOrMoreRaces,
                  hispanicOrLatinoEthnicity,
                  countryOfBirthCode,
                  stateOfBirthAbbreviation,
                  cityOfBirth,
                  publicSchoolResidenceStatus from onerosterv11csv.getAllDemographics ", "$edorgIdWhere") }
#Enrollments
    @{csvName="GetAllEnrollments.csv"; query="SELECT * from onerosterv11csv.GetAllEnrollments;" }

#Users
    @{csvName="getAllUsers.csv"; query=-join("SELECT sourceId,
       status,
       dateLastModified,
       enabledUser,
	   orgs AS orgSourcedIds,
       role,
       username,
       userIds,
       givenName,
       familyName,
       middleName,
	   identifier,
       email,
       sms,
       phone,
       agents AS agentSourcedIds,
	   grades,
       password
       FROM onerosterv11csv.getAllUsers ", "$edorgIdWhere") }

    #@{csvName="getAllGradingPeriods.csv"; query="SELECT * from onerosterv11csv.getAllGradingPeriods;" }
    #@{csvName="getAllTerms.csv"; query="SELECT * from onerosterv11csv.getAllTerms;" }
    #more here...
);

foreach ($onq in $OneRosterQueries) {
    createCSV $onq
}