defmodule MaxoSql.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      MaxoSql.Repo.Registry
    ]

    opts = [strategy: :one_for_one, name: MaxoSql.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
