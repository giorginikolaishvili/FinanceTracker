class Stock < ApplicationRecord
  has_many :user_stocks
  has_many :users, through: :user_stocks

  def self.find_by_ticker(ticker)
    where(ticker: ticker).first
  end

  def self.new_from_lookup(ticker_symbol)
    begin
      looked_up_stock = StockQuote::Stock.quote(ticker_symbol)
      price = strip_commas(looked_up_stock.previous_close.to_s)
      new(name: looked_up_stock.company_name, ticker: looked_up_stock.symbol, last_price: price)
    rescue Exception => e
      return nil
    end
  end

  def self.strip_commas(num)
    num.gsub(",", "")
  end
end
