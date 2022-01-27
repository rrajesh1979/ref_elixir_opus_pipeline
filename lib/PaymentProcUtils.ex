defmodule PaymentProc.Utils do
  @doc """
  This spec defines the get_payments stage.
  """
  def get_payments(file_path) do
    file_streams =
      for file <- File.ls!(file_path) do
        File.stream!(file_path <> "/" <> file, read_ahead: 100_000)
        |> Stream.drop(1)
      end

    file_streams
  end
end
