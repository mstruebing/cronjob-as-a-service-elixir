defmodule CronjobAsAService.Http do
  def call(url) do
    url = URI.encode(url)

    case HTTPoison.get(url) do
      {:ok, %{status_code: status_code}} ->
        cond do
          status_code >= 200 && status_code < 400 ->
            {:ok}

          true ->
            {:error, "status code #{status_code}"}
        end

      _ ->
        {:error, "can't call url"}
    end
  end
end
