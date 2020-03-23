defmodule CronjobAsAService.Context do
  @moduledoc """
  This module is a Plug which adds the current logged in user to the context.
  """

  @behaviour Plug

  import Plug.Conn
  import Ecto.Query, only: [where: 2]

  alias CronjobAsAService.Accounts.User
  alias CronjobAsAService.Repo

  def init(opts), do: opts

  def call(conn, _) do
    IO.puts("CALL")

    case build_context(conn) do
      {:ok, context} ->
        put_private(conn, :absinthe, %{context: context})

      _ ->
        conn
    end
  end

  defp build_context(conn) do
    IO.puts("BUILD_CONTEXT")

    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, current_user} <- authorize(token) do
      {:ok, %{current_user: current_user, token: token}}
    end
  end

  defp authorize(token) do
    IO.puts("AUTHORIZE")

    User
    |> where(token: ^token)
    |> Repo.one()
    |> case do
      nil -> {:error, "Invalid authorization token"}
      user -> {:ok, user}
    end
  end
end
