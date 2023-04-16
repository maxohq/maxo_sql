import Config

if config_env() == :test do
  config :maxo_test_iex, event_dedup_timeout: 500
end
