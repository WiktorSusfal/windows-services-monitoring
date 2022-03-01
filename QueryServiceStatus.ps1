#Login and password to remote machines
$password = "My_Password";
$user = "My_User";

#sql server instance name, Login and password to database server
$sqlPassword = "Sql_Password";
$sqlUser = "SQL_User";
$sqlInstance = "My_Instance";

$q_distinctMachines = "SELECT DISTINCT MachineName FROM Autoinfo.dbo.ServicesStatus";
$q_servicesOnMachineBase = "SELECT DISTINCT ServiceName FROM Autoinfo.dbo.ServicesStatus WHERE MachineName = ";
$q_insertStatusBase = "UPDATE Autoinfo.dbo.ServicesStatus Set DisplayName = '-ds-',  SrvStatus = '-ss-', RefreshDate = '-rs-' WHERE MachineName = '-ms-' AND ServiceName = '-sr-'";



$secPsswd = $password | ConvertTo-SecureString -AsPlainText -Force;
$C = New-Object System.Management.Automation.PSCredential -ArgumentList $user, $secPsswd

$machines = Invoke-Sqlcmd -Query $q_distinctMachines -Username $sqlUser -Password $sqlPassword -ServerInstance $sqlInstance;

$i = 0;
foreach ($iter in $machines.rows)
{
    $m = $machines[$i][0];
  
    $q_servicesOnMachine = $q_servicesOnMachineBase + "'"+ $m +"'";
    $srvices = Invoke-Sqlcmd -Query  $q_servicesOnMachine -Username $sqlUser -Password $sqlPassword -ServerInstance $sqlInstance;
    $cnt = $srvices | Measure-Object | Select -ExpandProperty "Count"

    $j = 0;
    while ($j -lt $cnt)
    {
      	IF ($cnt -eq 1)
        {
            $srvname = $srvices[$j];
        }
        ELSE
        {
            $srvname = $srvices[$j][0];
        }
     
        try{
               
	        $srvinfo = Get-WmiObject Win32_Service -computer $m -credential $C -ErrorAction Stop  | where {($_.Name -eq $srvname)};

            IF (-not $srvinfo)
            {
                $srvStatus = "Cannot Find Service On Machine";
                $srvDisp = " ";
            }
            ELSE
            {
                $srvStatus = $srvinfo | select -ExpandProperty "State";
   	            $srvDisp = $srvinfo | select -ExpandProperty "DisplayName";
            }
    
                
        }
        catch
        {
            	$srvStatus = "Cannot Connect To Machine.  ";
	$srvStatus += $Error[0].Exception;
            	$srvDisp = " ";
        }

      		
	    $q_insertStatus = $q_insertStatusBase.Replace("-ds-", $srvDisp);
       	$q_insertStatus = $q_insertStatus.Replace("-ss-", $srvStatus);
       	$q_insertStatus = $q_insertStatus.Replace("-ms-",  $m);
      	$q_insertStatus = $q_insertStatus.Replace("-sr-",  $srvname);
	
    
	    $currDate = get-date -format 'yyyy-MM-dd hh:mm:ss';
	    $q_insertStatus = $q_insertStatus.Replace("-rs-",  $currDate);


       	Invoke-Sqlcmd -Query $q_insertStatus -Username $sqlUser -Password $sqlPassword -ServerInstance $sqlInstance;
      	$j = $j + 1;
    }

    
    $i = $i + 1;
}
