defmodule Mix.Tasks.Ifsc.CopyJson do
  use Mix.Task

  def run(_) do
    File.mkdir_p!("priv/ifsc-data")
    Enum.map(
      ~w(banknames.json IFSC.json sublet.json banks.json),
      &(File.copy("src/" <> &1, "priv/ifsc-data/" <> &1))
    )
  end
end
