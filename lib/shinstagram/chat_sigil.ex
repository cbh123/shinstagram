defmodule Shinstagram.ChatSigil do
  @doc """
  Implement the ~AI sigil for chat messages. Allows you to write a chat transcript
  using the format:

  ## Examples

    iex> import Shinstagram.ChatSigil
    iex> ~AI"model: gpt-3.5-turbo system: You are an expert at text to image prompts. Given a description, write a text-to-image prompt. user: sunset"
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
end
