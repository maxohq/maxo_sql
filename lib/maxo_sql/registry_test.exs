defmodule MaxoSql.RegistyTest do
  use ExUnit.Case
  use MnemeDefaults

  test "full cycle" do
    {:ok, pid} = MaxoSql.Driver.Psql.start()
    MaxoSql.Repo.Registry.associate(pid, PsqlRepo, PsqlRepo)
    auto_assert([PsqlRepo] <- MaxoSql.Repo.Registry.all_running())
    auto_assert(^pid when is_pid(pid) <- MaxoSql.Repo.Registry.mylookup(PsqlRepo))

    GenServer.stop(pid)

    require WaitForIt

    res =
      case WaitForIt.wait(MaxoSql.Repo.Registry.all_running() == [], frequency: 1) do
        true -> []
        _ -> {:error, :nope}
      end

    auto_assert([] <- MaxoSql.Repo.Registry.all_running())
  end
end
