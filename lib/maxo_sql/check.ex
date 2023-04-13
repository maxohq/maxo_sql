defmodule MaxoSql.Check do
  alias MaxoSql.Driver.Mysql
  alias MaxoSql.Driver.Psql
  alias MaxoSql.Driver.Sqlite

  def psql do
    {:ok, pid} = Psql.start("postgresql://postgres:postgres@127.0.0.1:5551/maxo_sql")
    Psql.query!(pid, "select 1") |> IO.inspect()
    GenServer.stop(pid)
  end

  def mysql do
    {:ok, pid} = Mysql.start("mysql://root:mysql@127.0.0.1:5552/maxo_sql")
    Mysql.query!(pid, "select 1") |> IO.inspect()
    GenServer.stop(pid)
  end

  def sqlite do
    # {:ok, pid} = Sqlite.start("file:./check.db")
    {:ok, pid} = Sqlite.start("file:./check.db?mode=memory&cache=shared")
    Sqlite.query!(pid, "select 1") |> IO.inspect()
    GenServer.stop(pid)
  end
end
