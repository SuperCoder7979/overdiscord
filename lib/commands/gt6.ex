defmodule Overdiscord.Commands.GT6 do
  use Alchemy.Cogs
  alias Alchemy.{Client, Embed}
  import Embed

  # @red_embed %Embed{color: 0xd44480}
  @blue_embed %Embed{color: 0x1f95c1}

  Cogs.group("gt6")

  def get_changelog() do
    %{body: changelog, headers: headers} = HTTPoison.get!("http://gregtech.overminddl1.com/com/gregoriust/gregtech/gregtech_1.7.10/changelog.txt")
    changelog =
      String.split(changelog, "\r\n\r\n\r\n", trim: true)
      |> tl() # Remove the top message about how often the changelog is updated
      |> Enum.map(fn version_entry ->
          version_entry
          |> String.split("\r\n[", trum: true)
          |> case do
               [_] -> []
               [version_line | entries] ->
                {version, description} =
                   case String.split(version_line, ":", parts: 2) do
                     [version] -> {version, ""}
                     [version, " (Not released yet)"] -> {version, false}
                     [version, description] -> {version, description}
                   end
                 entries =
                   entries
                   |> Enum.map(fn entry ->
                       case String.split(entry, "]", parts: 2) do
                         [reason, description] -> {reason, String.trim(description)}
                         _ -> entry
                       end
                   end)
                 %{
                   version: version,
                   description: description,
                   entries: entries,
                   url: "http://gregtech.overminddl1.com/com/gregoriust/gregtech/gregtech_1.7.10/changelog.txt",
                 }
             end
    end)
    |> List.flatten()
    last_updated =
        case List.keyfind(headers, "Last-Modified", 0) do
          nil -> "Unknown"
          {_, date} -> date
        end
    %{
      changesets: changelog,
      last_updated: last_updated,
    }
  end

  def send_changeset(message, version \\ nil) do
    Client.trigger_typing(message.channel_id)
    %{changesets: changelog, last_updated: last_updated} = get_changelog()
    case version do
      nil -> hd(changelog)
      version ->
        case Enum.find(changelog, nil, &(&1.version===version)) do
          nil -> nil
          changeset -> changeset
        end
    end
    |> case do
         nil ->
           possibles =
             changelog
             |> Enum.map(&{&1.version, String.jaro_distance(&1.version, version)})
             |> Enum.sort(&(elem(&1, 1) >= elem(&2, 1)))
             |> Enum.filter(&(elem(&1, 1)>=0.1))
             |> Enum.take(4)
             |> Enum.map(&elem(&1, 0))
             |> Enum.intersperse("\n\t")
             |> Enum.join()
             |> case do
                  [] ->
                    changelog
                    |> Enum.take(4)
                    |> Enum.map(&(&1.version))
                    |> Enum.intersperse("\n\t")
                    |> Enum.join()
                  possibles -> possibles
                end
           Cogs.say("Version `#{version}` is not found\nMaybe you meant to run `!gt6 changelog` to get the latest, or perhaps you meant one of these versions?\n\t#{possibles}")
         changeset ->
           embed =
             Enum.reduce(changeset.entries, @blue_embed, fn
               entry, embed when is_binary(entry)-> field(embed, "", entry)
               {type, description}, embed -> field(embed, type, description)
             end)
             |> title("Gregtech 6 Changelog: #{changeset.version}")
             |> url(changeset.url)
             |> footer([text: "Last Updated On: #{last_updated}"])
           embed = if(changeset.description, do: description(embed, changeset.description), else: embed)
           embed
           |> Embed.send()
       end
  end

  Cogs.def changelog do
    send_changeset(message)
  end

  Cogs.def changelog version do
    send_changeset(message, version)
  end
end