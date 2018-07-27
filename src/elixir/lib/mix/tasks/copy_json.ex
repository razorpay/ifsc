defmodule Mix.Tasks.Ifsc.CopyJson do
  use Mix.Task


  def run(_) do
  	IO.puts("Creating priv/ifsc-data in")
  	IO.puts(File.cwd!())
    File.mkdir_p!("priv/ifsc-data")
    Enum.map(
      ~w(banknames.json IFSC.json sublet.json),
      &(File.copy("src/" <> &1, "priv/ifsc-data/" <> &1))
    )
  end
end
