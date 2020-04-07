defmodule CronjobAsAService.Runner do
  use GenServer

  import Crontab.CronExpression

  alias CronjobAsAService.Jobs
  alias CronjobAsAService.Http

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
    last_run = DateTime.utc_now()
    {_, next_run} = Crontab.Scheduler.get_next_run_date(~e[#{job.schedule}])

    case Http.call(job.url) do
      {:ok} ->
        IO.puts("#{job.id}: Successfull called #{job.url}")

      {:error, msg} ->
        IO.puts("#{job.id}: Failure calling #{job.url}, #{msg}")
    end

    Jobs.update_job(job, %{next_run: next_run, last_run: last_run, runs: job.runs + 1})
  end
end
