[
  locals_without_parens: [
    plug: :*,
    parse: :*,
    serialize: :*,
    value: :*,
    has_one: :*,
    has_many: :*,
    from: :*,
    get: :*,
    post: :*,
    put: :*,
    belongs_to: :*,
    pipe_through: :*,
    forward: :*,
    deprecate: :*,

    # absinthe
    field: :*,
    resolve: :*,
    arg: :*,
    list_of: :*,
    middleware: :*,
    types: :*,
    resolve_type: :*,
    import_types: :*
  ],
  import_deps: [:phoenix],
  inputs: ["*.{ex,exs}", "{config,lib,test}/**/*.{ex,exs}"],
  subdirectories: ["priv/*/migrations"]
]
