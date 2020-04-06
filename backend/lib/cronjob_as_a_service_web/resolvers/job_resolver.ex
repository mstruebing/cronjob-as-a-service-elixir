defmodule CronjobAsAServiceWeb.JobResolver do
  @moduledoc """
  This module defines the resolvers for users.
  """

  import Crontab.CronExpression

  alias CronjobAsAService.Jobs

  def create(_root, args, %{context: %{current_user: current_user}}) do
    {_, next_run} = Crontab.Scheduler.get_next_run_date(~e[#{args.schedule}])

    count = Jobs.count_jobs_by_user_id(current_user.id)

    if count >= 2 do
      {:error, "only two cronjobs are currently allowed"}
    else
      %{
        url: URI.encode(args.url),
        schedule: args.schedule,
        last_run: DateTime.utc_now(),
        next_run: next_run,
        user_id: current_user.id
      }
      |> Jobs.create_job()
    end
  end

  def create(_root, _args, _info) do
    {:error, "not logged in"}
  end

  def list(_root, _args, %{context: %{current_user: current_user}}) do
    {:ok, Jobs.list_jobs_by_user_id(current_user.id)}
  end

  def list(_root, _args, _info) do
    {:error, "not logged in"}
  end

  def delete(_root, %{id: id}, %{context: %{current_user: current_user}}) do
    jobs = Jobs.list_jobs_by_user_id(current_user.id)
    job = Enum.find(jobs, fn job -> job.id == String.to_integer(id) end)

    if job == nil do
      {:error, "job not owned or not found"}
    else
      Jobs.delete_job(job)
    end
  end

  def delete(_root, _args, _info) do
    {:error, "not logged in"}
  end
end
