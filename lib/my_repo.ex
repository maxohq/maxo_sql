defmodule MyRepo do
  use GenServer
  alias MaxoSql.Repo.Registry, as: RepoReg
  alias MaxoSql.Driver.Psql
  alias MaxoSql.Driver.Mysql
  alias MaxoSql.Driver.Sqlite

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(opts) do
    state = %{opts: opts}
    connect_if_possible(state)
    # {:ok, state, {:continue, :connect_if_possible}}
    {:ok, state}
  end

  def connect(url) do
    params = MaxoSql.Util.url_to_params(url)
    db_type = Keyword.get(params, :type)

    driver = get_driver(db_type)
    conn_pid = assert_conn!(driver.start(url), url)
    my_pid = Process.whereis(__MODULE__)

    meta = %{
      url: url,
      conn_pid: conn_pid,
      driver: driver
    }

    if my_pid do
      RepoReg.associate(my_pid, __MODULE__, meta)
    end
  end

  def run(%MaxoSql{} = query) do
    {sql, opts} = MaxoSql.Query.to_sql(query)
    query!(sql, opts)
  end

  def query!(sql, opts \\ []) do
    {_pid, meta} = dynamic_lookup()
    %{driver: driver, conn_pid: conn_pid} = meta
    driver.query!(conn_pid, sql, opts)
  end

  def get_driver(:psql), do: Psql
  def get_driver(:mysql), do: Mysql
  def get_driver(:sqlite), do: Sqlite
  def get_driver(type), do: raise("NOT SUPPORTED DRIVER #{type}!")

  def assert_conn!(res, url) do
    case res do
      {:ok, pid} -> pid
      _ -> raise("COULD NOT CONNECT TO #{url}")
    end
  end

  def stop do
    with {pid, meta} <- dynamic_lookup() do
      %{conn_pid: conn_pid} = meta
      GenServer.stop(conn_pid)
      GenServer.stop(pid)
    end
  end

  def dynamic_lookup do
    MaxoSql.Repo.Registry.mylookup(MyRepo) || raise "Repo not started / configured"
  end

  @impl true
  def handle_continue(:connect_if_possible, state) do
    connect_if_possible(state)

    {:noreply, state}
  end

  def connect_if_possible(state) do
    cond do
      is_binary(state.opts) -> connect(state.opts)
      true -> :ok
    end
  end
end
