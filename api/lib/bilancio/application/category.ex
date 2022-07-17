defmodule Bilancio.Application.Category do
  @moduledoc false

  alias Bilancio.Repo

  alias Bilancio.Schema.User, as: UserSchema
  alias Bilancio.Schema.Category, as: CategorySchema
  alias Bilancio.Application.User, as: UserApplication

  require Logger

  @spec get_all_except_belogs_to_user :: [CategorySchema.t()]
  def get_all_except_belogs_to_user do
    CategorySchema
    |> CategorySchema.get_all_by_user_id(nil)
    |> Repo.all()
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
