defmodule MaxoSql.Driver.Psql do
  alias MaxoSql.Config

  def start do
    ensure_started()
    Postgrex.start_link(Config.psql_params())
  end

  defp ensure_started do
    :application.ensure_all_started(:postgrex)
  end
end
