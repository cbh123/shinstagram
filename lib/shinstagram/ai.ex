defmodule Shinstagram.AI do
  def parse_chat({:ok, %{choices: [%{"message" => %{"content" => content}} | _]}}),
    do: {:ok, content}

  def parse_chat({:error, %{"error" => %{"message" => message}}}), do: {:error, message}

  def save_r2(image_url, uuid) do
    image_binary = Req.get!(image_url).body

    file_name = "prediction-#{uuid}.png"
    bucket = System.get_env("BUCKET_NAME")

    %{status_code: 200} =
      ExAws.S3.put_object(bucket, file_name, image_binary)
      |> ExAws.request!()

    {:ok, "#{System.get_env("CLOUDFLARE_PUBLIC_URL")}/#{file_name}"}
  end

  def gen_image({:ok, image_prompt}), do: gen_image(image_prompt)

  @doc """
  Generates an image given a prompt. Returns {:ok, url} or {:error, error}.
  """
  def gen_image(image_prompt) when is_binary(image_prompt) do
    model = Replicate.Models.get!("stability-ai/stable-diffusion")

    version =
      Replicate.Models.get_latest_version!(
        model,
        "ac732df83cea7fff18b8472768c88ad041fa750ff7682a21affe81863cbe77e4"
      )

    {:ok, prediction} = Replicate.Predictions.create(version, %{prompt: image_prompt})
    {:ok, prediction} = Replicate.Predictions.wait(prediction)

    prediction.output
    |> List.first()
    |> save_r2(prediction.id)
  end

  def chat_completion(text) do
    text
    |> OpenAI.chat_completion()
    |> parse_chat()
  end
end
