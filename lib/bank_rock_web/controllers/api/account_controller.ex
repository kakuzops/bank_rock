defmodule BankRockWeb.Api.AccountController do
  use BankRockWeb, :controller

  alias BankRock.Accounts
  alias BankRockWeb.ErrorView
  alias BankRock.Guardian

  @doc """
  Receives a params with this following struct:
      %{
        "account" =>
        %{
          "name" => name,
          "email" => email,
          "password" => password
        }
      }
  """

  def sign_up(conn, %{"account" => account_params}) do
    with {:ok, account} <- Accounts.create(account_params),
         {:ok, account} <- Accounts.format_to_currency(account),
         {:ok, token, _claims} = Guardian.encode_and_sign(account) do
      account =
        account
        |> Map.put(:jwt, token)

      conn
      |> put_status(:ok)
      |> json(account)
    else
      {:error, %Ecto.Changeset{valid?: false} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> put_view(ErrorView)
        |> render("422.json", changeset: changeset, root_path: "/data")

      _ ->
        conn
        |> put_status(:bad_request)
        |> put_view(ErrorView)
        |> render("400.json")
    end
  end

  def sign_up(conn, _) do
    conn
    |> put_status(:bad_request)
    |> put_view(ErrorView)
    |> render("400.json")
  end

  @doc """
  Receives a params with this following struct:
      %{
        "account" =>
        %{
          "email" => email,
          "password" => password
        }
      }
  """
  def sign_in(conn, %{"account" => %{"email" => email, "password" => password}}) do
    case Accounts.token_sign_in(email, password) do
      {:ok, token, _claims} ->
        token = %{jwt: token}

        conn
        |> put_status(:ok)
        |> json(token)

      _ ->
        conn
        |> put_status(:unauthorized)
        |> put_view(ErrorView)
        |> render("401.json")
    end
  end

  def sign_in(conn, _) do
    conn
    |> put_status(:bad_request)
    |> put_view(ErrorView)
    |> render("400.json")
  end
end
