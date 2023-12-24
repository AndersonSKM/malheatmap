class User < ApplicationRecord
  include Crawlable
  include Mergeable
  include Calendars
  include Signaturable
  include Authenticatable
  include Deactivatable

  has_many :entries, -> { preload(:item) }, inverse_of: :user, dependent: :delete_all
  has_many :activities, -> { preload(:item) }, inverse_of: :user, dependent: :delete_all do
    def generate_from_history
      ActivitiesGenerator.new(proxy_association.owner).run
    end

    def first_date
      order(date: :asc).limit(1).pick(:date)
    end
  end

  validates :time_zone, presence: true
  validates :latitude, numericality: true, allow_nil: true
  validates :longitude, numericality: true, allow_nil: true

  def with_time_zone(&)
    Time.use_zone(time_zone, &)
  end

  def to_param
    username
  end

  def to_s
    username
  end
end
