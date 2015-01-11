class Question < ActiveRecord::Base
  belongs_to :user

  def <=> other_question
    if identifier.length == 0
      return +1
    end

    if other_question.identifier.length == 0
      return -1
      end

    identifier <=> other_question.identifier
  end
end
