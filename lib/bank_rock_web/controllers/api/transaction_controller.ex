defmodule BankRockWeb.Api.TransactionController do
  use BankRockWeb, :controller
  alias BankRock.Transactions
  alias BankRockWeb.ErrorView

  @doc """
  Receives a params with this following struct:
      %{
        "transaction" =>
        %{
          "operation_type" => operation_type,
          "amount" => amount (in cents) ,
          "receiver_id" => receiver_id (only when operation_type is transfer)
        }
      }
  """
  def create(conn, %{"transaction" => transaction_params}) do
    with {:ok, transaction_params} <-
           Transactions.put_payer_id(
             transaction_params,
             Guardian.Plug.current_resource(conn)
           ),
         {:ok, transaction} <- Transactions.create_and_update_account_balance(transaction_params),
         {:ok, transaction} <- Transactions.format_to_currency(transaction, :transaction) do
      conn
      |> put_status(:ok)
      |> json(transaction)
    else
      {:error, {:create_transaction, %Ecto.Changeset{valid?: false} = changeset, _infos}} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(ErrorView)
        |> render("422.json", changeset: changeset, root_path: "/data")

      {:error, _result} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(ErrorView)
        |> render("422.json", changeset: :something_went_wrong)

      _ ->
        conn
        |> put_status(:bad_request)
        |> put_view(ErrorView)
        |> render("400.json")
    end
  end

  def create(conn, _) do
    conn
    |> put_status(:bad_request)
    |> put_view(ErrorView)
    |> render("400.json")
  end
end
