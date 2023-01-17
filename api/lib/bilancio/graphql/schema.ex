defmodule Bilancio.Graphql.Schema do
  @moduledoc false

  use Absinthe.Schema

  import_types Bilancio.Graphql.Types.Custom.Date
  import_types Bilancio.Graphql.Types.Custom.Uuid
  import_types Bilancio.Graphql.Types.Custom.Decimal
  import_types Bilancio.Graphql.Types.User
  import_types Bilancio.Graphql.Types.Category
  import_types Bilancio.Graphql.Types.Movement

  def context(context) do
    loader = Dataloader.new()

    Map.put(context, :loader, loader)
  end

  def plugins, do: [Absinthe.Middleware.Dataloader | Absinthe.Plugin.defaults()]

  query do
    import_fields(:user_queries)
    import_fields(:category_queries)
  end

  mutation do
    import_fields(:user_mutations)
    import_fields(:category_mutations)
  end
end
