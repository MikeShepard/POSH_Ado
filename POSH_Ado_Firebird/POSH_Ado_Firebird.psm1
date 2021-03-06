# ---------------------------------------------------------------------------
### <Script>
### <Author>
### Mike Shepard
### </Author>
### <Description>
### Defines functions for executing Ado.net queries with the Firebird data provider. 
### </Description>
### <Usage>
### import-module POSH_Ado_Firebird
###  </Usage>
### </Script>
# ---------------------------------------------------------------------------

#[reflection.assembly]::LoadFrom('C:\Program Files (x86)\FirebirdClient\FirebirdSql.Data.FirebirdClient.dll')
import-module POSH_Ado -args FirebirdSql.Data.FirebirdClient -Prefix FireBird -force

Set-FirebirdADONetParameters  -ServerToken 'DataSource' -options @{Port=3050;Dialect=3;Charset='NONE'} 

Export-ModuleMember *-FireBird*
