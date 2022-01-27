defmodule ExperianCheck do
  use Opus.Pipeline
  require Logger

  require Application
  @experian_endpoint Application.compile_env(:ref_elixir_opus_pipeline, :experian_endpoint)

  # skip(:skip_record,
  #       if:
  #       {credit_requested, _} = Integer.parse(&1.credit_requested)
  #       credit_requested < 5000)
  step(:experian_check)

  def experian_check(request) do
    Logger.info("Request for Experian Check: #{inspect(request.request_id)}")

    _response =
      case HTTPoison.get!(@experian_endpoint) do
        %HTTPoison.Response{status_code: 200} ->
          %{
            request_id: request.request_id,
            request_type: "Experian Check",
            status_code: 200
          }

        _ ->
          %{
            request_id: request.request_id,
            request_type: "Experian Check",
            status_code: :error
          }
      end

    # Logger.info("Response Experian Check: #{inspect(_response)}")

    request_processed = %{
      request
      | status: "EXPERIAN_CHECK_DONE",
        activity_log: Enum.concat(request.activity_log, ["EXPERIAN_CHECK"])
    }

    request_processed
  end
end
