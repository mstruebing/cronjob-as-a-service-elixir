defmodule CronjobAsAServiceWeb.Schema do
  @moduledoc """
  This module defines the used GraphQL schema.
  """

  use Absinthe.Schema

  alias CronjobAsAServiceWeb.UserResolver

  import_types(Absinthe.Type.Custom)

  object :user do
    field(:id, non_null(:id))
    field(:email, non_null(:string))
  end

  object :session do
    field(:token, :string)
    field(:user, :user)
  end

  mutation do
    field :create_user, :user do
      arg(:email, non_null(:string))
      arg(:password, non_null(:string))

      resolve(&UserResolver.create/3)
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
