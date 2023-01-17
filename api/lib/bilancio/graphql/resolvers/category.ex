defmodule Bilancio.Graphql.Resolver.Category do
  @moduledoc false

  alias Bilancio.Application.Category, as: CategoryApplication

  alias Bilancio.Schema.Category, as: CategorySchema

  alias Bilancio.Application.User, as: UserApplication

  alias Noether.Either

  alias Bilancio.Schema.User, as: UserSchema

  alias Absinthe.Resolution

  @spec get(map(), any()) :: {:ok, CategorySchema.t()}
  def get(_args, %Resolution{
        source: %{category_id: category_id},
        context: %{
          current_user: %Bilancio.Domain.User{identifier: _user_identifier},
          authorization_token: _authorization_token
        }
      }) do
    category_id
    |> CategoryApplication.get_by_id()
    |> Either.wrap()
  end

  @spec get_all(map(), any()) :: {:ok, [CategorySchema.t()]}
  def get_all(_args, %Resolution{
        context: %{
          current_user: %Bilancio.Domain.User{identifier: user_identifier},
          authorization_token: _authorization_token
        }
      }) do
    user_identifier
    |> CategoryApplication.get_by_user_identifier()
    |> Either.wrap()
  end

  @spec create_category(map(), any()) :: {:ok, CategorySchema.t() | %{error: String.t()}}
  def create_category(%{category: category}, %Resolution{
        context: %{
          current_user: %Bilancio.Domain.User{identifier: user_identifier},
          authorization_token: _authorization_token
        }
      }) do
    user_identifier
    |> UserApplication.get_by_identifier()
    |> case do
      %UserSchema{id: user_id} -> CategoryApplication.create(category, user_id)
      _ -> %{error: :unknown}
    end
    |> Either.wrap()
  end
end
