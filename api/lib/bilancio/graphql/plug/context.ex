defmodule Bilancio.Graphql.Plug.Context do
  @moduledoc """
    Questo modulo ha il compito di verificare la corretta forma del jwt e la relativa validità ( è expirato? è associato ad un sub ? )
  """

  alias Bilancio.Domain.User, as: UserDomain
  alias Bilancio.Graphql.Plug.Helper
  alias Bilancio.Token, as: Token

  alias Noether.Either

  @behaviour Plug

  @jwt_sign Application.compile_env!(:bilancio, :jwt)[:sign]

  @type user_context :: %{
          current_user: UserDomain.t() | nil,
          authorization_token: String.t() | nil
        }

  def init(opts), do: opts

  def call(conn, _) do
    context = conn |> get_authorization_token() |> get_user_from_token()

    Absinthe.Plug.put_options(conn, context: context)
  end

  defp get_authorization_token(conn) do
    with "Bearer " <> token <- Helper.get_header(conn, "authorization") do
      token
    end
  end

  @spec get_user_from_token(String.t() | nil) :: user_context()
  defp get_user_from_token(nil), do: jwt_not_valid()

  defp get_user_from_token(token) do
    with signer <- Joken.Signer.create(@jwt_sign, "secret"),
         now <- DateTime.truncate(DateTime.utc_now(), :second),
         {:ok, %{"sub" => sub, "exp" => exp}} <- Token.verify_and_validate(token, signer),
         exp <- exp |> DateTime.from_unix() |> Either.unwrap(),
         :lt <- DateTime.compare(now, exp) do
      %{current_user: %UserDomain{identifier: sub}, authorization_token: token}
    else
      _ -> jwt_not_valid()
    end
  end

  defp jwt_not_valid do
    %{current_user: nil, authorization_token: nil}
  end
end
