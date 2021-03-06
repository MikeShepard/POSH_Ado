param([parameter(Mandatory=$true,
                 HelpMessage="The name of the ADO.NET provider to import the module for.")]
                 $ADONETProvider)

# Load the named ADO.NET provider
$provider=[System.Data.Common.DbProviderFactories]::GetFactory($ADONETProvider) 


# ---------------------------------------------------------------------------
### <Script>
### <Author>
### Mike Shepard
### </Author>
### <Description>
### Defines functions for executing Ado.net queries
### </Description>
### <Usage>
### import-module adonetlib -args ProviderName -Prefix PRE -force
### Ex:  import-module adonetlib -args System.Data.SqlClient -Prefix SQL -force
###  </Usage>
### </Script>
# ---------------------------------------------------------------------------


$ADONET_ServerToken='Server'
$ADONET_DatabaseToken='Database'
$ADONET_UserToken='User ID'
$ADONET_PasswordToken='Password'
$ADONET_NTAuthenticationToken='Integrated Security'
$ADONET_Options = @{Pooling='true'}
$ADONET_AllowNTAuthentication=$true 
$ADONET_UseODBCSyntax=$false 
$ADONET_ParameterPrefix="@"
<#
	.SYNOPSIS
		Provide changes for the connection string builing process

	.DESCRIPTION
		This function changes the default settings that the connection string building process uses to create a connection string.

	.PARAMETER  ServerToken
		The string token in the connection string that indicates the server/file/instance for the connection.

	.PARAMETER  DatabaseToken
		The string token in the connection string that specifies the database for the connection.
	
    .PARAMETER  UserToken
		The string token in the connection string that specifies the named user for the connection
        
	.PARAMETER  PasswordToken
		The string token in the connection string that specifies the password for the named user.

	.PARAMETER  NTAuthenticationToken
		The string token in the connection string that indicates whether NT Authentication is to be used for the connection.

	.PARAMETER  AllowNTAuthentication
		Indicates whether the provider allows the use of windows integrated security (NT Authentication)

	.PARAMETER  UseODBCSyntax
		Whether or not connection strings for this ADO.NET provider should be created using ODBC syntax (http://msdn.microsoft.com/en-us/library/ms722656%28v=vs.85%29.aspx)
     
    .PARAMETER  ParameterPrefix
        The character to use (if any) to prefix parameter names.  Defaults to @

	.PARAMETER  Options
		A hashtable of options to apply by default to all connections for this provider (unless overridden)

	.EXAMPLE
		PS C:\> New-ConnectionString -server MYSERVER -database master

	.EXAMPLE
		PS C:\> set-ADONetParameters -ServerToken "Data Source" -DatabaseToken "Initial Catalog"
    .INPUTS
        None.
        You cannot pipe objects to set-ADONetParameters

	.OUTPUTS
		None

#>
function set-ADONetParameters{
param(
$ServerToken=$ADONET_ServerToken,
$DatabaseToken=$ADONET_DatabaseToken,
$UserToken=$ADONET_UserToken,
$PasswordToken=$ADONET_PasswordToken,
$NTAuthenticationToken=$ADONET_NTAuthenticationToken,
$AllowNTAuthentication=$ADONET_AllowNTAuthentication ,
$UseODBCSyntax=$ADONET_UseODBCSyntax ,
$ParameterPrefix=$ADONET_ParameterPrefix,
$Options = @{Pooling='true'})


$script:ADONET_ServerToken =$ServerToken
$script:ADONET_DatabaseToken =$DatabaseToken 
$script:ADONET_UserToken =$UserToken 
$script:ADONET_PasswordToken =$PasswordToken 
$script:ADONET_NTAuthenticationToken =$NTAuthenticationToken
$script:ADONET_AllowNTAuthentication =$AllowNTAuthentication 
$script:ADONET_UseODBCSyntax =$UseODBCSyntax 
$script:ADONET_ParameterPrefix=$ParameterPrefix
$script:ADONET_Options =$Options 
}


<#
	.SYNOPSIS
		Create an ADO.NET connection string using the given parameters

	.DESCRIPTION
		This function creates a ADO.NET connection string, using the parameters provided.  You may optionally provide the initial database, and SQL credentials (to use instead of NT Authentication).

	.PARAMETER  Server
		The name of the Server/instance/file to connect to.  To connect to a named SQL Server instance, enclose the server name in quotes (e.g. "Laptop\SQLExpress")

	.PARAMETER  Database
		The Initial Database for the connection.
	
    .PARAMETER  User
		The SQLUser you wish to use for the connection (instead of using NT Authentication)
        
	.PARAMETER  Password
		The password for the user specified by the User parameter.

	.EXAMPLE
		PS C:\> New-ConnectionString -server MYSERVER -database master

	.EXAMPLE
		PS C:\> New-Connectionstring -server MYSERVER -user sa -password sapassword

    .INPUTS
        None.
        You cannot pipe objects to New-Connectionstring

	.OUTPUTS
		String

#>
function New-ConnectionString{
param([Parameter(Position=0, Mandatory=$true)][string]$server, 
      [Parameter(Position=1, Mandatory=$false)][string]$database='',
      [string]$user='',
      [string]$password='',
	  [hashtable]$options=$ADONET_Options)
	$connStringBuilder=$provider.CreateConnectionStringBuilder()
	if ($ADONET_UseODBCSyntax){
		$connStringBuilder=New-Object ($connStringBuilder.GetType()) -ArgumentList $true
	}
	$connStringBuilder.Add($ADONET_ServerToken,$server)
	if($database -ne ''){
	  $connStringBuilder.Add($ADONET_DatabaseToken,$database)
	}
	
	if ($user -ne ''){
		$connStringBuilder.Add($ADONET_UserToken,$user)
		$connStringBuilder.Add($ADONET_PasswordToken,$password)
	} elseif ($ADONET_AllowNTAuthentication) {
		$connStringBuilder.Add($ADONET_NTAuthenticationToken,'yes')
	}
	foreach($key in $options.Keys){
		$connStringBuilder.Add($key,$options[$key])
	}
    return $connStringBuilder.ConnectionString
}

<#
	.SYNOPSIS
		Create a DBConnection object with the given parameters for the ADO.NET provider selected by the module import

	.DESCRIPTION
		This function creates a DBConnection object, using the parameters provided to construct the connection string.  You may optionally provide the initial database, and SQL credentials (to use instead of NT Authentication).

	.PARAMETER  Server
		The name of the Server/instance/file to connect to.  To connect to a named SQL Server instance, enclose the server name in quotes (e.g. "Laptop\SQLExpress")

	.PARAMETER  Database
		The Initial Database for the connection.
	
    .PARAMETER  User
		The SQLUser you wish to use for the connection (instead of using NT Authentication)
        
	.PARAMETER  Password
		The password for the user specified by the User parameter.

	.PARAMETER  Options
		The hashtable providing options to add to the connection string.

	.EXAMPLE
		PS C:\> New-Connection -server MYSERVER -database master

	.EXAMPLE
		PS C:\> New-Connection -server MYSERVER -user sa -password sapassword

    .INPUTS
        None.
        You cannot pipe objects to New-Connection

	.OUTPUTS
		System.Data.Common.DBConnection

#>
function New-Connection{
param([Parameter(Position=0, Mandatory=$true)][string]$server, 
      [Parameter(Position=1, Mandatory=$false)][string]$database='',
      [string]$user='',
      [string]$password='',
      [hashtable]$options=$ADONET_Options)

	$conn=$provider.CreateConnection()
	$conn.ConnectionString=new-connectionstring @PSBoundParameters
    
	$conn.Open()
	
	return $conn 
}
<#
	.SYNOPSIS
		Tests to see if a value is a SQL NULL or not

	.DESCRIPTION
		Returns $true if the value is a SQL NULL.

	.PARAMETER  value
		The value to test

	

	.EXAMPLE
		PS C:\> Is-NULL $row.columnname

	
    .INPUTS
        None.
 

	.OUTPUTS
		Boolean

#>
function Is-NULL{
  param([Parameter(Position=0, Mandatory=$true)]$value)
  return  [System.DBNull]::Value.Equals($value)
}



function Get-Connection{
param([System.Data.Common.DBConnection]$conn,
      [string]$server, 
      [string]$database,
      [string]$user,
      [string]$password,
      [hashtable]$options=$ADONET_Options)
	if (-not $conn){
		if ($server){
			$conn=New-Connection -server $server -database $database -user $user -password $password -options $options
		} else {
		    throw "No connection or connection information supplied"
		}
	}
	return $conn
}

function Put-OutputParameters{
param([Parameter(Position=0, Mandatory=$true)][System.Data.IDBCommand]$cmd, 
      [Parameter(Position=1, Mandatory=$false)][hashtable]$outparams)
    if ($outparams){
    	foreach($outp in $outparams.Keys){
            $paramtype=get-paramtype $outparams[$outp]
            $p=$provider.CreateParameter()
            $p.ParameterName="$ADONET_ParameterPrefix$outp"
            $p.Direction=[System.Data.ParameterDirection]::Output
            $p.DBType=$paramtype 
            if ($paramtype -like '*string*'){
               if ($outparams[$outp] -match '.*\((.*)\)'){
                  $p.size=[int]$matches[1]
               } else {
                  #no size specified...use 50 as a default.
                  $p.size=50
               }
                
            }
            $p2=$cmd.Parameters.Add($p)
     	}
    }
}

function Get-Outputparameters{
param([Parameter(Position=0, Mandatory=$true)][System.Data.IDBCommand]$cmd,
      [Parameter(Position=1, Mandatory=$true)][hashtable]$outparams)
	foreach($p in $cmd.Parameters){
		if ($p.Direction -eq [System.Data.ParameterDirection]::Output){
          if($ADONET_ParameterPrefix -ne ''){
		      $outparams[$p.ParameterName.Replace("$ADONET_ParameterPrefix","")]=$p.Value
          } else {
    		  $outparams[$p.ParameterName]=$p.Value
          }
        }
	}
}



function Get-ParamType{
param([string]$typename)
	$type=switch -wildcard ($typename.ToLower()) {
		'uniqueidentifier' {[System.Data.DbType]::Guid}
		'int'  {[System.Data.DbType]::Int32}
		'datetime'  {[System.Data.DbType]::Datetime}
		'tinyint'  {[System.Data.DbType]::Byte}
		'bigint'  {[System.Data.DbType]::Int64}
		'bit'  {[System.Data.DbType]::Boolean}
		'char*'  {[System.Data.DbType]::StringFixedLength}
		'nchar*'  {[System.Data.DbType]::AnsiString}
		'date'  {[System.Data.DbType]::date}
        'varchar*' {[System.Data.DbType]::AnsiString}
        'nvarchar*' {[System.Data.DbType]::String}
		default {[System.Data.DbType]::Int32}
	}
	return $type
	
}

function Copy-HashTable{
param([hashtable]$hash,
[String[]]$include,
[String[]]$exclude)

	if($include){
	   $newhash=@{}
	   foreach ($key in $include){
	    if ($hash.ContainsKey($key)){
	   		$newhash.Add($key,$hash[$key]) | Out-Null 
		}
	   }
	} else {
	   $newhash=$hash.Clone()
	   if ($exclude){
		   foreach ($key in $exclude){
		        if ($newhash.ContainsKey($key)) {
		   			$newhash.Remove($key) | Out-Null 
				}
		   }
	   }
	}
	return $newhash
}

<#
Helper function figure out what kind of returned object to build from the results of a sql call (ds). 
Options are:
	1.  Dataset   (multiple lists of rows)
	2.  Datatable (list of datarows)
	3.  Nothing (no rows and no output variables
	4.  Dataset with output parameter dictionary
	5.  Datatable with output parameter dictionary
	6.  A dictionary of output parameters
	

#>
function Get-CommandResults{
param([Parameter(Position=0, Mandatory=$true)][System.Data.Dataset]$ds, 
      [Parameter(Position=1, Mandatory=$true)][HashTable]$outparams)   

	if ($ds.tables.count -eq 1){
		$retval= $ds.Tables[0]
	}
	elseif ($ds.tables.count -eq 0){
		$retval=$null
	} else {
		[system.Data.DataSet]$retval= $ds 
	}
	if ($outparams.Count -gt 0){
		if ($retval){
			return @{Results=$retval; OutputParameters=$outparams}
		} else {
			return $outparams
		}
	} else {
		return $retval
	}
}

<#
	.SYNOPSIS
		Create an ADO.NET command object

	.DESCRIPTION
		This function uses the information contained in the parameters to create an ADO.NET command object.  In general, you will want to use the invoke- functions directly, 
        but if you need to manipulate a command object in ways that those functions don't allow, you will need this.  

	.PARAMETER  sql
		The sql to be executed by the command object (although it is not executed by this function).

	.PARAMETER  connection
		An existing connection to perform the sql statement with.  

	.PARAMETER  parameters
		A hashtable of input parameters to be supplied with the query.  See example 2. 
        
	.PARAMETER  timeout
		The commandtimeout value (in seconds).  The command will fail and be rolled back if it does not complete before the timeout occurs.

	.PARAMETER  Server
		The server to connect to.  If both Server and Connection are specified, Server is ignored.

	.PARAMETER  Database
		The initial database for the connection.  If both Database and Connection are specified, Database is ignored.

	.PARAMETER  User
		The sql user to use for the connection.  If both User and Connection are specified, User is ignored.

	.PARAMETER  Password
		The password for the sql user named by the User parameter.

	.PARAMETER  Options
		Additional options for the connection string (specified as a hashtable)

	.PARAMETER  Transaction
		A transaction to execute the sql statement in.

	.EXAMPLE
		PS C:\> $cmd=new-command "ALTER DATABASE AdventureWorks Modify Name = Northwind" -server MyServer
        PS C:\> $cmd.ExecuteNonQuery()

    .INPUTS
        None.
        You cannot pipe objects to new-command

	.OUTPUTS
		System.Data.Common.dbCommand

#>
function New-Command{
param([Parameter(Position=0, Mandatory=$true)][Alias('storedProcName')][string]$sql,
      [Parameter(ParameterSetName="SuppliedConnection",Position=1, Mandatory=$false)][System.Data.Common.DBConnection]$connection,
      [Parameter(Position=2, Mandatory=$false)][hashtable]$parameters=@{},
      [Parameter(Position=3, Mandatory=$false)][int]$timeout=30,
      [Parameter(ParameterSetName="AdHocConnection",Position=4, Mandatory=$false)][string]$server,
      [Parameter(ParameterSetName="AdHocConnection",Position=5, Mandatory=$false)][string]$database,
      [Parameter(ParameterSetName="AdHocConnection",Position=6, Mandatory=$false)][string]$user,
      [Parameter(Position=7, Mandatory=$false)][string]$password,
      [Parameter(Position=8, Mandatory=$false)][System.Data.Common.DBTransaction]$transaction=$null,
	  [Parameter(Position=9, Mandatory=$false)][hashtable]$outparameters=@{},
      [hashtable]$options=$ADONET_Options)
   
    $dbconn=Get-Connection -conn $connection -server $server -database $database -user $user -password $password -options $options
    $close=($dbconn.State -eq [System.Data.ConnectionState]'Closed')
    if ($close) {
        $dbconn.Open()
    }	
    $cmd=$dbconn.CreateCommand()
    $cmd.CommandText=$sql
    $cmd.CommandTimeout=$timeout
    foreach($p in $parameters.Keys){
        $parm=$cmd.CreateParameter()
        $parm.ParameterName="$ADONET_ParameterPrefix$p"
        $parm.Value=$parameters[$p]
        [void]$cmd.Parameters.Add($parm) 
	    #$parm=$cmd.Parameters.AddWithValue("$ADONET_ParameterPrefix$p",$parameters[$p])
        if (Is-NULL $parameters[$p]){
           $parm.Value=[DBNull]::Value
        }
    }
    put-outputparameters $cmd $outparameters

    if ($transaction -is [System.Data.IDBTransaction]){
	$cmd.Transaction = $transaction
    }
    return $cmd


}



<#
	.SYNOPSIS
		Execute a sql statement, ignoring the result set.  Returns the number of rows modified by the statement (or -1 if it was not a DML staement)

	.DESCRIPTION
		This function executes a sql statement, using the parameters provided and returns the number of rows modified by the statement.  You may optionally 
        provide a connection or sufficient information to create a connection, as well as input parameters, command timeout value, and a transaction to join.

	.PARAMETER  sql
		The SQL Statement

	.PARAMETER  connection
		An existing connection to perform the sql statement with.  

	.PARAMETER  parameters
		A hashtable of input parameters to be supplied with the query.  See example 2. 
        
	.PARAMETER  timeout
		The commandtimeout value (in seconds).  The command will fail and be rolled back if it does not complete before the timeout occurs.

	.PARAMETER  Server
		The server to connect to.  If both Server and Connection are specified, Server is ignored.

	.PARAMETER  Database
		The initial database for the connection.  If both Database and Connection are specified, Database is ignored.

	.PARAMETER  User
		The sql user to use for the connection.  If both User and Connection are specified, User is ignored.

	.PARAMETER  Password
		The password for the sql user named by the User parameter.

	.PARAMETER  Transaction
		A transaction to execute the sql statement in.

	.PARAMETER  Options
		Additional options for the connection string (specified as a hashtable)

	.EXAMPLE
		PS C:\> invoke-sql "ALTER DATABASE AdventureWorks Modify Name = Northwind" -server MyServer


	.EXAMPLE
		PS C:\> $con=New-Connection MyServer
        PS C:\> invoke-sql "Update Table1 set Col1=null where TableID=@ID" -parameters @{ID=5}

    .INPUTS
        None.
        You cannot pipe objects to invoke-sql

	.OUTPUTS
		Integer

#>
function Invoke-Command{
param([Parameter(Position=0, Mandatory=$true)][string]$sql,
      [Parameter(ParameterSetName="SuppliedConnection",Position=1, Mandatory=$false)][System.Data.IDBConnection]$connection,
      [Parameter(Position=2, Mandatory=$false)][hashtable]$parameters=@{},
      [Parameter(Position=3, Mandatory=$false)][hashtable]$outparameters=@{},
      [Parameter(Position=4, Mandatory=$false)][int]$timeout=30,
      [Parameter(ParameterSetName="AdHocConnection",Position=5, Mandatory=$false)][string]$server,
      [Parameter(ParameterSetName="AdHocConnection",Position=6, Mandatory=$false)][string]$database,
      [Parameter(ParameterSetName="AdHocConnection",Position=7, Mandatory=$false)][string]$user,
      [Parameter(ParameterSetName="AdHocConnection",Position=8, Mandatory=$false)][string]$password,
      [Parameter(Position=9, Mandatory=$false)][System.Data.IDBTransaction]$transaction=$null,
      [hashtable]$options=$ADONET_Options)
	

      $cmd=new-command @PSBoundParameters

      $result=$cmd.ExecuteNonQuery()
       
       #if it was an ad hoc connection, close it
       if ($server){
          $cmd.connection.close()
       }	

       return $result
	
}
<#
	.SYNOPSIS
		Execute a sql statement, returning the results of the query.  

	.DESCRIPTION
		This function executes a sql statement, using the parameters provided (both input and output) and returns the results of the query.  You may optionally 
        provide a connection or sufficient information to create a connection, as well as input and output parameters, command timeout value, and a transaction to join.

	.PARAMETER  sql
		The SQL Statement

	.PARAMETER  connection
		An existing connection to perform the sql statement with.  

	.PARAMETER  parameters
		A hashtable of input parameters to be supplied with the query.  See example 2. 

	.PARAMETER  outparameters
		A hashtable of input parameters to be supplied with the query.  Entries in the hashtable should have names that match the parameter names, and string values that are the type of the parameters. See example 3. 
        
	.PARAMETER  timeout
		The commandtimeout value (in seconds).  The command will fail and be rolled back if it does not complete before the timeout occurs.

	.PARAMETER  Server
		The server to connect to.  If both Server and Connection are specified, Server is ignored.

	.PARAMETER  Database
		The initial database for the connection.  If both Database and Connection are specified, Database is ignored.

	.PARAMETER  User
		The sql user to use for the connection.  If both User and Connection are specified, User is ignored.

	.PARAMETER  Password
		The password for the sql user named by the User parameter.

	.PARAMETER  Transaction
		A transaction to execute the sql statement in.
        
	.PARAMETER  Options
		Additional options for the connection string (specified as a hashtable)

    .PARAMETER AsResult
        Specifies how you want the results of the query, as a Datarow(s), as a dataTable, a DataSet, or Dynamic to let the function look at the output and decide.
            
    .EXAMPLE
        This is an example of a query that returns a single result.  
        PS C:\> $c=New-Connection '.\sqlexpress'
        PS C:\> $res=invoke-query 'select * from master.dbo.sysdatabases' -conn $c
        PS C:\> $res 
   .EXAMPLE
        This is an example of a query that returns 2 distinct result sets.  
        PS C:\> $c=New-Connection '.\sqlexpress'
        PS C:\> $res=invoke-query 'select * from master.dbo.sysdatabases; select * from master.dbo.sysservers' -conn $c
        PS C:\> $res.Tables[1]
    .EXAMPLE
        This is an example of a query that returns a single result and uses a parameter.  It also generates its own (ad hoc) connection.
        PS C:\> invoke-query 'select * from master.dbo.sysdatabases where name=@dbname' -param  @{dbname='master'} -server '.\sqlexpress' -database 'master'

     .INPUTS
        None.
        You cannot pipe objects to invoke-query

   .OUTPUTS
        Several possibilities (depending on the structure of the query and the presence of output variables)
        1.  A list of rows 
        2.  A dataset (for multi-result set queries)
        3.  An object that contains a dictionary of ouptut parameters and their values and either 1 or 2 (for queries that contain output parameters)
#>
function Invoke-Query{
param( [Parameter(Position=0, Mandatory=$true)][string]$sql,
       [Parameter(ParameterSetName="SuppliedConnection", Position=1, Mandatory=$false)][System.Data.IDBConnection]$connection,
       [Parameter(Position=2, Mandatory=$false)][hashtable]$parameters=@{},
       [Parameter(Position=3, Mandatory=$false)][hashtable]$outparameters=@{},
       [Parameter(Position=4, Mandatory=$false)][int]$timeout=30,
       [Parameter(ParameterSetName="AdHocConnection",Position=5, Mandatory=$false)][string]$server,
       [Parameter(ParameterSetName="AdHocConnection",Position=6, Mandatory=$false)][string]$database,
       [Parameter(ParameterSetName="AdHocConnection",Position=7, Mandatory=$false)][string]$user,
       [Parameter(ParameterSetName="AdHocConnection",Position=8, Mandatory=$false)][string]$password,
       [Parameter(Position=9, Mandatory=$false)][System.Data.IDBTransaction]$transaction=$null,
       [Parameter(Position=10, Mandatory=$false)] [ValidateSet("DataSet", "DataTable", "DataRow", "Dynamic")] [string]$AsResult="Dynamic",
       [hashtable]$options=$ADONET_Options
       )
    
	$connectionparameters=copy-hashtable $PSBoundParameters -exclude AsResult
    $cmd=new-command @connectionparameters
    $ds=New-Object system.Data.DataSet
    $da=$provider.CreateDataAdapter()
    $da.SelectCommand=$cmd
    $da.fill($ds) | Out-Null
    
    #if it was an ad hoc connection, close it
    if ($server){
       $cmd.connection.close()
    }
    get-outputparameters $cmd $outparameters
    switch ($AsResult)
    {
        'DataSet'   { $result = $ds }
        'DataTable' { $result = $ds.Tables }
        'DataRow'   { $result = $ds.Tables[0] }
        'Dynamic'   { $result = get-commandresults $ds $outparameters } 
    }
    return $result
}



<#
	.SYNOPSIS
		Execute a stored procedure, returning the results of the query.  

	.DESCRIPTION
		This function executes a stored procedure, using the parameters provided (both input and output) and returns the results of the query.  You may optionally 
        provide a connection or sufficient information to create a connection, as well as input and output parameters, command timeout value, and a transaction to join.

	.PARAMETER  sql
		The SQL Statement

	.PARAMETER  connection
		An existing connection to perform the sql statement with.  

	.PARAMETER  parameters
		A hashtable of input parameters to be supplied with the query.  See example 2. 

	.PARAMETER  outparameters
		A hashtable of input parameters to be supplied with the query.  Entries in the hashtable should have names that match the parameter names, and string values that are the type of the parameters. 
        Note:  not all types are accounted for by the code. int, uniqueidentifier, varchar(n), and char(n) should all work, though.
        
	.PARAMETER  timeout
		The commandtimeout value (in seconds).  The command will fail and be rolled back if it does not complete before the timeout occurs.

	.PARAMETER  Server
		The server to connect to.  If both Server and Connection are specified, Server is ignored.

	.PARAMETER  Database
		The initial database for the connection.  If both Database and Connection are specified, Database is ignored.

	.PARAMETER  User
		The sql user to use for the connection.  If both User and Connection are specified, User is ignored.

	.PARAMETER  Password
		The password for the sql user named by the User parameter.

	.PARAMETER  Transaction
		A transaction to execute the sql statement in
        
	.PARAMETER  Options
		Additional options for the connection string (specified as a hashtable)

    .PARAMETER AsResult
        Specifies how you want the results of the stored procedure call, as a Datarow(s), as a dataTable, a DataSet, or Dynamic to let the function look at the output and decide.
            
    .EXAMPLE
        #Calling a simple stored procedure with no parameters
        PS C:\> $c=New-Connection -server '.\sqlexpress' 
        PS C:\> invoke-storedprocedure 'sp_who2' -conn $c
    .EXAMPLE 
        #Calling a stored procedure that has an output parameter and multiple result sets
        PS C:\> $c=New-Connection '.\sqlexpress'
        PS C:\> $res=invoke-storedprocedure -storedProcName 'AdventureWorks2008.dbo.stp_test' -outparameters @{LogID='int'} -conne $c
        PS C:\> $res.Results.Tables[1]
        PS C:\> $res.OutputParameters
        
        For reference, here's the stored procedure:
        CREATE procedure [dbo].[stp_test]
            @LogID int output
        as
            set @LogID=5
            select * from master.dbo.sysdatabases
            select * from master.dbo.sysservers
    .EXAMPLE 
        #Calling a stored procedure that has an input parameter
        PS C:\> invoke-storedprocedure 'sp_who2' -conn $c -parameters @{loginame='sa'}
        
    .INPUTS
        None.
        You cannot pipe objects to invoke-storedprocedure

    .OUTPUTS
        Several possibilities (depending on the structure of the query and the presence of output variables)
        1.  A list of rows 
        2.  A dataset (for multi-result set queries)
        3.  An object that contains a hashtables of ouptut parameters and their values and either 1 or 2 (for queries that contain output parameters)
#>
function Invoke-StoredProcedure{
param([Parameter(Position=0, Mandatory=$true)][string]$storedProcName,
      [Parameter(ParameterSetName="SuppliedConnection",Position=1, Mandatory=$false)][System.Data.IDBConnection]$connection,
      [Parameter(Position=2, Mandatory=$false)][hashtable] $parameters=@{},
      [Parameter(Position=3, Mandatory=$false)][hashtable]$outparameters=@{},
      [Parameter(Position=4, Mandatory=$false)][int]$timeout=30,
      [Parameter(ParameterSetName="AdHocConnection",Position=5, Mandatory=$false)][string]$server,
      [Parameter(ParameterSetName="AdHocConnection",Position=6, Mandatory=$false)][string]$database,
      [Parameter(ParameterSetName="AdHocConnection",Position=7, Mandatory=$false)][string]$user,
      [Parameter(ParameterSetName="AdHocConnection",Position=8, Mandatory=$false)][string]$password,
      [Parameter(Position=9, Mandatory=$false)][System.Data.IDBTransaction]$transaction=$null,
      [Parameter(Position=10, Mandatory=$false)] [ValidateSet("DataSet", "DataTable", "DataRow", "Dynamic")] [string]$AsResult="Dynamic",
      [hashtable]$options=$ADONET_Options) 

	$cmd=new-command @PSBoundParameters
	$cmd.CommandType=[System.Data.CommandType]::StoredProcedure  
    $ds=New-Object system.Data.DataSet
    $da=$provider.CreateDataAdapter()
    $da.SelectCommand=$cmd
    $da.fill($ds) | out-null

    get-outputparameters $cmd $outparameters
	
    switch ($AsResult)
    {
        'DataSet'   { $result = $ds }
        'DataTable' { $result = $ds.Tables }
        'DataRow'   { $result = $ds.Tables[0] }
        'Dynamic'   { $result = get-commandresults $ds $outparameters } 
    }

    #if it was an ad hoc connection, close it
    if ($server){
       $cmd.connection.close()
    }	

    
    return $result
}




export-modulemember invoke-command
export-modulemember invoke-query
export-modulemember invoke-storedprocedure
Export-ModuleMember new-Connection
Export-ModuleMember New-ConnectionString 
Export-ModuleMember new-command
Export-ModuleMember set-adonetparameters
