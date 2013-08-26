class Sprint < ActiveRecord::Base

  belongs_to :user
  belongs_to :project
  has_many :issues, :dependent => :destroy

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => [:project_id]
  validates_length_of :name, :maximum => 60
  validates_presence_of :name

  validates :start_date, :date => true
  validates_presence_of :start_date

  validates :end_date, :date => true
  validates_presence_of :end_date

  def to_s
    name
  end

end
