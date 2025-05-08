module Api
  module V1
    class TimeEntrySerializer < ActiveModel::Serializer
      attributes :id, :date, :distance, :duration, :average_speed

      def average_speed
        object.average_speed
      end
    end
  end
end
