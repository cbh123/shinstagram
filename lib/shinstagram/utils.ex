defmodule Shinstagram.Utils do
  def parse_chat({:ok, %{choices: [%{"message" => %{"content" => content}} | _]}}) do
    {:ok, content}
  end

  def save_r2(uuid, image_url) do
    {:ok, resp} = :httpc.request(:get, {image_url, []}, [], body_format: :binary)
    {{_, 200, 'OK'}, _headers, image_binary} = resp

    file_name = "prediction-#{uuid}.png"
    bucket = System.get_env("BUCKET_NAME")

    %{status_code: 200} =
      ExAws.S3.put_object(bucket, file_name, image_binary)
      |> ExAws.request!()

    {:ok, "#{System.get_env("CLOUDFLARE_PUBLIC_URL")}/#{file_name}"}
  end
end
