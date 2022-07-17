defmodule Bilancio.Application.User do
  @moduledoc false

  use Timex

  alias Bilancio.Repo
  alias Bilancio.Rabbit.Publisher, as: Publisher

  alias Bilancio.Application.Jwt, as: JwtApplication
  alias Bilancio.Schema.User, as: UserSchema
  alias Bilancio.Schema.Token, as: TokenSchema
  alias Bilancio.Application.Movement, as: MovementApplication
  alias Bilancio.Application.Category, as: CategoryApplication

  require Logger

  @spec login(String.t(), String.t()) ::
          %{token: String.t(), identifier: String.t()} | %{error: atom()}
  def login(email, password) do
    UserSchema
    |> UserSchema.get_by_email_and_password(email, encode_password(password), :active)
    |> Repo.one()
    |> JwtApplication.generate_jwt()
  end

  @spec logout(String.t()) :: %{message: String.t()} | %{error: atom()}
  def logout(token) do
    token
    |> JwtApplication.get_by_value()
    |> case do
      %TokenSchema{} -> JwtApplication.set_to_blacklist(token)
      _ -> %{error: :token_not_stored}
    end
  end

  @spec deactivate(String.t(), String.t()) :: %{message: String.t()} | %{error: atom()}
  def deactivate(token, identifier) do
    with user = %UserSchema{} <- get_by_identifier(identifier),
         {:ok, user_updated} <- update(user, %{status: :not_active}),
         %{message: _} <- logout(token) do
      %{
        identifier: user_updated |> Map.get(:identifier) |> UUID.binary_to_string!()
      }
      |> Publisher.user_deactivated()
      |> case do
        _ -> %{message: "done"}
      end
    else
      _ -> %{error: :unknown}
    end
  end

  @spec delete(String.t()) :: :ok | :error
  def delete(user_identifier) do
    results =
      ParallelTask.new()
      |> ParallelTask.add(
        first_task: fn ->
          MovementApplication.delete_by_user_identifier(user_identifier)
        end
      )
      |> ParallelTask.add(
        second_task: fn ->
          CategoryApplication.delete_by_user_identifier(user_identifier)
        end
      )
      |> ParallelTask.perform()

    user_identifier = UUID.string_to_binary!(user_identifier)

    with %{first_task: :ok, second_task: :ok} <- results,
         query <- UserSchema.get_by_identifier(UserSchema, user_identifier),
         user = %UserSchema{} <- Repo.one(query),
         {:ok, _} <- Repo.delete(user) do
      :ok
    else
      _ -> :error
    end
  end

  @spec get_by_identifier(String.t()) :: UserSchema.t() | nil
  def get_by_identifier(identifier) do
    UserSchema
    |> UserSchema.get_by_identifier(UUID.string_to_binary!(identifier))
    |> Repo.one()
  end

  @spec update(UserSchema.t(), map()) :: {:ok | :error, UserSchema.t()}
  defp update(schema, attrs) do
    schema
    |> UserSchema.update_changeset(attrs)
    |> Repo.update()
  end

  @spec get_by_identifier_and_status(String.t(), atom()) :: UserSchema.t() | nil
  def get_by_identifier_and_status(identifier, status \\ :active) do
    UserSchema
    |> UserSchema.get_by_identifier_and_status(UUID.string_to_binary!(identifier), status)
    |> Repo.one()
  end

  @spec encode_password(String.t()) :: String.t()
  def encode_password(password) do
    :md5
    |> :crypto.hash(password)
    |> Base.encode64()
  end
end
