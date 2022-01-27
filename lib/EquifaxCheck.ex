defmodule EquifaxCheck do
  use Opus.Pipeline
  require Logger

  require Application
  @equifax_endpoint Application.compile_env(:ref_elixir_opus_pipeline, :equifax_endpoint)

  # skip(:skip_record,
  #       if:
  #       {credit_requested, _} = Integer.parse(&1.credit_requested)
  #       credit_requested < 5000)
  step(:equifax_check)

  def equifax_check(request) do
    Logger.info("Request for Equifax Check: #{inspect(request.request_id)}")

    _response =
      case HTTPoison.get!(@equifax_endpoint) do
        %HTTPoison.Response{status_code: 200} ->
          %{
            request_id: request.request_id,
            request_type: "Equifax Check",
            status_code: 200
          }

        _ ->
          %{
            request_id: request.request_id,
            request_type: "Equifax Check",
            status_code: :error
          }
      end

    # Logger.info("Response from Equifax Check: #{inspect(_response)}")

    request_processed = %{
      request
      | status: "EQUIFAX_CHECK_DONE",
        activity_log: Enum.concat(request.activity_log, ["EQUIFAX_CHECK"])
    }

    request_processed
  end
end
