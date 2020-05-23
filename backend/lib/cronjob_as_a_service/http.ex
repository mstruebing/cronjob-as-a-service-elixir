defmodule CronjobAsAService.Http do
  def call(method, url, body \\ "", headers \\ []) do
    url = URI.encode(url)

    case HTTPoison.request(get_method(method), url, body, headers) do
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

  defp get_method(method) do
    case method do
      "GET" ->
        :get

      "POST" ->
        :post

      "PUT" ->
        :put

      "DELETE" ->
        :delete

      "PATCH" ->
        :patch

      true ->
        raise "Not allowed request method"
    end
  end
end
