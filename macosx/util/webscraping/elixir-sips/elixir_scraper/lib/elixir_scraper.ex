defmodule ElixirScraper do
  @moduledoc """
  Documentation for ElixirScraper.
  """

  use Hound.Helpers


  def login(username, password) do
    navigate_to "https://elixirsips.dpdcart.com/subscriber/login"
    find_element(:id, "username", 1) |> fill_field(username)
    find_element(:id, "password", 1) |> fill_field(password)
    page_source()
  end


  @doc """
  Logs into the elixir sip web site.

  ## Examples

      iex> ElixirScraper.start

  """
  def start do

	username = IO.gets "Elixir Sips username: "
	password = IO.gets "Elixir Sips password: "

    

    IO.puts "starting"
    Hound.start_session
    
	entries = login(username, password) 
              |> Floki.find(".blog-entry") 
              |> Enum.reverse() 
              |> Enum.take(2)

	lessons = List.foldl(entries, [], fn (entry, acc) ->
			
			{_, _, lesson_title} = Floki.find(entry, "h3") |> List.first()
			lesson_url = Floki.find(entry, "a") |> List.first() |> Floki.attribute("href")
			
			navigate_to "https://elixirsips.dpdcart.com/#{lesson_url}"
			file_links = find_all_elements(:tag, "a", 1) 
                    |> Enum.map(fn(x) -> attribute_value(x, "href") end)
                    |> Enum.filter(fn(x) -> x != nil && String.contains? x, "download" end)

            lesson_info = %{lesson_tile: lesson_title,
                            lesson_url: lesson_url,
                            file_links: file_links}

            IO.puts("lesson_info: #{Poison.encode!(lesson_info)}")

			IO.puts("title: #{lesson_title}")
			IO.puts("url: #{lesson_url}")
			for file_link <- file_links, do: IO.puts("file_link: #{file_link}")
		
            # file_links = find_all_elements(:tag, "a", 1)
            #  |> Enum.filter(fn(x) -> attribute_value(x, "href") != nil 
            #                          && String.contains? attribute_value(x, "href"), "download" end) 
            #for fl <- file_links, do: click(fl)
			
            [lesson_info] ++ acc
		end 
	)

    # Hound.end_session
  end

end
