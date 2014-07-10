defmodule Ordos.HTTP do
	require Lager
	
	def handle(_req, _args) do
		Lager.info "Got request: #{inspect _req} with args #{inspect _args}"
		{:ok, [], "ordos handler"}
	end
	def handle_event(_event, _data, _args), do: :ok
end