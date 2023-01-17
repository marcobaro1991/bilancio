defmodule Bilancio.Application.Movement do
  @moduledoc false

  alias Bilancio.Repo

  alias Bilancio.Schema.User, as: UserSchema
  alias Bilancio.Schema.Movement, as: MovementSchema
  alias Bilancio.Schema.Category, as: CategorySchema
  alias Bilancio.Application.User, as: UserApplication
  alias Bilancio.Application.Category, as: CategoryApplication

  require Logger

  @spec get_by_user_identifier(String.t(), map() | nil) :: [MovementSchema.t()]
  def get_by_user_identifier(identifier, order) do
    identifier
    |> UserApplication.get_by_identifier()
    |> case do
      %UserSchema{id: id} ->
        MovementSchema
        |> MovementSchema.get_by_user_id(id, order)
        |> Repo.all()

      _ ->
        []
    end
  end

  @spec get_by_user_identifier(String.t()) :: [MovementSchema.t()]
  def get_by_user_identifier(identifier) do
    identifier
    |> UserApplication.get_by_identifier()
    |> case do
      %UserSchema{id: id} ->
        MovementSchema
        |> MovementSchema.get_by_user_id(id, nil)
        |> Repo.all()

      _ ->
        []
    end
  end

  @spec get_by_identifier_and_user_id(String.t(), integer()) :: MovementSchema.t() | nil
  def get_by_identifier_and_user_id(identifier, user_id) do
    MovementSchema
    |> MovementSchema.get_by_identifier_and_user_id(UUID.string_to_binary!(identifier), user_id)
    |> Repo.one()
    |> case do
      res = %MovementSchema{} -> res
      _ -> nil
    end
  end

  @spec create(map(), integer()) :: MovementSchema.t() | %{error: any()}
  def create(data, user_id) do
    category_id =
      data
      |> Map.get(:category_identifier, nil)
      |> CategoryApplication.get_by_identifier()
      |> case do
        %CategorySchema{id: id} -> id
        _ -> nil
      end

    %MovementSchema{
      user_id: user_id,
      category_id: category_id,
      identifier: UUID.string_to_binary!(UUID.uuid4()),
      title: data |> Map.get(:title) |> String.trim(),
      description: data |> Map.get(:description, nil) |> format_description(),
      value: Map.get(data, :value),
      occurred_at: Map.get(data, :occurred_at)
    }
    |> Repo.insert()
    |> case do
      {:ok, res = %MovementSchema{}} -> res
      {:ok, err} -> %{error: err}
    end
  end

  @spec delete(String.t(), String.t()) :: %{message: String.t()} | %{error: any()}
  def delete(identifier, user_id) do
    with query <-
           MovementSchema.get_by_identifier_and_user_id(
             MovementSchema,
             UUID.string_to_binary!(identifier),
             user_id
           ),
         movement = %MovementSchema{} <- Repo.one(query),
         {:ok, _} <- Repo.delete(movement) do
      %{message: "Fatto!"}
    else
      _ -> %{error: "non siamo riusciti a cancellare la risorsa"}
    end
  end

  @spec delete_by_user_identifier(String.t()) :: :ok | :error
  def delete_by_user_identifier(user_identifier) do
    case UserApplication.get_by_identifier(user_identifier) do
      %UserSchema{id: user_id} ->
        delete_by_user_id(user_id)

      _ ->
        Logger.error("User  #{inspect(user_identifier)} not found")
        :error
    end
  end

  @spec delete_by_user_id(String.t()) :: :ok | :error
  def delete_by_user_id(user_id) do
    MovementSchema
    |> MovementSchema.get_by_user_id(user_id, nil)
    |> Repo.delete_all()
    |> case do
      {_, nil} -> :ok
      _ -> :error
    end
  end

  @spec format_description(String.t() | nil) :: nil | String.t()
  defp format_description(description = nil) do
    description
  end

  defp format_description(description) do
    String.trim(description)
  end
end
