defmodule CronjobAsAService.JobsTest do
  use CronjobAsAService.DataCase

  alias CronjobAsAService.Jobs

  describe "jobs" do
    alias CronjobAsAService.Jobs.Job

    @valid_attrs %{url: "some url", last_run: "2010-04-17 14:00:00.000000Z", next_run: "2010-04-17 14:00:00.000000Z", schedule: "some schedule"}
    @update_attrs %{url: "some updated url", last_run: "2011-05-18 15:01:01.000000Z", next_run: "2011-05-18 15:01:01.000000Z", schedule: "some updated schedule"}
    @invalid_attrs %{url: nil, last_run: nil, next_run: nil, schedule: nil}

    def job_fixture(attrs \\ %{}) do
      {:ok, job} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Jobs.create_job()

      job
    end

    test "list_jobs/0 returns all jobs" do
      job = job_fixture()
      assert Jobs.list_jobs() == [job]
    end

    test "get_job!/1 returns the job with given id" do
      job = job_fixture()
      assert Jobs.get_job!(job.id) == job
    end

    test "create_job/1 with valid data creates a job" do
      assert {:ok, %Job{} = job} = Jobs.create_job(@valid_attrs)
      assert job.url == "some url"
      assert job.last_run == DateTime.from_naive!(~N[2010-04-17 14:00:00.000000Z], "Etc/UTC")
      assert job.next_run == DateTime.from_naive!(~N[2010-04-17 14:00:00.000000Z], "Etc/UTC")
      assert job.schedule == "some schedule"
    end

    test "create_job/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Jobs.create_job(@invalid_attrs)
    end

    test "update_job/2 with valid data updates the job" do
      job = job_fixture()
      assert {:ok, job} = Jobs.update_job(job, @update_attrs)
      assert %Job{} = job
      assert job.url == "some updated url"
      assert job.last_run == DateTime.from_naive!(~N[2011-05-18 15:01:01.000000Z], "Etc/UTC")
      assert job.next_run == DateTime.from_naive!(~N[2011-05-18 15:01:01.000000Z], "Etc/UTC")
      assert job.schedule == "some updated schedule"
    end

    test "update_job/2 with invalid data returns error changeset" do
      job = job_fixture()
      assert {:error, %Ecto.Changeset{}} = Jobs.update_job(job, @invalid_attrs)
      assert job == Jobs.get_job!(job.id)
    end

    test "delete_job/1 deletes the job" do
      job = job_fixture()
      assert {:ok, %Job{}} = Jobs.delete_job(job)
      assert_raise Ecto.NoResultsError, fn -> Jobs.get_job!(job.id) end
    end

    test "change_job/1 returns a job changeset" do
      job = job_fixture()
      assert %Ecto.Changeset{} = Jobs.change_job(job)
    end
  end
end
