defmodule BankRock.Repo.Migrations.CreateTransactionsTable do
  use Ecto.Migration

  def change do
    create table(:transactions, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :operation_type, :string, null: false
      add(:payer_id, references("accounts", type: :binary_id), null: false)
      add(:receiver_id, references("accounts", type: :binary_id), null: true)
      add :amount, :integer, default: 0

      timestamps()
    end

    create(index("transactions", [:payer_id, :receiver_id]))
  end
end
