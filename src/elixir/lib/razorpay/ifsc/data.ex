defmodule Razorpay.IFSC.Data do
  use Memoize

  @path "./src/"
  @api "https://ifsc.razorpay.com/"

  defmemo ifsc, do: json("IFSC")
  defmemo bank, do: json("banknames")
  defmemo sublet, do: json("sublet")

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
    with {:ok, body} <- File.read(@path <> filename <> ".json"),
         {:ok, json} <- Poison.decode(body)
    do
      {:ok, json}
    end
  end

  defp api_uri(ifsc), do: URI.merge(@api, ifsc)
end
