defmodule ElixirScraper do
  @moduledoc """
  Documentation for ElixirScraper.
  """

  use Hound.Helpers

  @site_url           "https://elixirsips.dpdcart.com"
  @login_url_fragment "/subscriber/login"


  @doc """
  Logs into the main web and navigates to the list of available lessons. The page in returned.

  This function assumes a Hound selenium session is running. After invocation the session should be
  authenticated. The target browser should be at the available lessons page. 
  """
  def login() do
    # get user credentials
	username = IO.gets "Elixir Sips username: "
	password = IO.gets "Elixir Sips password: "
    # navigate to main page
    navigate_to "#{@site_url}#{@login_url_fragment}"
    find_element(:id, "username", 1) |> fill_field(username)
    find_element(:id, "password", 1) |> fill_field(password)
    page_source()
  end


  @doc """
  Logs into the main web and navigates to the list of available lessons. The lessons are extracted
  and returned.

  This function assumes an authenticated Hound selenium session is running. 
  """
  def extract_lessons(lessons_page) do
	lessons_page
      |> Floki.find(".blog-entry")
      |> Enum.reverse()
  end
  

  @doc """
  Given a list of 'lesson' html elements, navigates to each lesson page and extracts the set of
  download urls. These are used to create a map of lessons details.

  This function assumes an authenticated Hound selenium session is running. 
  """
  def extract_lesson_infos(lesson_elements) do
    List.foldl(lesson_elements, [], fn (lesson_element, results) ->
      # extract the lesson title 
	  {_, _, lesson_title} = Floki.find(lesson_element, "h3") 
                           |> List.first()
      # extract lesson url fragment
	  lesson_url_fragment = Floki.find(lesson_element, "a") 
                          |> List.first() 
                          |> Floki.attribute("href")
      # navigate to the lesson page and extract the download linkis
      lesson_url =  "#{@site_url}#{lesson_url_fragment}"
	  navigate_to lesson_url
	  file_links = find_all_elements(:tag, "a", 1) 
                 |> Enum.map(fn(x) -> attribute_value(x, "href") end)
                 |> Enum.filter(fn(x) -> x != nil && String.contains? x, "download" end)
      # construct a the info and add it to the response    
      lesson_info = %{lesson_tile: List.first(lesson_title),
                      lesson_url: lesson_url,
                      file_links: file_links}
      [lesson_info] ++ results
	end)
  end
 

  @doc """
  Logs into the elixir sip web site and downloads the video lessons.
  ## Examples
      iex> ElixirScraper.start
  """
  def start do
    # start scraping session with selenium serer
    IO.puts "starting"
    Hound.start_session
    lessons_page = login()
    # extract the list of lessons from the main contents page
    lessons = lessons_page
            |> extract_lessons() 
            |> Enum.take(2)
    # extract the lesson info and download urls from each lesson page.
	lesson_infos = extract_lesson_infos(lessons)
    for lesson_info <- Enum.reverse(lesson_infos), do: IO.puts("lesson_info: #{Poison.encode!(lesson_info)}\n")
    # end the scraping sessions
    # Hound.end_session
  end

end
