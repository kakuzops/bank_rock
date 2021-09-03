defmodule BankRockWeb.Guardian.AuthPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :bank,
    module: BankRock.Guardian,
    error_handler: BankRockWeb.AuthErrorHandler

  plug Guardian.Plug.VerifyHeader, realm: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
