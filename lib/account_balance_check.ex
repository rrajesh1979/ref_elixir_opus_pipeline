defmodule AccountBalanceCheck do
  use Opus.Pipeline
  require Logger

  require Application

  @account_balance_endpoint Application.compile_env(
                              :ref_elixir_opus_pipeline,
                              :account_balance_endpoint
                            )

  # skip(:skip_record,
  #       if:
  #       {credit_requested, _} = Integer.parse(&1.credit_requested)
  #       credit_requested < 5000)
  step(:account_balance_check)

  def account_balance_check(request) do
    Logger.info("Request for Account Balance Check: #{inspect(request.request_id)}")

    _response =
      case HTTPoison.get!(@account_balance_endpoint) do
        %HTTPoison.Response{status_code: 200} ->
          %{
            request_id: request.request_id,
            request_type: "Account Balance Check",
            status_code: 200
          }

        _ ->
          %{
            request_id: request.request_id,
            request_type: "Account Balance Check",
            status_code: :error
          }
      end

    # Logger.info("Response from Account Balance Check: #{inspect(_response)}")

    request_processed = %{
      request
      | status: "ACCOUNT_BALANCE_CHECK_DONE",
        activity_log: Enum.concat(request.activity_log, ["ACCOUNT_BALANCE_CHECK"])
    }

    request_processed
  end
end
