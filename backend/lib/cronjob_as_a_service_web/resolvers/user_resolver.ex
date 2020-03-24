defmodule CronjobAsAServiceWeb.UserResolver do
  @moduledoc """
  This module defines the resolvers for users.
  """

  alias CronjobAsAService.Accounts
  alias CronjobAsAService.AuthHelper

  def create(_root, args, _info) do
    Accounts.create_user(args)
  end

  def login(_root, %{email: email, password: password}, _info) do
    with {:ok, user} <- AuthHelper.login_with_email_pass(email, password),
         {:ok, jwt, _} <- CronjobAsAService.Guardian.encode_and_sign(user),
         {:ok, _} <- CronjobAsAService.Accounts.store_token(user, jwt) do
      {:ok, %{token: jwt}}
    end
  end

  def logout(_root, _args, %{context: %{current_user: current_user}}) do
    CronjobAsAService.Accounts.revoke_token(current_user, nil)
    {:ok, true}
  end

  def logout(_root, _args, _info) do
    {:error, "Please log in first!"}
  end
end
