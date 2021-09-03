defmodule BankRock.Accounts do
  alias BankRock.Repo
  alias BankRock.Accounts.Account
  alias BankRock.Guardian

  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]

  @moduledoc """
  Holds `BankRock.Accounts.Accounts` related functions.
  """

  @doc """
  Creates an account.
  Mandatory account properties:
    - name ( string: up to 255 chars)
    - email ( string: up to 255 chars)
    - password ( password: min 6 chars and max to 100 chars)
  """

  def create(%{} = account_params) do
    %Account{}
    |> Account.changeset(account_params)
    |> Repo.insert()
  end

  @doc """
  Updates an account.
  Only update properties:
    - balance (integer(amount in cents): min 0)
  """

  def update(%Account{} = account \\ %Account{}, attrs \\ %{}) do
    account
    |> Account.change_account(attrs)
    |> Repo.update()
  end

  @doc """
  Returns a instance of account by uuid.
  """

  def filter_by_uuid(nil), do: nil

  def filter_by_uuid(uuid), do: Repo.get(Account, uuid)

  @doc """
  Returns a instance of account by email
  """

  def filter_by_email(nil), do: nil

  def filter_by_email(email), do: Repo.get_by(Account, email: email)

  @doc """
  Verify if balance can handle with this transaction.
  """

  def verify_balance(account, amount) do
    if account.balance - amount < 0 do
      :not_authorized
    else
      :authorized
    end
  end

  @doc """
  Recalculate balance from receiver and payer account by operation.
  """

  def calculate_balance(:withdraw, account, _receiver, amount) do
    payer_balance = account.balance - amount
    {:ok, payer_balance: payer_balance, receiver_balance: nil}
  end

  def calculate_balance(:transfer, payer, receiver, amount) do
    payer_balance = payer.balance - amount
    receiver_balance = receiver.balance + amount
    {:ok, payer_balance: payer_balance, receiver_balance: receiver_balance}
  end

  def format_to_currency(account) do
    balance =
      account.balance
      |> Money.new(:BRL)
      |> Money.to_string()

    account = Map.put(account, :balance, balance)
    {:ok, account}
  end

  def token_sign_in(email, password) do
    case email_password_auth(email, password) do
      {:ok, account} ->
        Guardian.encode_and_sign(account)

      _ ->
        {:error, :unauthorized}
    end
  end

  defp email_password_auth(email, password) when is_binary(email) and is_binary(password) do
    with {:ok, account} <- get_by_email(email),
         do: verify_password(password, account)
  end

  defp get_by_email(email) when is_binary(email) do
    case Repo.get_by(Account, email: email) do
      nil ->
        dummy_checkpw()
        {:error, "Login error."}

      account ->
        {:ok, account}
    end
  end

  defp verify_password(password, %Account{} = account) when is_binary(password) do
    if checkpw(password, account.encrypted_password) do
      {:ok, account}
    else
      {:error, :invalid_password}
    end
  end
end
