defmodule Bilancio.Graphql.Resolver.User do
  @moduledoc false

  alias Bilancio.Application.User, as: UserApplication
  alias Bilancio.Application.Movement, as: MovementApplication

  alias Absinthe.Resolution

  alias Bilancio.Schema.User, as: UserSchema
  alias Bilancio.Schema.Movement, as: MovementSchema

  alias Noether.Either

  @spec login(map(), any()) ::
          {:ok, %{token: String.t(), identifier: String.t()} | %{error: atom()}}
  def login(_args, %Resolution{
        context: %{
          current_user: %Bilancio.Domain.User{identifier: _user_identifier},
          authorization_token: _authorization_token
        }
      }) do
    Either.wrap(%{error: :already_logged_in})
  end

  def login(%{email: email, password: password}, _info) do
    email
    |> UserApplication.login(password)
    |> Either.wrap()
  end

  @spec logout(map(), any()) :: {:ok, %{message: String.t()} | %{error: atom()}}
  def logout(_, %Resolution{
        context: %{
          current_user: %Bilancio.Domain.User{identifier: _user_identifier},
          authorization_token: authorization_token
        }
      }) do
    authorization_token
    |> UserApplication.logout()
    |> Either.wrap()
  end

  @spec deactivate(map(), any()) :: {:ok, %{message: String.t()} | %{error: atom()}}
  def deactivate(_, %Resolution{
        context: %{
          current_user: %Bilancio.Domain.User{identifier: user_identifier},
          authorization_token: authorization_token
        }
      }) do
    authorization_token
    |> UserApplication.deactivate(user_identifier)
    |> Either.wrap()
  end

  @spec me(any(), any()) :: {:ok, UserSchema.t() | nil}
  def me(_, %Resolution{
        context: %{current_user: %Bilancio.Domain.User{identifier: user_identifier}}
      }) do
    user_identifier
    |> UserApplication.get_by_identifier()
    |> Either.wrap()
  end

  @spec get_movement(map(), any()) :: {:ok, MovementSchema.t() | nil}
  def get_movement(%{identifier: movement_identifier}, %Resolution{
        context: %{
          current_user: %Bilancio.Domain.User{identifier: user_identifier},
          authorization_token: _authorization_token
        }
      }) do
    user_identifier
    |> UserApplication.get_by_identifier()
    |> case do
      %UserSchema{id: user_id} ->
        MovementApplication.get_by_identifier_and_user_id(movement_identifier, user_id)

      _ ->
        %{error: "Movement not found"}
    end
    |> Either.wrap()
  end

  @spec movements(map() | nil, any()) :: {:ok, [MovementSchema.t()]}
  def movements(%{order: order}, %Resolution{
        context: %{
          current_user: %Bilancio.Domain.User{identifier: user_identifier},
          authorization_token: _authorization_token
        }
      }) do
    user_identifier
    |> MovementApplication.get_by_user_identifier(order)
    |> Either.wrap()
  end

  def movements(_, %Resolution{
        context: %{
          current_user: %Bilancio.Domain.User{identifier: user_identifier},
          authorization_token: _authorization_token
        }
      }) do
    user_identifier
    |> MovementApplication.get_by_user_identifier()
    |> Either.wrap()
  end

  @spec create_movement(map(), any()) :: {:ok, MovementSchema.t() | %{error: String.t()}}
  def create_movement(%{movement: movement}, %Resolution{
        context: %{
          current_user: %Bilancio.Domain.User{identifier: user_identifier},
          authorization_token: _authorization_token
        }
      }) do
    user_identifier
    |> UserApplication.get_by_identifier()
    |> case do
      %UserSchema{id: user_id} -> MovementApplication.create(movement, user_id)
      _ -> %{error: :unknown}
    end
    |> Either.wrap()
  end

  @spec delete_movement(map(), any()) :: {:ok, %{message: String.t()} | %{error: String.t()}}
  def delete_movement(%{identifier: movement_identifier}, %Resolution{
        context: %{
          current_user: %Bilancio.Domain.User{identifier: user_identifier},
          authorization_token: _authorization_token
        }
      }) do
    user_identifier
    |> UserApplication.get_by_identifier()
    |> case do
      %UserSchema{id: user_id} ->
        MovementApplication.delete(movement_identifier, user_id)

      _ ->
        %{error: "Utente non trovato."}
    end
    |> Either.wrap()
  end
end
