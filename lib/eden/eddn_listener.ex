defmodule EDDNListener do
  use GenServer

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [])
  end

  def init(_args) do
    {:ok, [setup_subscriber_socket()], {:continue, :started}}
  end

  def handle_continue(:started, [socket] = state) do
    receive_message(socket)
    {:noreply, state}
  end

  def handle_info({:received, content}, [socket] = state) do
    [
      fn -> create_system(content) end
    ]
    |> Task.async_stream(fn func -> func.() end)
    |> Stream.run()

    receive_message(socket)
    {:noreply, state}
  end

  defp write_to_file(content) do
    File.touch!("eddn_msgs.txt")

    File.write!("eddn_msgs.txt", "EDDN_MESSAGE: #{Jason.encode!(content, pretty: true)}\n", [
      :append
    ])
  end

  defp create_system(content) do
    message = Map.get(content, "message")

    case Map.get(message, "SystemAddress") do
      nil ->
        :noop

      system_address ->
        {:ok, changeset} =
        case Eden.Repo.get_by(Eden.Schemas.System, system_address: system_address) do
          nil -> %Eden.Schemas.System{}
          system -> system
        end
        |> Eden.Schemas.System.changeset(message)

        Eden.Repo.insert_or_update(changeset)
    end
  end

  defp setup_subscriber_socket() do
    {:ok, socket} = :chumak.socket(:sub)
    :chumak.subscribe(socket, "")
    :chumak.connect(socket, :tcp, ~c'eddn.edcd.io', 9500)
    socket
  end

  defp receive_message(socket) do
    {:ok, deflated_contents} = :chumak.recv(socket)

    z = :zlib.open()
    :ok = :zlib.inflateInit(z)
    inflated_contents = :zlib.inflate(z, deflated_contents)
    :zlib.inflateEnd(z)

    content = inflated_contents |> to_string() |> JSON.decode!()

    Process.send(self(), {:received, content}, [])
  end
end
