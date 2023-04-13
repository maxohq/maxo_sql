defmodule MaxoSql.Check do
  alias MaxoSql.Driver.Mysql
  alias MaxoSql.Driver.Psql

  def mysql do
    {:ok, pid} = Mysql.start()
    Mysql.query!(pid, "select 1") |> IO.inspect()
    GenServer.stop(pid)
  end

  def psql do
    {:ok, pid} = Psql.start()
    Psql.query!(pid, "select 1") |> IO.inspect()
    GenServer.stop(pid)
  end
end
