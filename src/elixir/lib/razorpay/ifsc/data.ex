defmodule Razorpay.IFSC.Data do
  @moduledoc """
  Fetches data from the API or offline JSON files
  """

  use Memoize

  @api "https://ifsc.razorpay.com/"

  @doc """
  Load, parse and memoize the data for IFSC.json
  """
  @spec ifsc() :: {:ok, data :: map} | {:error, reason :: any}
  defmemo ifsc, do: json("IFSC")

  @doc """
  Load, parse and memoize the data for banknames.json
  """
  @spec bank() :: {:ok, data :: map} | {:error, reason :: any}
  defmemo bank, do: json("banknames")

  @doc """
  Load, parse and memoize the data for sublet.json
  """
  @spec sublet() :: {:ok, data :: map} | {:error, reason :: any}
  defmemo sublet, do: json("sublet")

  @doc """
  Fetch the JSON payload for an IFSC
  """
  @spec api(ifsc :: String.t) :: {:ok, data :: map} | {:error, reason :: any}
  def api(ifsc) do
    case api_memoized(ifsc) do
      {:ok, response} ->
        {:ok, response}
      {:error, reason} ->
        Memoize.invalidate(__MODULE__, :api_memoized, [ifsc])
        {:error, reason}
    end
  end

  defmemo api_memoized(ifsc) do
    ifsc
    |> api_uri
    |> HTTPoison.get
  end

  defp json(filename) do
    with {:ok, body} <- File.read(data_path(filename <> ".json")),
         {:ok, json} <- Poison.decode(body)
    do
      {:ok, json}
    end
  end

  defp data_path(filename) do
    :code.priv_dir(:ifsc)
    |> Path.join("./ifsc-data/")
    |> Path.join(filename)
  end

  defp api_uri(ifsc), do: URI.merge(@api, ifsc)
end
