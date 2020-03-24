defmodule CronjobAsAServiceWeb.Schema do
  @moduledoc """
  This module defines the used GraphQL schema.
  """

  use Absinthe.Schema

  alias CronjobAsAServiceWeb.UserResolver
  alias CronjobAsAServiceWeb.JobResolver

  import_types(Absinthe.Type.Custom)

  object :user do
    field(:id, non_null(:id))
    field(:email, non_null(:string))
  end

  object :session do
    field(:token, :string)
  end

  object :job do
    field(:id, non_null(:id))
    field(:user_id, non_null(:id))
    field(:url, non_null(:string))
    field(:schedule, non_null(:string))
    field(:last_run, non_null(:datetime))
    field(:next_run, non_null(:datetime))
  end

  query do
    field :jobs, non_null(list_of(non_null(:job))) do
      resolve(&JobResolver.list/3)
    end
  end

  mutation do
    field :create_user, non_null(:user) do
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))

      resolve(&UserResolver.create/3)
    end

    field :create_job, :job do
      arg(:schedule, non_null(:string))
      arg(:url, non_null(:string))

      resolve(&JobResolver.create/3)
    end

    field :delete_job, :job do
      arg(:job_id, non_null(:id))

      resolve(&JobResolver.delete/3)
    end

    field :login, :session do
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))

      resolve(&UserResolver.login/3)
    end

    field :logout, non_null(:boolean) do
      resolve(&UserResolver.logout/3)
    end
  end
end
