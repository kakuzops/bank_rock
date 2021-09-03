defmodule BankRockWeb.Router do
  import Plug.BasicAuth
  use BankRockWeb, :router
  alias BankRockWeb.Guardian

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :basic_rock_auth do
    plug :basic_auth, Application.compile_env(:bank_rock, :bank_rock_basic_auth)
  end

  pipeline :jwt_authenticated do
    plug Guardian.AuthPipeline
  end

  forward "/health", HealthCheckup

  scope "/api", BankRockWeb do
    pipe_through :api

    post "/account/sign_up", Api.AccountController, :sign_up
    post "/account/sign_in", Api.AccountController, :sign_in
  end

  scope "/api/", BankRockWeb.Api.Report do
    pipe_through [:api, :basic_rock_auth]
    post "/report/transactions", TransactionController, :index
  end

  scope "/api/", BankRockWeb do
    pipe_through [:api, :jwt_authenticated]
    post "/transaction/create", Api.TransactionController, :create
  end

  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:fetch_session, :protect_from_forgery]
      live_dashboard "/dashboard", metrics: BankRockWeb.Telemetry
    end
  end
end
