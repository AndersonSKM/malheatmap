require "test_helper"

class User
  class GenerateActivitiesFromHistoryTest < ActiveSupport::TestCase
    setup do
      @user = create(:user)
      @service = GenerateActivitiesFromHistory.set(user: @user)
    end

    def activities
      @user.activities.sort_by(&:date)
    end

    test "creates activity with current position if there's just one entry" do
      create(:entry, user: @user, timestamp: Date.new(2020, 1, 1), amount: 10)

      assert_changes -> { activities.size }, from: 0, to: 1 do
        @service.call
      end

      activity = activities.first
      assert_equal 10, activity.amount
      assert_equal Date.new(2020, 1, 1), activity.date
    end

    test "keeps activity's amount unmodified if there are duplicated entries same date and item" do
      create(:item) do |item|
        create(:entry, item: item, user: @user, timestamp: Date.new(2020, 1, 1), amount: 10)
        create(:entry, item: item, user: @user, timestamp: Date.new(2020, 1, 1), amount: 10)
      end

      assert_changes -> { activities.size }, from: 0, to: 1 do
        @service.call
      end

      assert_equal 10, activities.first.amount
    end

    test "creates subsequent activities with difference between positions" do
      create(:item) do |item|
        create(:entry, item: item, user: @user, timestamp: Date.new(2020, 1, 1), amount: 10)
        create(:entry, item: item, user: @user, timestamp: Date.new(2020, 1, 2), amount: 15)
      end

      assert_changes -> { activities.size }, from: 0, to: 2 do
        @service.call
      end

      assert_equal 10, activities.first.amount
      assert_equal 5, activities.second.amount
    end

    test "creates two activities when there are entries of different items on date" do
      create(:entry, :manga, user: @user, timestamp: DateTime.new(2020, 1, 1, 12, 15), amount: 10)
      create(:entry, :anime, user: @user, timestamp: DateTime.new(2020, 1, 1, 13, 30), amount: 20)

      assert_changes -> { activities.size }, from: 0, to: 2 do
        @service.call
      end

      first_activity = activities.first
      assert_equal 10, first_activity.amount

      second_activity = activities.second
      assert_equal 20, second_activity.amount

      assert_equal first_activity.date, second_activity.date
    end

    test "creates negative activity when user fall back the current postition" do
      create(:item) do |item|
        create(:entry, item: item, user: @user, timestamp: Date.new(2020, 1, 1), amount: 10)
        create(:entry, item: item, user: @user, timestamp: Date.new(2020, 1, 2), amount: 5)
        create(:entry, item: item, user: @user, timestamp: Date.new(2020, 1, 2), amount: 6)
      end

      @service.call

      assert_equal 10, activities.first.amount
      assert_equal(-4, activities.second.amount)
    end

    test "creates just one activity per day when there are multiple entries of same item on date" do
      create(:item) do |item|
        create(:entry, item: item, user: @user, timestamp: Date.new(2020, 1, 1), amount: 10)
        create(:entry, item: item, user: @user, timestamp: Date.new(2020, 1, 1), amount: 12)
        create(:entry, item: item, user: @user, timestamp: Date.new(2020, 1, 2), amount: 15)
        create(:entry, item: item, user: @user, timestamp: Date.new(2020, 1, 7), amount: 21)
        create(:entry, item: item, user: @user, timestamp: Date.new(2020, 1, 7), amount: 26)
      end

      assert_changes -> { activities.size }, from: 0, to: 3 do
        @service.call
      end

      activity = activities.first
      assert_equal 12, activity.amount
      assert_equal Date.new(2020, 1, 1), activity.date

      activity = activities.second
      assert_equal 3, activity.amount
      assert_equal Date.new(2020, 1, 2), activity.date

      activity = activities.third
      assert_equal 11, activity.amount
      assert_equal Date.new(2020, 1, 7), activity.date
    end

    test "should keep the entry with the greater amount when they have the same timestamp" do
      create(:item) do |item|
        create(:entry, item: item, user: @user, timestamp: Time.zone.local(2020, 7, 25, 14, 16), amount: 25)
        create(:entry, item: item, user: @user, timestamp: Time.zone.local(2020, 7, 25, 14, 16), amount: 1)
      end

      @service.call

      activity = activities.first
      assert_equal 25, activity.amount
    end
  end
end
