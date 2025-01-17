defmodule CronjobAsAService.Jobs.Job do
  use Ecto.Schema
  import Ecto.Changeset

  schema "jobs" do
    field(:url, :string)
    field(:method, :string)
    field(:body, :string)
    field(:last_run, :utc_datetime)
    field(:next_run, :utc_datetime)
    field(:schedule, :string)
    field(:runs, :integer)

    belongs_to(:user, User, foreign_key: :user_id)

    timestamps()
  end

  @doc false
  def changeset(job, attrs) do
    job
    |> cast(attrs, [:url, :schedule, :next_run, :last_run, :user_id, :runs, :method, :body])
    |> validate_required([:url, :schedule, :next_run, :last_run, :user_id, :runs, :method])
    |> validate_inclusion(:method, ["GET", "POST", "PUT", "DELETE", "PATCH"])
  end
end
