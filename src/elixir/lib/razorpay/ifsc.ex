defmodule Razorpay.IFSC do
  @moduledoc """
  Razorpay IFSC Validation Module
  """

  use Memoize

  @type t :: %__MODULE__{
    ifsc:      String.t,
    bank:      String.t | nil,
    bank_code: String.t | nil,
    branch:    String.t | nil,
    address:   String.t | nil,
    contact:   String.t | nil,
    city:      String.t | nil,
    district:  String.t | nil,
    state:     String.t | nil,
    rtgs:      boolean | nil,
  }

  @enforce_keys ~w(ifsc)a

  defstruct ~w(ifsc bank bank_code branch address contact city district state rtgs)a

  @api "https://ifsc.razorpay.com/"

  @doc """
  Fetch details about an IFSC code from the Razorpay IFSC API
  """
  @spec get(ifsc :: String.t) :: {:ok, ifsc :: __MODULE__.t} | {:error | reason :: atom}
  def get(ifsc) do
    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- api_data(ifsc),
         {:ok, json} <- Poison.decode(body)
    do
      {:ok, %__MODULE__{
        ifsc: json["IFSC"],
        bank: json["BANK"],
        bank_code: json["BANKCODE"],
        branch: json["BRANCH"],
        address: json["ADDRESS"],
        contact: json["CONTACT"],
        city: json["CITY"],
        district: json["DISTRICT"],
        state: json["STATE"],
        rtgs: json["RTGS"],
      }}
    else
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, :invalid_ifsc}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  defp api_data(ifsc) do
    case memoized_api_data(ifsc) do
      {:ok, response} ->
        {:ok, response}
      {:error, reason} ->
        Memoize.invalidate(__MODULE__, :memoized_api_data, [ifsc])
        {:error, reason}
    end
  end

  defmemo memoized_api_data(ifsc) do
    ifsc
    |> api_uri
    |> HTTPoison.get
  end

  defp api_uri(ifsc), do: URI.merge(@api, ifsc)
end
