defmodule BankRock.Repo.Migrations.CreateAccountsTable do
  use Ecto.Migration

  def change do
    create table(:accounts, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string, null: false
      add :email, :string, null: false
      add :encrypted_password, :string, null: false
      add :balance, :integer, default: 0

      timestamps()
    end
  end
end
