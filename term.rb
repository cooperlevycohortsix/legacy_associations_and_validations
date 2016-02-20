class Term < ActiveRecord::Base
  belongs_to :school
  has_many :courses, dependent: :restrict_with_error
  validates :starts_on, presence: true
  validates :ends_on, presence: true
  validates :school_id, presence: true
  default_scope { order('ends_on DESC') }

  scope :for_school_id, ->(school_id) { where("school_id = ?", school_id) }

  def add_course(course)
    terms << course
  end

  def school_name
    schools ? school.name : "None"
  end
end
