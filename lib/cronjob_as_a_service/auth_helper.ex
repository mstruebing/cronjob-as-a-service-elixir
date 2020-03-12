defmodule CronjobAsAService.AuthHelper do
  @moduledoc false

  alias CronjobAsAService.Accounts.User
  alias CronjobAsAService.Repo

  def login_with_email_pass(email, given_pass) do
    user = Repo.get_by(User, email: String.downcase(email))

    cond do
      user && Bcrypt.verify_pass(given_pass, user.password_hash) ->
        {:ok, user}

      user ->
        {:error, "Incorrect login credentials"}

      true ->
        {:error, :"User not found"}
    end
  end
end
