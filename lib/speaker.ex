alias Ordos.Message, as: Message


defmodule Ordos.Speaker do
	@response_timeout	:timer.seconds(5)
	@life_timeout		:timer.seconds(60)

	def spawn_channel(msg) do
		spawn fn ->
			message_channel(msg, %{})
		end
	end
	defp update_lock(msg = %Message{req_id: req_id}) do
		case :locker.lock(req_id, self) do
			{:ok, _, _, _} -> :ok
			{:error, _} -> :error
		end
	end
	defp do_send(data, state = %{pids: pids}) do
		for pid <- pids, do: send(data, pid)
	end
	defp message_channel(msg = %Message{req_id: req_id}, state = %{}) do
		update_lock(msg)
		:erlang.send_after(@response_timeout, :timeout_response)
		receive do
			{:subscribe, pid} -> 
				case Map.get(state, :response) do
					nil -> 
						message_channel(msg, put_in(state, :pids, ([pid | Map.get(state, :pids, [])])))
					data -> 
						send(data, pid)
						message_channel(msg, state)
				end
			{:response, data} -> 
				do_send(data, state)
				:erlang.send_after(@life_timeout, :timeout_life)
				message_channel(msg, put_in(state, :response, data))
			:lock_timeout ->
				update_lock(msg)
				message_channel(msg, state)
			:timeout_response ->
				case Map.get(state, :response) do
					nil -> do_send(:timeout, state)
					_   -> message_channel(msg, state)
				end
			:timeout_life -> :ok
		end
	end
end