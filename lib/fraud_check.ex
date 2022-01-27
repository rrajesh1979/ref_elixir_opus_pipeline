defmodule FraudCheck do
  use Opus.Pipeline
  require Logger

  require Application
  @fraud_check_endpoint Application.compile_env(:ref_elixir_opus_pipeline, :fraud_check_endpoint)

  # skip(:skip_record,
  #       if:
  #       {credit_requested, _} = Integer.parse(&1.credit_requested)
  #       credit_requested < 5000)
  step(:fraud_check)

  def fraud_check(request) do
    Logger.info("Request for Fraud Check: #{inspect(request.request_id)}")

    _response =
      case HTTPoison.get!(@fraud_check_endpoint) do
        %HTTPoison.Response{status_code: 200} ->
          %{
            request_id: request.request_id,
            request_type: "Fraud Check",
            status_code: 200
          }

        _ ->
          %{
            request_id: request.request_id,
            request_type: "Fraud Check",
            status_code: :error
          }
      end

    # Logger.info("Response from Fraud Check: #{inspect(_response)}")

    request_processed = %{
      request
      | status: "FRAUD_CHECK_DONE",
        activity_log: Enum.concat(request.activity_log, ["FRAUD_CHECK"])
    }

    request_processed
  end
end
