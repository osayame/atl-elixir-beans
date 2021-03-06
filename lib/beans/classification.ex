defmodule Beans.Classification do
  @moduledoc """
  Utility module to build and maintain a key-value store of bean names and their classifications.
  """
  use GenServer
  require Logger
  @classification_filename "beans_names_and_classifications.csv"

  # Startup and Initialization
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    Logger.debug("#{__MODULE__} starting...")
    state = %{
      store:         %{}
    }
    {:ok, state}
  end

  #API

  @doc """
  Primes the cache by parsing files in the `priv/data` directory
  """
  def build_store() do
    data_path = Application.app_dir(:beans, "priv/data/#{@classification_filename}")
    case File.exists?(data_path) do
      true ->
        GenServer.cast(__MODULE__, {:build_store, [data_path]})
      _ ->
        msg = "Could not parse classification file in path #{data_path}"
        Logger.warn(msg)
        {:error, msg}
    end
  end

  #Handlers

  def handle_cast({:build_store, [data_path]}, state) do
    File.stream!(data_path)
    |> Stream.filter(fn(line) -> !is_nil(line) end)
    |> Stream.filter(fn(line) -> line != "" end)
    |> Stream.map(fn(line) -> String.strip(line) end)
    |> Stream.map(fn(line) -> line |> String.split(",") end)
    |> Enum.each(fn(list) ->
      key = list |> Enum.at(0)
      value = list |> Enum.at(1)
      GenServer.cast(__MODULE__, {:add_item_to_store, [key, value]})
    end)
    {:noreply, state}
  end

  def handle_cast({:add_item_to_store, [key, val]}, state) do
    new_store = state.store |> Map.put(key, val)
    {:noreply, %{state | store: new_store}}
  end

  #Private Helpers

end
