defmodule CronjobAsAService.Runner do
  use GenServer

  import Crontab.CronExpression

  alias CronjobAsAService.Jobs

  def start_link do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule_run()
    {:ok, state}
  end

  def handle_info(:run, state) do
    schedule_run()

    jobs = Jobs.list_runnable_jobs()
    Enum.map(jobs, fn job -> spawn(fn -> run(job) end) end)

    {:noreply, state}
  end

  defp schedule_run() do
    # Every ten seconds
    interval = 10 * 1 * 1000
    Process.send_after(self(), :run, interval)
  end

  defp run(job) do
    IO.puts("Running Job: #{job.id}")

    {_, next_run} = Crontab.Scheduler.get_next_run_date(~e[#{job.schedule}])
    Jobs.update_job(job, %{next_run: next_run, last_run: DateTime.utc_now()})
  end
end
