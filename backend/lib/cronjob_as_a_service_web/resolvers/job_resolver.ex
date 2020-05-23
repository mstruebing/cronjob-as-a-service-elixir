defmodule CronjobAsAServiceWeb.JobResolver do
  @moduledoc """
  This module defines the resolvers for users.
  """

  import Crontab.CronExpression

  alias CronjobAsAService.Jobs

  def create(_root, args, %{context: %{current_user: current_user}}) do
    count = Jobs.count_jobs_by_user_id(current_user.id)

    cond do
      args.url == "" ->
        {:error, "url can't be empty"}

      args.schedule == "" ->
        {:error, "schedule can't be empty"}

      count >= 2 ->
        {:error, "only two cronjobs are currently allowed"}

      !Enum.member?(["GET", "POST", "PUT", "DELETE", "PATCH"], args.method) ->
        {:error, "#{args.method} is not a valid http method to use"}

      true ->
        try do
          {_, next_run} = Crontab.Scheduler.get_next_run_date(~e[#{args.schedule}])

          %{
            url: URI.encode(args.url),
            method: args.method,
            body: args.body,
            schedule: args.schedule,
            last_run: DateTime.utc_now(),
            next_run: next_run,
            user_id: current_user.id,
            runs: 0
          }
          |> Jobs.create_job()
        rescue
          x -> {:error, "not a valid crontab string"}
        end
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

  def count(_root, _args, _info) do
    {:ok, Jobs.count_jobs()}
  end

  def runs(_root, _args, _info) do
    {:ok, Jobs.runs()}
  end
end
