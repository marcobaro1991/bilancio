defmodule Bilancio.Application.Category do
  @moduledoc false

  alias Bilancio.Repo

  alias Bilancio.Schema.User, as: UserSchema
  alias Bilancio.Schema.Category, as: CategorySchema
  alias Bilancio.Application.User, as: UserApplication

  require Logger

  @spec get_by_id(integer() | nil) :: CategorySchema.t() | nil
  def get_by_id(nil) do
    nil
  end

  def get_by_id(id) do
    CategorySchema
    |> CategorySchema.get_by_id(id)
    |> Repo.one()
    |> case do
      res = %CategorySchema{} -> res
      _ -> nil
    end
  end

  @spec get_by_identifier(String.t() | nil) :: CategorySchema.t() | nil
  def get_by_identifier(nil) do
    nil
  end

  def get_by_identifier(identifier) do
    CategorySchema
    |> CategorySchema.get_by_identifier(UUID.string_to_binary!(identifier))
    |> Repo.one()
    |> case do
      res = %CategorySchema{} -> res
      _ -> nil
    end
  end

  @spec get_by_user_identifier(String.t()) :: [CategorySchema.t()]
  def get_by_user_identifier(user_identifier) do
    user_identifier
    |> UserApplication.get_by_identifier()
    |> case do
      %UserSchema{id: user_id} ->
        CategorySchema
        |> CategorySchema.get_all_by_user_id(user_id)
        |> Repo.all()

      _ ->
        Logger.error("User  #{inspect(user_identifier)} not found")
        []
    end
  end

  @spec create(map(), integer()) :: CategorySchema.t() | %{error: any()}
  def create(data, user_id) do
    %CategorySchema{
      user_id: user_id,
      identifier: UUID.string_to_binary!(UUID.uuid4()),
      title: data |> Map.get(:title) |> String.trim(),
      color: Map.get(data, :color, nil)
    }
    |> Repo.insert()
    |> case do
      {:ok, res = %CategorySchema{}} -> res
      {:ok, err} -> %{error: err}
    end
  end

  @spec delete_by_user_identifier(String.t()) :: :ok | :error
  def delete_by_user_identifier(user_identifier) do
    case UserApplication.get_by_identifier(user_identifier) do
      %UserSchema{id: user_id} ->
        delete_by_user_id(user_id)

      _ ->
        Logger.error("User #{inspect(user_identifier)} not found")
        :error
    end
  end

  @spec delete_by_user_id(String.t()) :: :ok | :error
  def delete_by_user_id(user_id) do
    CategorySchema
    |> CategorySchema.get_all_by_user_id(user_id)
    |> Repo.delete_all()
    |> case do
      {_, nil} -> :ok
      _ -> :error
    end
  end
end
