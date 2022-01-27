defmodule CreditDecision do
  use Opus.Pipeline
  require Logger

  # skip(:skip_record,
  #       if:
  #       {credit_requested, _} = Integer.parse(&1.credit_requested)
  #       credit_requested < 5000)
  step(:credit_decision)

  def credit_decision(request) do
    Logger.info("Final decision on credit request: #{inspect(request.request_id)}")

    {credit_requested, _} = Integer.parse(request.credit_requested)
    Logger.info("Credit requested: #{inspect(credit_requested)}")

    final_decision =
      case {request.status, credit_requested} do
        {"ACCOUNT_BALANCE_CHECK_DONE", _}
        when credit_requested > 1_000_000 ->
          "REJECTED"

        {"ACCOUNT_BALANCE_CHECK_DONE", _} ->
          "EXCEPTION_REVIEW"

        _ ->
          "REJECTED"
      end

    # Logger.info("Final decision: #{inspect(final_decision)}")

    request_processed = %{
      request
      | status: final_decision,
        activity_log: Enum.concat(request.activity_log, ["CREDIT_DECISION"])
    }

    request_processed
  end
end
