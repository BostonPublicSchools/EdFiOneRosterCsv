#Variable to hold variable  
$MsSQLServerConnection= "Server=.; Database=v3.4.0_AMT_EdFi_Ods_Populated_Template; Integrated Security=True;"
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

$edorgId=255901001;
#SQL Query  
$OneRosterQueries = @(
    @{csvName="orgs.csv"; query="SELECT sourcedId,status,dateLastModified,name,type,identifier,parentSourcedId FROM onerosterv11csv.getAllOrgs WHERE EducationOrganizationId=$edorgId;" }
    @{csvName="academicSessions.csv"; query="SELECT * from onerosterv11csv.getAllAcademicSessions;" }
    #more here...
);

foreach ($onq in $OneRosterQueries) {
    createCSV $onq
}
