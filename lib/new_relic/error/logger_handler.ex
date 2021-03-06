defmodule NewRelic.Error.LoggerHandler do
  @moduledoc false

  # http://erlang.org/doc/man/logger.html

  def add_handler() do
    :logger.remove_handler(:new_relic)
    :logger.add_handler(:new_relic, NewRelic.Error.LoggerHandler, %{})
  end

  def remove_handler() do
    :logger.remove_handler(:new_relic)
  end

  def log(
        %{
          meta: %{error_logger: %{tag: :error_report, type: :crash_report}},
          msg: {:report, %{report: [report | _]}}
        },
        _config
      ) do
    if NewRelic.Transaction.Reporter.tracking?(self()) do
      NewRelic.Error.Reporter.report_transaction_error(report)
    else
      NewRelic.Error.Reporter.report_process_error(report)
    end
  end

  def log(_log, _config), do: :ignore
end
