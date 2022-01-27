defmodule RefElixirOpusPipeline do
  @moduledoc """
  Documentation for `RefElixirOpusPipeline`.
  """
  use Opus.Pipeline

  link(ParseRecord)
  # skip(:skip_invalid_record, if: &(&1.status === "CLOSED"))
  link(ExperianCheck)
  link(EquifaxCheck)
  link(AMLCheck)
  link(FraudCheck)
  link(AccountBalanceCheck)
  link(CreditDecision)
end
