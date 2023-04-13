defmodule MaxoSql.Config do
  def psql_params do
    [
      username: "postgres",
      password: "postgres",
      hostname: "127.0.0.1",
      database: "maxo_sql",
      port: 5551
    ]
  end

  def mysql_params do
    [
      username: "root",
      password: "mysql",
      hostname: "127.0.0.1",
      database: "maxo_sql",
      port: 5552,
      protocol: :tcp
    ]
  end
end
