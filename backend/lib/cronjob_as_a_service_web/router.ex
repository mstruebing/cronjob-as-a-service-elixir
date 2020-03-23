defmodule CronjobAsAServiceWeb.Router do
  use CronjobAsAServiceWeb, :router

  pipeline :api do
    plug(:accepts, ["json"])
    plug(CronjobAsAService.Context)
  end

  scope "/graphql" do
    pipe_through(:api)

    forward("/", Absinthe.Plug, schema: CronjobAsAServiceWeb.Schema)

    if Mix.env() == :dev do
      forward("/playground", Absinthe.Plug.GraphiQL,
        schema: CronjobAsAServiceWeb.Schema,
        interface: :playground,
        context: %{pubsub: CronjobAsAServiceWeb.Endpoint}
      )
    end
  end
end
