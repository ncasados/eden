defmodule EDDNListener do
  use GenServer

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [])
  end

  def init(_args) do
    {:ok, [setup_subscriber_socket()], {:continue, :started}}
  end

  def handle_continue(:started, [socket] = state) do
    process_message(socket)
    {:noreply, state}
  end

  def handle_info({:received, content}, [socket] = state) do
    IO.puts("RECEIVED: #{inspect(content)}")
    process_message(socket)
    {:noreply, state}
  end

  defp setup_subscriber_socket() do
    {:ok, socket} = :chumak.socket(:sub)
    :chumak.subscribe(socket, "")
    :chumak.connect(socket, :tcp, ~c'eddn.edcd.io', 9500)
    socket
  end

  defp process_message(socket) do
    {:ok, deflated_contents} = :chumak.recv(socket)

    z = :zlib.open()
    :ok = :zlib.inflateInit(z)
    inflated_contents = :zlib.inflate(z, deflated_contents)
    :zlib.inflateEnd(z)

    content = inflated_contents |> to_string() |> JSON.decode!()

    Process.send(self(), {:received, content}, [])
  end
end
