defmodule BankRock.Transactions.Transaction do
  use Ecto.Schema
  import Ecto.Changeset
  alias BankRock.Accounts
  alias BankRock.Transactions.Transaction

  @operation_types [
    "withdraw",
    "transfer"
  ]

  @moduledoc """
    Specifies the expected struct for BankRock.Transactions.Transaction
  """

  @derive {Jason.Encoder,
           only: [:id, :operation_type, :amount, :inserted_at, :receiver_id, :payer_id]}
  @primary_key {:id, :binary_id, autogenerate: true}

  schema "transactions" do
    field(:operation_type, :string)
    field(:amount, :integer)

    timestamps(created_at: :created_at, updated_at: :updated_at)

    belongs_to(:receiver, BankRock.Accounts.Account, foreign_key: :receiver_id, type: :binary_id)
    belongs_to(:payer, BankRock.Accounts.Account, foreign_key: :payer_id, type: :binary_id)
  end

  def changeset(%Transaction{} = transaction, attrs \\ %{}) do
    transaction
    |> cast(attrs, [
      :operation_type,
      :amount,
      :payer_id,
      :receiver_id
    ])
    |> validate_required([
      :operation_type,
      :amount
    ])
    |> validate_inclusion(:operation_type, @operation_types)
    |> validate_valid_amount()
    |> validate_and_put_payer()
    |> validate_and_put_receiver()
    |> validate_account_by_transaction()
    |> unique_constraint(:id)
  end

  defp validate_valid_amount(%Ecto.Changeset{changes: %{amount: amount}} = changeset) do
    if amount < 0 do
      changeset
      |> add_error(:balance, "amount cannot be negative")
    else
      changeset
    end
  end

  defp validate_account_by_transaction(%Ecto.Changeset{valid?: false} = changeset), do: changeset

  defp validate_account_by_transaction(
         %Ecto.Changeset{changes: %{payer_id: payer_id, receiver_id: receiver_id, amount: amount}} =
           changeset
       ) do
    payer = Accounts.filter_by_uuid(payer_id)
    receiver = Accounts.filter_by_uuid(receiver_id)

    if payer == receiver do
      changeset
      |> add_error(:payer_id, "payer is equal receiver_id")
    else
      case Accounts.verify_balance(payer, amount) do
        :not_authorized ->
          changeset
          |> add_error(:amount, "this operation cannot be authorized")

        :authorized ->
          changeset
      end
    end
  end

  defp validate_account_by_transaction(
         %Ecto.Changeset{
           changes: %{payer_id: payer_id, amount: amount, operation_type: "withdraw"}
         } = changeset
       ) do
    payer = Accounts.filter_by_uuid(payer_id)

    case Accounts.verify_balance(payer, amount) do
      :not_authorized ->
        changeset
        |> add_error(:amount, "this operation cannot be authorized")

      :authorized ->
        changeset
    end
  end

  def validate_and_put_payer(%Ecto.Changeset{valid?: false} = changeset), do: changeset

  def validate_and_put_payer(%Ecto.Changeset{changes: %{payer_id: payer_id}} = changeset) do
    payer = Accounts.filter_by_uuid(payer_id)

    if Kernel.is_nil(payer) do
      changeset
      |> add_error(:payer_id, "payer not exists")
    else
      changeset
      |> put_assoc(:payer, payer)
    end
  end

  def validate_and_put_receiver(%Ecto.Changeset{valid?: false} = changeset), do: changeset

  def validate_and_put_receiver(
        %Ecto.Changeset{changes: %{receiver_id: receiver_id, operation_type: "transfer"}} =
          changeset
      ) do
    receiver = Accounts.filter_by_uuid(receiver_id)

    if Kernel.is_nil(receiver) do
      changeset
      |> add_error(:receiver_id, "receiver not exists")
    else
      changeset
      |> put_assoc(:receiver, receiver)
    end
  end

  def validate_and_put_receiver(changeset), do: changeset
end
