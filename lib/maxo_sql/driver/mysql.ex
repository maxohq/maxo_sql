defmodule MaxoSql.Driver.Mysql do
  alias MaxoSql.Config
  alias MaxoSql.ResultMapper

  def start do
    ensure_started()
    MyXQL.start_link(Config.mysql_params())
  end

  def query!(pid, sql, opts \\ []) do
    MyXQL.query!(pid, sql, opts) |> ResultMapper.map()
  end

  defp ensure_started do
    :application.ensure_all_started(:myxql)
  end
end
