defmodule KiteConnect.InstrumentsServer do
  use GenServer
  alias KiteConnect.Core.Instrument

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def get_instrument!(trading_symbol) do
    GenServer.call(__MODULE__, {:get_instrument, trading_symbol})
  end

  def handle_call({:get_instrument, trading_symbol}, _from, state) do
    instrument =
      state.instruments
      |> Enum.find(fn x ->
        String.downcase(x.trading_symbol) == String.downcase(trading_symbol)
      end)

    {:reply, instrument, state}
  end

  def handle_info({:fetch_instruments, _exchange}, state) do
    headers = KiteConnect.gen_headers()
    url = "https://api.kite.trade/instruments/NSE?api_key=#{KiteConnect.access_token()}"

    case HTTPoison.get(url, headers) do
      {:ok, res} ->
        instruments = Instrument.parse_csv_string(res.body)
        state = %{state | instruments: MapSet.new(instruments), timestamp: Timex.now()}
        {:noreply, state}

      _ ->
        {:ok, state}
    end
  end

  def init(_args) do
    {:ok, initial_state()}
  end

  defp initial_state() do
    Process.send_after(self(), {:fetch_instruments, "NSE"}, 5 * 1000)
    %{instruments: MapSet.new(), timestamp: nil}
  end
end
