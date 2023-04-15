defmodule MaxoSql.Ecto.UrlParser do
  ## THE ECTO VERSION, see:
  # ecto/repo/supervisor.ex
  @integer_url_query_params ["timeout", "pool_size", "idle_interval"]
  @db_types %{
    "postgresql" => :psql,
    "mysql" => :mysql,
    "file" => :sqlite
  }

  # url = "ecto://username:password@hostname:port/database?ssl=true&timeout=1000"
  # MaxoSql.Ecto.UrlParser.parse_url(url)

  def parse_url(""), do: []

  def parse_url(url) when is_binary(url) do
    info = URI.parse(url)

    if is_nil(info.host) do
      raise Ecto.InvalidURLError, url: url, message: "host is not present"
    end

    if is_nil(info.path) or not (info.path =~ ~r"^/([^/])+$") do
      raise Ecto.InvalidURLError, url: url, message: "path should be a database name"
    end

    destructure [username, password], info.userinfo && String.split(info.userinfo, ":")
    "/" <> database = info.path

    type = Map.get(@db_types, info.scheme, :sqlite)

    url_opts = [
      scheme: info.scheme,
      username: username,
      password: password,
      database: database,
      port: info.port,
      type: type
    ]

    url_opts = put_hostname_if_present(url_opts, info.host)
    query_opts = parse_uri_query(info)

    for {k, v} <- url_opts ++ query_opts,
        not is_nil(v),
        do: {k, if(is_binary(v), do: URI.decode(v), else: v)}
  end

  defp put_hostname_if_present(keyword, "") do
    keyword
  end

  defp put_hostname_if_present(keyword, hostname) when is_binary(hostname) do
    Keyword.put(keyword, :hostname, hostname)
  end

  defp parse_uri_query(%URI{query: nil}),
    do: []

  defp parse_uri_query(%URI{query: query} = url) do
    query
    |> URI.query_decoder()
    |> Enum.reduce([], fn
      {"ssl", "true"}, acc ->
        [{:ssl, true}] ++ acc

      {"ssl", "false"}, acc ->
        [{:ssl, false}] ++ acc

      {key, value}, acc when key in @integer_url_query_params ->
        [{String.to_atom(key), parse_integer!(key, value, url)}] ++ acc

      {key, value}, acc ->
        [{String.to_atom(key), value}] ++ acc
    end)
  end

  defp parse_integer!(key, value, url) do
    case Integer.parse(value) do
      {int, ""} ->
        int

      _ ->
        raise Ecto.InvalidURLError,
          url: url,
          message: "can not parse value `#{value}` for parameter `#{key}` as an integer"
    end
  end
end
