class User
  class ActivitiesGenerator
    def initialize(user)
      super()
      @user = user
      @processed_entries = ProcessedEntries.new(user)
      @processed_activities = ProcessedActivities.new(user)
    end

    def run
      Instrumentation.instrument(title: "#{self.class.name}#run") do
        user.with_time_zone do
          calculate_activities_per_day_from_history
          processed_activities.save!
        end
      end

      true
    end

    private

    attr_reader :user, :processed_entries, :processed_activities

    def calculate_activities_per_day_from_history
      entries = user
                  .entries
                  .order(:timestamp, :item_id, :amount, :created_at)

      processed_entries.clear_cache

      entries.each do |entry|
        generate_activity_from_entry(entry)

        processed_entries << entry
      end
    end

    def generate_activity_from_entry(current_entry)
      item = current_entry.item
      date = current_entry.timestamp.in_time_zone.to_date

      activity = processed_activities.find_or_new(item, date)

      # Some uses prefer to count their activities by entry line in their history
      # like other existing tools, MALGraph for example
      activity.amount += if user.count_each_entry_as_an_activity?
                           1
                         else
                           calculate_amount_from_last_entry_position(current_entry, item, date)
                         end
    end

    def calculate_amount_from_last_entry_position(current_entry, item, date)
      last_amount = processed_entries.find_last_amount(item, date) || current_entry.amount

      current_entry.amount - last_amount
    end

    class ProcessedActivities
      def initialize(user)
        super()
        @user = user
        @activities = {}
      end

      def find_or_new(item, date)
        @activities["#{item.id}/#{date}"] ||= @user.activities.build(item: item, date: date, amount: 0)
      end

      def save!
        @user.activities.transaction do
          @user.activities.delete_all
          @activities.each_value(&:save!)
        end
      end
    end

    class ProcessedEntries
      def initialize(user)
        super()
        @redis = Redis.new(url: ENV["REDIS_URL"])
        @user = user
      end

      def <<(entry)
        score = "#{entry.timestamp.in_time_zone.to_date.strftime('%Y%m%d')}.#{entry.amount}".to_f

        @redis.zadd(redis_key(entry.item_id), score, entry.amount)
      end

      def find_last_amount(item, date)
        result = @redis.zrevrangebyscore(redis_key(item.id), date.strftime("%Y%m%d").to_s, "-inf", limit: [0, 1])
        result.first.present? ? result.first.to_i : nil
      end

      def clear_cache
        @redis.del "#{base_key}:*"
      end

      private

      attr_reader :user

      def redis_key(item)
        "#{base_key}:#{item}"
      end

      def base_key
        "#{self.class}:#{@user.id}"
      end
    end
  end
end
