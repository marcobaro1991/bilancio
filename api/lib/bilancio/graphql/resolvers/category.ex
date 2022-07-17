defmodule Bilancio.Graphql.Resolver.Category do
  @moduledoc false

  alias Bilancio.Application.Category, as: CategoryApplication

  alias Bilancio.Schema.Category, as: CategorySchema

  alias Bilancio.Application.User, as: UserApplication

  alias Noether.Either

  alias Bilancio.Schema.User, as: UserSchema

  alias Absinthe.Resolution

  @spec get_all(map(), any()) :: {:ok, [CategorySchema.t()]}
  def get_all(_args, _info) do
    Either.wrap(CategoryApplication.get_all_except_belogs_to_user())
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
