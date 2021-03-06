ipmo mysqllib -Force 

function AssertEquals{
param($lhs,$rhs,$description)
if ($lhs -eq $rhs){ 
	Write-Host "$description PASSED" -BackgroundColor Green 
} else {
	Write-Host "$description FAILED" -BackgroundColor Red
}
}

$server = 'localhost'
$db = 'testadonet'
$sql = "SELECT * from Person"

#test simple query using ad hoc connection and SQL login
$rows=invoke-MySQLQuery -sql $sql -server $server -database $db -user test_login -password 12345
AssertEquals $rows.Count 5 "ad hoc connection with SQL Login" 

#test parameterized query with ad hoc connection and sql login
$rows=@(invoke-MySQLQuery -sql 'select * from Person where LastName like @pattern' -server $server -database $db -user test_login -password 12345 -parameters @{pattern='M%'})
AssertEquals $rows.Count 2 "parameterized query with sql login" 
 
remove-variable conn -ea SilentlyContinue

$conn=new-MySQLConnection  -server $server -database $db  -user test_login -password 12345


#test simple query using shared connection and SQL login
$rows=invoke-MySQLQuery -sql $sql -conn $conn 
AssertEquals $rows.Count 5 "shared connection and SQL login" 

#test parameterized query with shared connection and sql login
$rows=@(invoke-MySQLQuery -sql 'select * from Person where LastName like @pattern' -conn $conn  -parameters @{pattern='M%'})
AssertEquals $rows.Count 2 "parameterized query with shared connection and sql login" 
 
#test stored procedure query with shared connection and sql login and IN parameters
$rows=@(invoke-MySQLstoredprocedure  -storedProcName stp_TestInputParameter  -conn $conn  -parameters @{prmPersonID=3})
AssertEquals $rows.Count 1 "parameterized query (in) with shared connection and sql login" 

#test stored procedure query with shared connection and sql login and out parameters
$outRows=invoke-MySQLstoredprocedure  -storedProcName stp_TestOutputParameter  -conn $conn  -parameters @{prmPersonID=3} -outparameters @{prmFullName='varchar(101)'} 
AssertEquals ($outrows.prmFullName -eq 'Mike Shepard') $true "parameterized query (out) with shared connection and sql login" 

#test NULL parameters
$rows=invoke-MySQLQuery "SELECT * from Person where @parm is NULL" -conn $conn -parameters @{parm=[System.DBNull]::Value}
AssertEquals $rows.Count 5 "shared connection null parameters" 

#test simple query using ad hoc connection and SQL Login with "-AsResult DataTable"
$rows=invoke-MySQLQuery -sql $sql -server $server -database $db -user test_login -password 12345 -AsResult DataTable
AssertEquals ($rows -is [Data.DataTable]) $true  "ad hoc connection with SQL Login as DataTable" 

#test simple query using ad hoc connection and SQL Login with "-AsResult DataSet"
$rows=invoke-MySQLQuery -sql $sql -server $server -database $db -user test_login -password 12345 -AsResult DataSet
AssertEquals ($rows -is [Data.DataSet]) $true  "ad hoc connection with SQL Login as DataSet" 


#test simple query using ad hoc connection and SQL Login with "-AsResult DataRow"
$rows=@(invoke-MySQLQuery -sql $sql -server $server -database $db -user test_login -password 12345 -AsResult DataRow)
AssertEquals ($rows[0] -is [Data.DataRow]) $true  "ad hoc connection with SQL Login as DataRow" 