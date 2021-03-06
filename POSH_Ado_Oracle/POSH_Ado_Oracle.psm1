# ---------------------------------------------------------------------------
### <Script>
### <Author>
### Mike Shepard
### </Author>
### <Description>
### Defines functions for executing Ado.net queries with the Oracle DataAccess data provider. 
### </Description>
### <Usage>
### import-module POSH_Ado_Oracle
###  </Usage>
### </Script>
# ---------------------------------------------------------------------------


import-module POSH_ADO -args Oracle.DataAccess.Client -Prefix Ora -force

Set-OraADONetParameters  -ServerToken 'Data Source' -ParameterPrefix ':'

Export-ModuleMember *-Ora*
