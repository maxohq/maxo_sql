defmodule MyRepo do
  use GenServer
  alias MaxoSql.DriverMapper

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(opts) do
    state = %{opts: opts}
    connect_if_possible(state)
    {:ok, state}
  end

  def connect(url) do
    params = MaxoSql.Util.url_to_params(url)
    db_type = Keyword.get(params, :type)
    driver = DriverMapper.get_driver(db_type)
    conn_pid = assert_conn!(driver.start(url), "COULD NOT CONNECT TO #{url}")
    my_pid = Process.whereis(__MODULE__)

    meta = %{
      url: url,
      conn_pid: conn_pid,
      driver: driver
    }

    if my_pid do
      MaxoSql.Repo.Registry.associate(my_pid, __MODULE__, meta)
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

  def assert_conn!(res, msg) do
    case res do
      {:ok, pid} -> pid
      _ -> raise(msg)
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

  def connect_if_possible(state) do
    cond do
      is_binary(state.opts) -> connect(state.opts)
      true -> :ok
    end
  end
end
