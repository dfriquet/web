class KeywordAssociation < ActiveRecord::Base
  belongs_to :user
  belongs_to :keyword
end
