if Code.ensure_loaded?(Exqlite) do
  defmodule MaxoSql.Driver.Sqlite do
    alias MaxoSql.ResultMapper

    def start(url) when is_binary(url) do
      ensure_started()
      params = [database: url]
      Exqlite.start_link(params)
    end

    def query(conn, sql, opts \\ []) do
      with {:ok, res} <- Exqlite.query(conn, sql, opts) do
        {:ok, ResultMapper.map(res)}
      end
    end

    def query!(conn, sql, opts \\ []) do
      Exqlite.query!(conn, sql, opts) |> ResultMapper.map()
    end

    defp ensure_started do
      :application.ensure_all_started(:exqlite)
    end
  end
end
