defmodule Bilancio.Domain.User do
  @moduledoc false

  @type t :: %__MODULE__{
          identifier: String.t()
        }

  defstruct [:identifier]

  @spec create(String.t()) :: {:ok, t()} | {:error, any()}
  def create(identifier) when is_binary(identifier),
    do: {:ok, %__MODULE__{identifier: identifier}}

  def create(_), do: {:error, "invalid identifier"}

  @spec create!(String.t()) :: t()
  def create!(identifier) do
    {:ok, user} = create(identifier)
    user
  end
end
