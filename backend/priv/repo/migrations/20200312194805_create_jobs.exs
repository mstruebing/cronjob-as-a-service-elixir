defmodule CronjobAsAService.Repo.Migrations.CreateJobs do
  use Ecto.Migration

  def change do
    create table(:jobs) do
      add(:url, :string)
      add(:schedule, :string)
      add(:runs, :integer)
      add(:next_run, :utc_datetime)
      add(:last_run, :utc_datetime)
      add(:user_id, references(:users, on_delete: :delete_all))

      timestamps()
    end

    create(index(:jobs, [:user_id]))
  end
end
