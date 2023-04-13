defmodule MaxoSql.Driver.Mysql do
  alias MaxoSql.Config

  def start do
    ensure_started()
    MyXQL.start_link(Config.mysql_params())
  end

  defp ensure_started do
    :application.ensure_all_started(:myxql)
  end
end
