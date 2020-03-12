defmodule CronjobAsAService.Jobs.Job do
  use Ecto.Schema
  import Ecto.Changeset

  schema "jobs" do
    field(:command, :string)
    field(:last_run, :utc_datetime)
    field(:next_run, :utc_datetime)
    field(:schedule, :string)

    belongs_to(:user, User, foreign_key: :user_id)

    timestamps()
  end

  @doc false
  def changeset(job, attrs) do
    job
    |> cast(attrs, [:command, :schedule, :next_run, :last_run, :user_id])
    |> validate_required([:command, :schedule, :next_run, :last_run, :user_id])
  end
end
