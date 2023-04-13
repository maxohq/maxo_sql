if Code.ensure_loaded?(Exqlite) do
  defmodule MaxoSql.Driver.Sqlite do
    alias MaxoSql.ResultMapper
    alias MaxoSql.Util

    def run do
      {:ok, conn} = Exqlite.Basic.open("file:blah?mode=memory&cache=shared")
      Exqlite.Basic.exec(conn, "create table test (id integer primary key, stuff text)")
      Exqlite.Basic.exec(conn, "insert into test(id, stuff) values (?, ?)", [1, "first"])
      Exqlite.Basic.exec(conn, "select * from test")

      # open another connection to that same in-memory DB
      {:ok, conn2} = Exqlite.Basic.open("file:blah?mode=memory&cache=shared")
      Exqlite.Basic.exec(conn2, "select * from test")

      # open yet another in-memory connection, but now it's fresh and does not have any tables!
      {:ok, conn3} = Exqlite.Basic.open("file:boom?mode=memory&cache=shared")
      Exqlite.Basic.exec(conn3, "select * from test")
    end

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
