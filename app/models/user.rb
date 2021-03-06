class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :questions
  accepts_nested_attributes_for :questions, :allow_destroy => true

  acts_as_taggable_on :keywords

  has_many :keyword_associations
  accepts_nested_attributes_for :keyword_associations, :allow_destroy => true
  has_many :keywords, :through => :keyword_associations
  accepts_nested_attributes_for :keywords, :allow_destroy => true

  has_attached_file :avatar, styles: {
      thumb: '100x100#',
  }

  before_post_process :rename_avatar
  def rename_avatar
    #avatar_file_name - important is the first word - avatar - depends on your column in DB table
    extension = File.extname(avatar_file_name).downcase
    self.avatar.instance_write :file_name, "#{Time.now.to_i.to_s}#{extension}"
  end

  # Validate the attached image is image/jpg, image/png, etc
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/

  def answer_to question_id
    question = questions.find {|q| q.identifier == question_id}
    question.answer if question
  end

  def is_keyword_popular keyword
    return KeywordAssociation.where(:keyword => keyword).count >= 2
  end

  def self.next current_id
    self.where("id > ? and published = ?", current_id, true).order(id: :asc).first() || self.where("published = ?", true).order(id: :asc).first()
  end

  def self.previous current_id
    self.where("id < ? and published = ?", current_id, true).order(id: :desc).first() || self.where("published = ?", true).last
  end

  def self.random
    offset = rand(self.where("published = ? and job_title IS NOT NULL", true).count())
    self.where("published = ? and job_title IS NOT NULL", true).offset(offset).first
  end

  def questions_to_display
    questions.select {|q| q.published }
  end

end
