defmodule Utils do
  def timestamp do
    :os.system_time(:seconds)
  end

  def domain(link) do
    case URI.parse(link) do
      %URI{authority: domain} when is_binary(domain) -> {:ok, domain}
      _ ->
        case URI.parse("http://" <> link) do
          %URI{authority: domain} when is_binary(domain) -> {:ok, domain}
          _ -> nil
        end
    end
  end

  def get_domains(from, to) do
    {:ok, keys} = Redix.command(:redix, ["KEYS", "*"])
    domains = for key <- keys, {:ok, time} = Redix.command(:redix, ["HGET", "#{key}", "time"]), from <= String.to_integer(time), to >= String.to_integer(time) do
          {:ok, domain} = Redix.command(:redix, ["HGET", "#{key}", "domain"])
          domain
    end
    Enum.uniq(domains)
  end

  def uniq_ref do
    "#{:erlang.ref_to_list(make_ref())}"
  end
end
