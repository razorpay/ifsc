defmodule Razorpay.IFSC do
  @moduledoc """
  Razorpay IFSC Validation Module
  """

  alias __MODULE__.Data

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

  @doc """
  Fetch details about an IFSC code from the Razorpay IFSC API
  """
  @spec get(ifsc :: String.t) :: {:ok, ifsc :: __MODULE__.t} | {:error | reason :: atom}
  def get(ifsc) do
    with {:ok, %HTTPoison.Response{status_code: 200, body: body}} <- Data.api(ifsc),
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

  @doc """
  Perform offline validation and return the bank and bank codes
  """
  @spec validate(ifsc :: String.t) :: {:ok, ifsc :: __MODULE__.t} | {:error | reason :: atom}
  def validate(ifsc) do
    ifsc = String.upcase(ifsc)

    with :ok <- validate_format(ifsc),
         :ok <- validate_bank(ifsc),
         :ok <- validate_branch(ifsc)
    do
      {:ok, %__MODULE__{
        ifsc: ifsc,
        bank: bank_name(ifsc),
        bank_code: bank_code(ifsc, :sublet),
      }}
    end
  end

  defp validate_format(ifsc) do
    if String.length(ifsc) == 11 and String.at(ifsc, 4) == "0" do
      :ok
    else
      {:error, :invalid_format}
    end
  end

  defp validate_bank(ifsc) do
    with {:ok, bank_data} <- Data.bank() do
      if Map.has_key?(bank_data, bank_code(ifsc, :regular)) do
        :ok
      else
        {:error, :invalid_bank_code}
      end
    end
  end

  defp validate_branch(ifsc) do
    with {:ok, ifsc_data} <- Data.ifsc() do
      branches = ifsc_data[bank_code(ifsc, :regular)]
      if branches && Enum.member?(branches, branch_code(ifsc)) do
        :ok
      else
        {:error, :invalid_branch_code}
      end
    end
  end

  defp bank_code(ifsc, :sublet) do
    code = bank_code(ifsc, :regular)

    with {:ok, sublet_data} <- Data.sublet() do
      sublet_data[ifsc] || code
    else
      _ -> code
    end
  end
  defp bank_code(ifsc, :regular), do: String.slice(ifsc, 0..3)

  defp branch_code(ifsc) do
    code = String.slice(ifsc, 5..-1)

    if code =~ ~r/^(\d)+$/ do
      String.to_integer(code)
    else
      String.upcase(code)
    end
  end

  defp bank_name(ifsc) do
    with {:ok, bank_data} <- Data.bank() do
      bank_data[bank_code(ifsc, :sublet)]
    else
      _ -> nil
    end
  end
end
