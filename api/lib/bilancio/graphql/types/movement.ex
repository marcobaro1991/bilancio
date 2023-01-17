defmodule Bilancio.Graphql.Types.Movement do
  @moduledoc false

  use Absinthe.Schema.Notation

  alias Bilancio.Graphql.Resolver.Category
  alias Noether.Either

  input_object :input_movement do
    field :title, non_null(:string)
    field :description, :string
    field :value, non_null(:float)
    field :occurred_at, non_null(:date)
  end

  input_object :movements_order do
    field :by, non_null(:movements_order_by)
    field :type, non_null(:movements_order_type)
  end

  object :movement do
    field :title, non_null(:string)
    field :description, :string

    field :identifier, non_null(:uuid) do
      resolve fn %{identifier: identifier}, _, _ ->
        identifier
        |> UUID.binary_to_string!()
        |> Either.wrap()
      end
    end

    field :value, non_null(:float)
    field :occurred_at, non_null(:date)

    field :category, type: :category do
      resolve(&Category.get/2)
    end
  end

  object :movement_not_created, is_type_of: :create_movement_response do
    field :error, non_null(:movement_created_error)
  end

  object :delete_movement_success, is_type_of: :delete_movement_response do
    field :message, non_null(:string)
  end

  object :delete_movement_failure, is_type_of: :delete_movement_response do
    field :error, non_null(:string)
  end

  union :create_movement_response do
    types [:movement, :movement_not_created]

    resolve_type fn
      %{error: _}, _ -> :movement_not_created
      _, _ -> :movement
    end
  end

  union :delete_movement_response do
    types [:delete_movement_success, :delete_movement_failure]

    resolve_type fn
      %{error: _}, _ -> :delete_movement_failure
      _, _ -> :delete_movement_success
    end
  end

  enum :movement_created_error do
    value :unknown
  end

  enum :movements_order_by do
    value :occurred_at
    value :value
    value :title
  end

  enum :movements_order_type do
    value :asc
    value :desc
  end
end
