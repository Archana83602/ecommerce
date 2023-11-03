
class SpreeUser < ApplicationRecord
    # other Devise modules...
  
    devise :confirmable, :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

end
  