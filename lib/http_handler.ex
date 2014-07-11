defmodule Ordos.HTTP do
	require Lager
	require Record

	Record.defrecord :elli_req, :req, Record.extract(:req, from_lib: "elli/include/elli.hrl")

	defp make_msg(msg = %{"req_id" => req_id}) do
		%Ordos.Message{req_id: req_id, body: msg}
	end

	def handle(req = elli_req([method: :GET, path: path, args: args]), _args) do
		Lager.info "GET | path = #{inspect path}, args = #{inspect args}"
		{:ok, [], "ordos handler"}
	end
	def handle(req = elli_req([method: :POST, path: path, body: body]), _args) do
		case :jiffy.decode(body, [:return_maps]) do
			json = %{"req_id" => req_id} ->
				Lager.info "POST| path = #{inspect path}, args = #{inspect json}"
				case Ordos.Speaker.read_channel(make_msg(json)) do
					{:ok, data} -> 
						{:ok , [], data}
					{:error, _msg} ->
						Lager.error "POST| path = #{inspect path}, args = #{inspect json} failed: #{inspect _msg}"
						{500, [], "request processing failed"}
				end
			json ->
				Lager.error "POST| path = #{inspect path}, args = #{inspect json} failed: no req_id given"
				{400, [], "no request id given"}
		end
	end

	def handle_event(_event, _data, _args), do: :ok
end