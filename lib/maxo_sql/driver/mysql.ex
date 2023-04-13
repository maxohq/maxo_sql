if Code.ensure_loaded?(MyXQL) do
  defmodule MaxoSql.Driver.Mysql do
    alias MaxoSql.Config
    alias MaxoSql.ResultMapper
    alias MaxoSql.Util

    def start do
      ensure_started()
      MyXQL.start_link(Config.mysql_params())
    end

    def start(url) when is_binary(url) do
      ensure_started()
      MyXQL.start_link(Util.url_to_params(url))
    end

    def query!(pid, sql, opts \\ []) do
      MyXQL.query!(pid, sql, opts) |> ResultMapper.map()
    end

    defp ensure_started do
      :application.ensure_all_started(:myxql)
    end
  end
end
