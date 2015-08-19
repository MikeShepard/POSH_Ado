# ---------------------------------------------------------------------------
### <Script>
### <Author>
### Mike Shepard
### </Author>
### <Description>
### Defines functions for executing Ado.net queries with the MySQL data provider.  You may need to be on version
### 5.0.8.1 for the command timeout to work.
### </Description>
### <Usage>
### import-module mysqllib
###  </Usage>
### </Script>
# ---------------------------------------------------------------------------


import-module adonetlib -args MySql.Data.MySqlClient -Prefix MySQL -force

# .NET (and PowerShell) do not like zero datetime values by default.  This option helps with that.
# http://dev.mysql.com/doc/refman/5.5/en/connector-net-connection-options.html
Set-MySQLADONetParameters -option @{'Allow Zero Datetime'='true'} -ParameterPrefix ''

Export-ModuleMember *-MySQL*
