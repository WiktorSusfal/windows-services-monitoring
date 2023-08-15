# windows-services-monitoring

Solution based on MS SQL database server and Powershell script. 
User inserts into [dbo].[ServicesStatus] table info about windows services that need to be monitored. Then, Powershell script queries given services on given machines and updates information about their statuses in [dbo].[ServicesStatus] table. Powershell script runs as a MS SQL JOB. Second step of the job executes T-SQL stored procedure that checks information from the table and send mail alerts with list of non-running services. 
Solution requires a mail profile configured in MS SQL Server and SQL Server Agent running. 

Table [dbo].[ServicesStatus]  consists of columns: [MachineName] [varchar](100) NOT NULL, [ServiceName] [varchar](100) NOT NULL, [DisplayName] [nvarchar](500) NULL, [SrvStatus] [varchar](50) NULL [RefreshDate] [varchar](30) NULL. User need to input values for MachineName nad ServiceName columns. Rest of the columns are being updated automatically by powershell script.

INSTALLATION:

* Create DB Mail Profile.
* Create [dbo].[ServicesStatus] table - run query from file "CreateTable for services status monitoring.sql".
* Create procedure for mail alerts - run query from file "StoppedServices - Send Mail Alerts.sql".
* Create new SQL JOB with necessary execution interval. In the first step paste the Powershell code from file "QueryServiceStatus.ps1". Assign values to variables at the beginning of file that stores password and username to machines with services, password and username and name of SQL instance under the job is running.
* Create second step of JOB - for stored procedure from pt. 3 execution. 
