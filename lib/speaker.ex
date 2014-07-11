alias Ordos.Message, as: Message


defmodule Ordos.Speaker do
	require Lager
	@life_timeout		:timer.seconds(60)
	@wait_timeout		:timer.seconds(90)

	defp do_send(data, state = %{pids: pids}) do
		for pid <- pids, do: send(pid, {:ok, data})
	end
	defp do_send(_, _), do: :ok

	def read_channel(msg) do
		root = self
		spawn fn -> 
			send(root, update_lock(msg, root)) 
		end
		receive do
			msg -> msg
		after @wait_timeout -> 
			{:error, :timeout}
		end
	end

	defp request_data(pid) do
		send(pid, {:subscribe, self})
	end
	defp update_lock(msg = %Message{req_id: req_id}, root) do
		case :locker.lock(req_id, self, @life_timeout) do
			{:ok, _, _, _} -> 
				message_channel(msg, %{pids: [root]})
			{:error, :no_quorum} -> 
				case :locker.dirty_read(req_id) do
					{:ok, pid} when is_pid(pid) -> 
						request_data(pid)
					{:ok, data} -> 
						{:ok, data}
					{:error, :not_found} -> 
						{:error, :no_data_no_quorum}
				end
			_ -> 
				{:error, :unknown}
		end
	end

	defp message_channel(msg = %Message{req_id: req_id}, state = %{}) do
		:erlang.send_after(@life_timeout, self(), :timeout_life)
		receive do
			{:subscribe, pid} -> 
				case Map.get(state, :response) do
					nil -> 
						#Lager.notice("#{inspect req_id} :: no data, subscribing")
						message_channel(msg, put_in(state, [:pids], ([pid | Map.get(state, :pids, [])])))
					data -> 
						#Lager.notice("#{inspect req_id} :: got data, returing")
						send(pid, {:ok, data})
						message_channel(msg, state)
				end
			{:response, data} -> 
				#Lager.notice("#{inspect req_id} :: recived data response, now only serving data")
				:locker.update(req_id, self, data, @life_timeout)
				do_send(data, state)
				message_channel(msg, put_in(state, [:response], data))
			:timeout_life -> 
				{:error, :timeout}
		end
	end
end