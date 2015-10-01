# ---------------------------------------------------------------------------
### <Script>
### <Author>
### Mike Shepard
### </Author>
### <Description>
### Defines functions for executing Ado.net queries with the SQLServer (SQLClient) DataAccess data provider. 
### </Description>
### <Usage>
### import-module POSH_Ado_SQLServer
###  </Usage>
### </Script>
# ---------------------------------------------------------------------------

import-module POSH_Ado -args System.Data.SqlClient -Prefix SQLServer -force

function Invoke-SQLServerBulkcopy{
  param([Parameter(Mandatory=$true)]$records,
        [Parameter(Mandatory=$true)]$server,
        [string]$database,
        [string]$user,
        [string]$password,
        [Parameter(Mandatory=$true)][string]$table,
        [hashtable]$mapping=@{},
        [int]$batchsize=0,
        [System.Data.SqlClient.SqlTransaction]$transaction=$null,
        [int]$notifyAfter=0,
        [scriptblock]$notifyFunction={Write-Host "$($args[1].RowsCopied) rows copied."},
        [System.Data.SqlClient.SqlBulkCopyOptions]$options=[System.Data.SqlClient.SqlBulkCopyOptions]::Default)

	#use existing "New-Connection" function to create a connection string.        
    $connection=New-Connection -server $server -database $Database -User $user -password $password
	$connectionString = $connection.ConnectionString
	$connection.close()

	#Use a transaction if one was specified
	if ($transaction -is [System.Data.SqlClient.SqlTransaction]){
		$bulkCopy=new-object "Data.SqlClient.SqlBulkCopy" $connectionString $options  $transaction
	} else {
		$bulkCopy = new-object "Data.SqlClient.SqlBulkCopy" $connectionString
	}
	$bulkCopy.BatchSize=$batchSize
	$bulkCopy.DestinationTableName = $table
	$bulkCopy.BulkCopyTimeout=10000000
	if ($notifyAfter -gt 0){
		$bulkCopy.NotifyAfter=$notifyafter
		$bulkCopy.Add_SQlRowscopied($notifyFunction)
	}

	#Add column mappings if they were supplied
	foreach ($key in $mapping.Keys){
	    $bulkCopy.ColumnMappings.Add($mapping[$key],$key) | out-null
	}
	
	write-debug "Bulk copy starting at $(get-date)"
	if ($records -is [System.Data.Common.DBCommand]){
		#if passed a command object (rather than a datatable), ask it for a datareader to stream the records
		$bulkCopy.WriteToServer($records.ExecuteReader())
    } elsif ($records -is [System.Data.Common.DbDataReader]){
		#if passed a Datareader object use it to stream the records
		$bulkCopy.WriteToServer($records)
	} else {
		$bulkCopy.WriteToServer($records)
	}
	write-debug "Bulk copy finished at $(get-date)"
}


Export-ModuleMember *-SQLServer*
