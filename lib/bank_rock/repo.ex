defmodule BankRock.Repo do
  use Ecto.Repo,
    otp_app: :bank_rock,
    adapter: Ecto.Adapters.Postgres

  def init(_, config) do
    repo_config =
      if is_nil(System.get_env("PGUSER")) do
        config
      else
        config
        |> Keyword.put(:username, System.get_env("PGUSER"))
        |> Keyword.put(:password, System.get_env("PGPASSWORD"))
        |> Keyword.put(:database, System.get_env("PGDATABASE"))
        |> Keyword.put(:hostname, System.get_env("PGHOST"))
        |> Keyword.put(:port, 5432)
      end

    {:ok, repo_config}
  end
end
