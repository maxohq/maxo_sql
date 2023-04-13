defmodule MaxoSql.Driver.Psql do
  alias MaxoSql.Config
  alias MaxoSql.ResultMapper

  def start do
    ensure_started()
    Postgrex.start_link(Config.psql_params())
  end

  def query!(pid, sql, opts \\ []) do
    Postgrex.query!(pid, sql, opts) |> ResultMapper.map()
  end

  defp ensure_started do
    :application.ensure_all_started(:postgrex)
  end
end
