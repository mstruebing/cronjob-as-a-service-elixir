defmodule CronjobAsAServiceWeb.Router do
  use CronjobAsAServiceWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", CronjobAsAServiceWeb do
    pipe_through :api
  end
end
