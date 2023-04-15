defmodule MaxoSql.Util do
  @doc """
  like here:
  - https://www.prisma.io/docs/reference/database-reference/connection-urls
  """
  @db_types %{
    "postgresql" => :psql,
    "mysql" => :mysql,
    "file" => :sqlite
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
    type = Map.get(@db_types, uri.scheme)

    query_opts = parse_uri_query(uri)

    url_opts = [
      username: username,
      password: password,
      hostname: hostname,
      database: database,
      port: port,
      type: type
    ]

    for {k, v} <- url_opts ++ query_opts,
        not is_nil(v),
        do: {k, if(is_binary(v), do: URI.decode(v), else: v)}
  end

  defp parse_uri_query(%URI{query: nil}),
    do: []

  defp parse_uri_query(%URI{query: query}) do
    query
    |> URI.query_decoder()
    |> Enum.reduce([], fn
      {"ssl", "true"}, acc ->
        [{:ssl, true}] ++ acc

      {"ssl", "false"}, acc ->
        [{:ssl, false}] ++ acc

      {key, value}, acc ->
        [{String.to_atom(key), value}] ++ acc
    end)
  end
end
