#Variable to hold variable  
#$MsSQLServerConnection= "Server=.; Database=v3.4.0_AMT_EdFi_Ods_Populated_Template; Integrated Security=True;"

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
$edorgId=Read-Host 'What is the school id?';
$edorgIdWhere= "WHERE EducationOrganizationId=$edorgId;";
if($x -eq $null){
   $edorgIdWhere= ";";
} 
else {
   $edorgIdWhere= "WHERE EducationOrganizationId=$edorgId;";
}

#SQL Query  
$OneRosterQueries = @(
    @{csvName="orgs.csv"; query=-join("SELECT sourcedId,status,dateLastModified,name,type,identifier,parentSourcedId FROM onerosterv11csv.getAllOrgs ", "$edorgIdWhere;") }
    @{csvName="academicSessions.csv"; query="SELECT * from onerosterv11csv.getAllAcademicSessions;" }
    @{csvName="getAllClasses.csv"; query="SELECT * from onerosterv11csv.getAllClasses;" }
    @{csvName="getAllCourses.csv"; query="SELECT * from onerosterv11csv.getAllCourses;" }
    @{csvName="getAllDemographics.csv"; query="SELECT * from onerosterv11csv.getAllDemographics;" }
    @{csvName="GetAllEnrollments.csv"; query="SELECT * from onerosterv11csv.GetAllEnrollments;" }
    @{csvName="getAllGradingPeriods.csv"; query="SELECT * from onerosterv11csv.getAllGradingPeriods;" }
    @{csvName="getAllTerms.csv"; query="SELECT * from onerosterv11csv.getAllTerms;" }
    @{csvName="getAllUsers.csv"; query="SELECT * from onerosterv11csv.getAllUsers;" }
    #more here...
);

foreach ($onq in $OneRosterQueries) {
    createCSV $onq
}