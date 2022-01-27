defmodule PaymentProc do
  @moduledoc """
  This module is used to process payments.
  """
  import PaymentProc.Utils, only: [get_payments: 1]
  require Logger

  def main(args \\ []) do
    Logger.info("#{inspect(__MODULE__)} start processing payments")

    {_, file_path} =
      args
      |> parse_args()

    get_payments(file_path)
    |> Flow.from_enumerables(max_demand: 10)
    |> Flow.partition(max_demand: 10, stages: 5)
    |> Flow.map(&RefElixirOpusPipeline.call/1)
    |> Enum.to_list()
  end

  def start_process(file_path) do
    get_payments(file_path)
    |> Flow.from_enumerables(max_demand: 10)
    |> Flow.partition(max_demand: 10, stages: 5)
    |> Flow.map(&RefElixirOpusPipeline.call/1)
    |> Enum.to_list()
  end

  defp parse_args(args) do
    {opts, file_path, _} =
      args
      |> OptionParser.parse(switches: [file: :boolean])

    {opts, List.to_string(file_path)}
  end
end

# Commands
# file_path = "/Users/rajesh/Learn/elixir/ref_elixir_opus_pipeline/priv/data"
# RefElixirOpusPipeline.start_process(file_path)
