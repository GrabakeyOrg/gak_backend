defmodule Grabakey.UserDb do
  use Agent

  def start_link(_ \\ []) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def stop() do
    Agent.stop(__MODULE__)
  end

  def create(email) do
    case get(email) do
      nil ->
        id = Ecto.ULID.generate()
        :ok = put(id, email)
        :ok = put(email, id)
        {:ok, id}

      id ->
        {:ok, id}
    end
  end

  def get() do
    Agent.get(__MODULE__, & &1)
  end

  def get(key) do
    Agent.get(__MODULE__, &Map.get(&1, key))
  end

  def put(key, value) do
    Agent.update(__MODULE__, &Map.put(&1, key, value))
  end

  def delete(key) do
    Agent.update(__MODULE__, &Map.pop(&1, key))
  end
end
