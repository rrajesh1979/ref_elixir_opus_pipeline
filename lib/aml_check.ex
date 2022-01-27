defmodule AMLCheck do
  use Opus.Pipeline
  require Logger

  require Application
  @aml_check_endpoint Application.compile_env(:ref_elixir_opus_pipeline, :aml_check_endpoint)

  # skip(:skip_record,
  #       if:
  #       {credit_requested, _} = Integer.parse(&1.credit_requested)
  #       credit_requested < 5000)
  step(:aml_check)

  def aml_check(request) do
    Logger.info("Request for AML Check: #{inspect(request.request_id)}")

    _response =
      case HTTPoison.get!(@aml_check_endpoint) do
        %HTTPoison.Response{status_code: 200} ->
          %{
            request_id: request.request_id,
            request_type: "AML Check",
            status_code: 200
          }

        _ ->
          %{
            request_id: request.request_id,
            request_type: "AML Check",
            status_code: :error
          }
      end

    # Logger.info("Response from AML Check: #{inspect(_response)}")

    request_processed = %{
      request
      | status: "AML_CHECK_DONE",
        activity_log: Enum.concat(request.activity_log, ["AML_CHECK"])
    }

    request_processed
  end
end
