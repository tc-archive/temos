#/bin/bash

# brew install elixir
# brew install selenium-server-standalone


selenium-server

mix deps.get
mix run

# iex -S mix

iex Scraper.start

