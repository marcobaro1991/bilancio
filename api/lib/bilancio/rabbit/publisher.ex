defmodule Bilancio.Rabbit.Publisher do
  @moduledoc false

  alias Amqpx.Gen.Producer

  def user_deactivated(user = %{identifier: _identifier}) do
    payload =
      user
      |> Map.put_new(:occurred_on, DateTime.utc_now())
      |> Jason.encode!()

    Producer.publish("entity", "bilancio.user_deactivated", payload, type: "user_deactivated")
    {:ok, user}
  end
end
