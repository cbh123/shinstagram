defmodule Shinstagram.AI do
  @doc """
  Implement the ~x sigil for chat messages. Allows you to write a chat transcript
  using the format:

  ## Examples

    iex> import Shinstagram.ChatSigil
    iex> ~x"model: gpt-3.5-turbo system: You are an expert at text to image prompts. Given a description, write a text-to-image prompt. user: sunset"
    %{
      messages: [
        %{
          content: "You are an expert at text to image prompts. Given a description, write a text-to-image prompt.",
          role: "system"
        },
        %{content: "sunset", role: "user"}
      ],
      model: "gpt-3.5-turbo"
    }
  """
  import Logger

  def sigil_x(lines, _opts) do
    lines |> text_to_prompts()
  end

  def text_to_prompts(text) when is_binary(text) do
    model = extract_model(text) |> String.trim()
    messages = extract_messages(text)
    [model: model, messages: messages]
  end

  defp extract_model(text) do
    extract_value_after_keyword(text, "model:")
  end

  defp extract_messages(text) do
    keywords = ["system:", "user:", "assistant:"]

    Enum.reduce_while(keywords, [], fn keyword, acc ->
      case extract_value_after_keyword(text, keyword) do
        nil ->
          {:cont, acc}

        value ->
          role = String.trim(keyword, ":")
          acc = acc ++ [%{role: role, content: String.trim(value)}]
          {:cont, acc}
      end
    end)
  end

  defp extract_value_after_keyword(text, keyword) do
    pattern = ~r/#{keyword}\s*(.*?)(?=model:|system:|user:|assistant:|$)/s

    case Regex.run(pattern, text) do
      [_, value] -> value
      _ -> nil
    end
  end

  def parse_chat({:ok, %{choices: [%{"message" => %{"content" => content}} | _]}}) do
    {:ok, content}
  end

  def save_r2(image_url, uuid) do
    {:ok, resp} = :httpc.request(:get, {image_url, []}, [], body_format: :binary)
    {{_, 200, 'OK'}, _headers, image_binary} = resp

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
    version = Replicate.Models.get_latest_version!(model)

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
