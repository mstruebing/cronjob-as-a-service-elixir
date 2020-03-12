defmodule CronjobAsAServiceWeb.JobResolver do
  @moduledoc """
  This module defines the resolvers for users.
  """

  alias CronjobAsAService.Jobs

  def create(_root, args, %{context: %{current_user: current_user}}) do
    Jobs.create_job()

    %{
      command: args.command,
      schedule: args.schedule,
      last_run: DateTime.utc_now(),
      next_run: DateTime.utc_now(),
      user_id: current_user.id
    }
    |> Jobs.create_job()
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
end
