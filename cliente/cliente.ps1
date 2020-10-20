#classe para manuseio do banco de dados
class Local
{

    [string] $_loginbanco = "subject-0002"
    [string] $_senhabanco = "subject-0002"
    [string] $_servidorbanco = "172.22.0.155"
    [string] $_portabanco = "3306"
    [string] $_nomebanco = "inventario"


    [array] RealizaSelect([string] $query, [string] $allorone)
    {
        [void][system.reflection.Assembly]::LoadFrom(“MySql.Data.dll”)
        $sql = new-object MySql.Data.MySqlClient.MySqlConnection
        $stringdeconexao = -join("server=", $this._servidorbanco, ";port=", $this._portabanco, ";user id=", $this._loginbanco, ";password=", $this._senhabanco, ";database=", $this._nomebanco, ";pooling=false")
        $sql.ConnectionString=  $stringdeconexao
        
        $sqlCmd = New-Object MySql.Data.MySqlClient.MySqlCommand
        $sqlCmd.CommandText = $query
        $sqlCmd.Connection = $sql
        $sql.Open()
        $sqlReader = $sqlcmd.ExecuteReader()

        if ($allorone -eq 'all')
        {

            $vetor = New-Object System.Collections.ArrayList

            while($sqlReader.Read()){
                $hashable = @{}
                for ($i= 0; $i -lt $sqlReader.FieldCount; $i++) {
                    $hashable.Add($sqlReader.GetName($i), $sqlReader[$i])
                }

                $a = $vetor.Add($hashable)

                Remove-Variable -name hashable

            }
        }
        elseif ($allorone -eq 'one')
        {
            $sqlReader.Read()
            $vetor = @{}
            for ($i= 0; $i -lt $sqlReader.FieldCount; $i++) {
                $vetor.Add($sqlReader.GetName($i), $sqlReader[$i])
            }

        }
        $sql.Close()
        return $vetor
    }

    RealizaInsert([array] $resultadodoscomandos)
    {

        [void][system.reflection.Assembly]::LoadFrom(“MySql.Data.dll”)
        $sql = new-object MySql.Data.MySqlClient.MySqlConnection
        $stringdeconexao = -join("server=", $this._servidorbanco, ";port=", $this._portabanco, ";user id=", $this._loginbanco, ";password=", $this._senhabanco, ";database=", $this._nomebanco, ";pooling=false")
        $sql.ConnectionString=  $stringdeconexao
        $sql.Open()
        $sqlCmd = New-Object MySql.Data.MySqlClient.MySqlCommand 
        $sqlCmd.CommandText = "INSERT IGNORE INTO computadores VALUES (@serial_number, @hostname, @sistema_operacional) ON DUPLICATE KEY UPDATE `serial_number` = VALUES(`serial_number`), `hostname` = VALUES(`hostname`), `sistema_operacional` = VALUES(`sistema_operacional`)"
        $sqlCmd.Connection = $sql
        $sqlCmd.Prepare()
        $sqlCmd.Parameters.AddWithValue("@serial_number", $resultadodoscomandos.serial_number)
        $sqlCmd.Parameters.AddWithValue("@hostname", $resultadodoscomandos.hostname)
        $sqlCmd.Parameters.AddWithValue("@sistema_operacional", $resultadodoscomandos.sistema_operacional)

        $sqlCmd.ExecuteNonQuery()
        $sql.Close()

    }

}

#listagem e execução dos comandos
$c = [Local]::new()

$comandos = $c.RealizaSelect("select * from comandos where sistema_operacional = 'windows' and linguagem = 'powershell' and status = '1'", 'all')

#pegar informações, necessario array como devolutiva do processo
$resultadodoscomandos = @{}
foreach ($comando in $comandos)
{
    $retornocomando = Invoke-Expression $comando.linha_de_comando.ToString()
    $bancocomando = $comando.banco_comando_indice.ToString()

    $resultadodoscomandos.Add($bancocomando, $retornocomando)

    Start-Sleep -Seconds 0.1
} 

$c.RealizaInsert($resultadodoscomandos)

#inserir no banco informações
