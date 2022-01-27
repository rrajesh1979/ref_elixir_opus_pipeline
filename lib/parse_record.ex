defmodule ParseRecord do
  use Opus.Pipeline

  @moduledoc """
  This module parses the record data from the input file.
  """

  require Logger
  alias NimbleCSV.RFC4180, as: CSV

  step(:parse_record)

  def parse_record(row) do
    Logger.info("Parsing record: #{row}")
    [row] = CSV.parse_string(row, skip_headers: false)

    %{
      request_id: Enum.at(row, 0),
      name: Enum.at(row, 1),
      credit_requested: Enum.at(row, 2),
      requested_date: Enum.at(row, 3),
      location: Enum.at(row, 4),
      status: "NEW_REQUEST",
      activity_log: ["REQUEST_CREATED"]
    }
  end
end
