defmodule CronjobAsAService.Accounts.User do
  @moduledoc """
  This module defines the user dataset.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias CronjobAsAService.Jobs.Job

  schema "users" do
    field(:email, :string)
    field(:password, :string, virtual: true)
    field(:password_hash, :string)
    field(:token, :string)

    has_many(:jobs, Job)

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password])
    |> validate_required([:email, :password])
    |> unique_constraint(:email, donwcase: true)
    |> put_password_hash()
  end

  def store_token_changeset(user, params \\ %{}) do
    user
    |> cast(params, [:token])
  end

  defp put_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, Bcrypt.hash_pwd_salt(pass))

      _ ->
        changeset
    end
  end
end
