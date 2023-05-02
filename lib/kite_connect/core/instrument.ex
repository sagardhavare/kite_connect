defmodule KiteConnect.Core.Instrument do
  defstruct instrument_token: nil,
            exchange_token: nil,
            trading_symbol: nil,
            name: nil,
            last_price: nil,
            expiry: nil,
            strike: nil,
            tick_size: nil,
            lot_size: nil,
            instrument_type: nil,
            segment: nil,
            exchange: nil

  use ExConstructor

  def parse_csv_string(data) do
    data
    |> NimbleCSV.RFC4180.parse_string()
    |> Enum.map(fn [
                     instrument_token,
                     exchange_token,
                     trading_symbol,
                     name,
                     last_price,
                     expiry,
                     strike,
                     tick_size,
                     lot_size,
                     instrument_type,
                     segment,
                     exchange
                   ] ->
      Instrument.new(%{
        :instrument_token => instrument_token,
        :exchange_token => exchange_token,
        :trading_symbol => trading_symbol,
        :name => name,
        :last_price => last_price,
        :expiry => expiry,
        :strike => strike,
        :lot_size => lot_size,
        :instrument_type => instrument_type,
        :segment => segment,
        :exchange => exchange
      })
    end)
  end
end
