class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :user_stocks
  has_many :stocks, through: :user_stocks
  has_many :friendships
  has_many :friends, through: :friendships

  def full_name
    return "#{first_name} #{last_name}".strip if (first_name || last_name)
    "Anonymous"
  end

  def stock_already_added_to_portfolio?(ticker)
    stock = Stock.find_by_ticker(ticker)
    return false unless stock
    user_stocks.where(stock_id: stock.id).exists?
  end

  def under_stock_limit?
    (user_stocks.count < 10)
  end

  def can_add_stock?(ticker)
    under_stock_limit? && !stock_already_added_to_portfolio?(ticker)
  end

  def self.search(param)
    puts param
    param.strip!
    param.downcase!
    to_send_back = (first_name_matches?(param) + last_name_matches?(param) + email_matches?(param)).uniq
    return nil unless to_send_back
    to_send_back
  end

  def self.first_name_matches?(param)
    matches('first_name', param)
  end

  def self.last_name_matches?(param)
    matches('last_name', param)

  end

  def self.email_matches?(param)
    matches('email', param)

  end

  def self.matches(field, param)
    User.where("#{field} like ?", "%#{param}%")
  end

  def except_current_user(users)
    users.reject {|user| user.id == self.id}
  end

  def not_friends_with?(user)
    !self.friends.to_a.include?(user)
  end
end
