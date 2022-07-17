defmodule Bilancio.Graphql.Middleware.UserAuthentication do
  @moduledoc """
  Middleware di authenticazione andiamo a verificare se questo token è blacklistato ( è stato reso invalido da un logout)
  """

  @behaviour Absinthe.Middleware

  alias Absinthe.Resolution
  alias Bilancio.Domain.User, as: UserDomain
  alias Bilancio.Application.User, as: UserApplication
  alias Bilancio.Application.Jwt, as: JwtApplication
  alias Bilancio.Schema.User, as: UserSchema

  def call(
        resolution = %Resolution{
          context: %{
            current_user: %UserDomain{identifier: user_identifier},
            authorization_token: authorization_token
          }
        },
        _config
      )
      when is_binary(authorization_token) do
    with false <- JwtApplication.is_blacklisted(authorization_token),
         %UserSchema{} <- UserApplication.get_by_identifier_and_status(user_identifier) do
      resolution
    else
      _ -> unauthenticated(resolution)
    end
  end

  def call(resolution, _config) do
    unauthenticated(resolution)
  end

  defp unauthenticated(resolution) do
    Absinthe.Resolution.put_result(resolution, {:error, "unauthenticated"})
  end
end
