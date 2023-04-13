if Code.ensure_loaded?(Exqlite) do
  defmodule MaxoSql.Driver.Sqlite do
    alias MaxoSql.ResultMapper
    alias MaxoSql.Util

    def start(url) when is_binary(url) do
      ensure_started()
      Exqlite.start_link(Util.url_to_params(url))
    end

    def query!(conn, sql, opts \\ []) do
      Exqlite.query!(conn, sql, opts) |> ResultMapper.map()
    end

    defp ensure_started do
      :application.ensure_all_started(:exqlite)
    end
  end
end
