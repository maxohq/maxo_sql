if Code.ensure_loaded?(Postgrex) do
  defmodule MaxoSql.Driver.Psql do
    alias MaxoSql.Config
    alias MaxoSql.ResultMapper
    alias MaxoSql.Util

    def start do
      ensure_started()
      Postgrex.start_link(Config.psql_params())
    end

    def start(url) when is_binary(url) do
      ensure_started()
      Postgrex.start_link(Util.url_to_params(url))
    end

    def query!(pid, sql, opts \\ []) do
      Postgrex.query!(pid, sql, opts) |> ResultMapper.map()
    end

    defp ensure_started do
      :application.ensure_all_started(:postgrex)
    end
  end
end
