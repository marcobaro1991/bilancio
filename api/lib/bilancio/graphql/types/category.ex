defmodule Bilancio.Graphql.Types.Category do
  @moduledoc false

  use Absinthe.Schema.Notation

  alias Bilancio.Graphql.Resolver.Category

  alias Bilancio.Graphql.Middleware.UserAuthentication

  alias Noether.Either

  object :category_queries do
    field :categories, type: non_null(list_of(:category)) do
      resolve(&Category.get_all/2)
    end
  end

  object :category_mutations do
    field :create_category, non_null(:create_category_response) do
      arg :category, non_null(:input_category)
      middleware(UserAuthentication)
      resolve(&Category.create_category/2)
    end
  end

  object :category do
    field :title, non_null(:string)

    field :color, :string

    field :identifier, non_null(:uuid) do
      resolve fn %{identifier: identifier}, _, _ ->
        identifier
        |> UUID.binary_to_string!()
        |> Either.wrap()
      end
    end
  end

  object :category_not_created, is_type_of: :create_category_response do
    field :error, non_null(:category_created_error)
  end

  input_object :input_category do
    field :title, non_null(:string)
    field :color, :string
  end

  union :create_category_response do
    types [:category, :category_not_created]

    resolve_type fn
      %{error: _}, _ -> :category_not_created
      _, _ -> :category
    end
  end

  enum :category_created_error do
    value :unknown
  end
end
