defmodule MaxoSql.Util do
  @doc """
  like here:
  - https://www.prisma.io/docs/reference/database-reference/connection-urls
  """
  @db_types %{
    "postgresql" => :psql,
    "mysql" => :mysql
  }
  def url_to_params(url) do
    uri = URI.parse(url)

    [username, password] =
      cond do
        uri.userinfo -> String.split(uri.userinfo, ":")
        uri.userinfo == nil -> ["", ""]
      end

    hostname = uri.host
    database = String.replace_leading(uri.path, "/", "")
    port = uri.port
    type = Map.get(@db_types, uri.scheme, :sqlite)

    [
      username: username,
      password: password,
      hostname: hostname,
      database: database,
      port: port,
      type: type
    ]
  end
end
