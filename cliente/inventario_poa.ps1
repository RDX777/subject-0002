#classe para manuseio do banco de dados
class Local
{

    [string] $_loginbanco = "subject-0002"
    [string] $_senhabanco = "subject-0002"
    [string] $_servidorbanco = "172.22.0.155"
    [string] $_portabanco = "3306"
    [string] $_nomebanco = "inventario"


    RealizaInsert([array] $resultadodoscomandos)
    {

        [void][system.reflection.Assembly]::LoadFrom(“MySql.Data.dll”)
        $sql = new-object MySql.Data.MySqlClient.MySqlConnection
        $stringdeconexao = -join("server=", $this._servidorbanco, ";port=", $this._portabanco, ";user id=", $this._loginbanco, ";password=", $this._senhabanco, ";database=", $this._nomebanco, ";pooling=false")
        $sql.ConnectionString=  $stringdeconexao
        $sql.Open()
        $sqlCmd = New-Object MySql.Data.MySqlClient.MySqlCommand 
        $sqlCmd.CommandText = "INSERT IGNORE INTO inventario_maquinas VALUES (@SerialNumber, @ComputerName, @UserName, @Domain, @Manufacturer, @Model, @TotalPhysicalMemory, @OperatingSystem, @ConsultDate) ON DUPLICATE KEY UPDATE `SerialNumber` = VALUES(`SerialNumber`), `ComputerName` = VALUES(`ComputerName`), `UserName` = VALUES(`UserName`), `Domain` = VALUES(`Domain`), `Manufacturer` = VALUES(`Manufacturer`), `Model` = VALUES(`Model`), `TotalPhysicalMemory` = VALUES(`TotalPhysicalMemory`), `OperatingSystem` = VALUES(`OperatingSystem`), `ConsultDate` = VALUES(`ConsultDate`)"
        $sqlCmd.Connection = $sql
        $sqlCmd.Prepare()

        $sqlCmd.Parameters.AddWithValue("@SerialNumber", $resultadodoscomandos.SerialNumber)
        $sqlCmd.Parameters.AddWithValue("@ComputerName", $resultadodoscomandos.ComputerName)
        $sqlCmd.Parameters.AddWithValue("@UserName", $resultadodoscomandos.UserName)
        $sqlCmd.Parameters.AddWithValue("@Domain", $resultadodoscomandos.Domain)
        $sqlCmd.Parameters.AddWithValue("@Manufacturer", $resultadodoscomandos.Manufacturer)
        $sqlCmd.Parameters.AddWithValue("@Model", $resultadodoscomandos.Model)
        $sqlCmd.Parameters.AddWithValue("@TotalPhysicalMemory", $resultadodoscomandos.TotalPhysicalMemory)
        $sqlCmd.Parameters.AddWithValue("@OperatingSystem", $resultadodoscomandos.OperatingSystem)
        $sqlCmd.Parameters.AddWithValue("@ConsultDate", $resultadodoscomandos.ConsultDate)

        $sqlCmd.ExecuteNonQuery()
        $sql.Close()

    }

}

$localinventario = [Local]::new()

$computers = @(Get-ADComputer -Server "172.28.1.18" -Filter { OperatingSystem -NotLike '*Windows Server*' } -Properties OperatingSystem, Description, CN)

foreach ($computer in $computers)
{

    If (Test-Connection -ComputerName $computer.CN -Count 1 -Quiet) {

        $bios = Get-WmiObject Win32_BIOS -ComputerName $computer.CN
        $cs = Get-WmiObject Win32_ComputerSystem -ComputerName $computer.CN

        $props = @{
            ComputerName = $computer.CN
            SerialNumber = $bios.SerialNumber
            Domain = $cs.Domain
            UserName = $cs.UserName
            Manufacturer = $cs.Manufacturer
            Model = $cs.Model
            TotalPhysicalMemory = $cs.TotalPhysicalMemory
            OperatingSystem = $computer.OperatingSystem
            ConsultDate = Get-Date -format "yyyy-MM-dd"
        }

        New-Object PsObject -Property $props

        Write-Host 'i'
        Write-Host $props

        $localinventario.RealizaInsert($props)

    }

}
