module Api
  module V1
    class TimeEntriesController < BaseController
      before_action :set_time_entry, only: [ :show, :update, :destroy ]

      def index
        @target_user = if params[:user_id].present? && current_user.admin?
                         User.find(params[:user_id])
        else
                         current_user
        end

        @time_entries = @target_user.time_entries.order(date: :desc)
        @time_entries = @time_entries.where("date >= ?", params[:from]) if params[:from].present?
        @time_entries = @time_entries.where("date <= ?", params[:to]) if params[:to].present?

        render json: @time_entries.as_json(methods: [ :average_speed ])
      end

      def show
        render json: @time_entry.as_json(methods: [ :average_speed ])
      end

      def create
        @target_user = if params[:user_id].present? && current_user.admin?
                         User.find(params[:user_id])
        else
                         current_user
        end

        @time_entry = @target_user.time_entries.build(time_entry_params)

        if @time_entry.save
          render json: @time_entry.as_json(methods: [ :average_speed ]), status: :created
        else
          render json: { errors: @time_entry.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        if @time_entry.update(time_entry_params)
          render json: @time_entry.as_json(methods: [ :average_speed ])
        else
          render json: { errors: @time_entry.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @time_entry.destroy
        head :no_content
      end

      def weekly_stats
        stats = TimeEntry.weekly_stats(current_user)

        render json: stats.as_json
      end

      private

      def set_time_entry
        @time_entry = if current_user.admin?
                        TimeEntry.find(params[:id])
        else
                        current_user.time_entries.find(params[:id])
        end
      end

      def time_entry_params
        params.require(:time_entry).permit(:date, :distance, :duration)
      end
    end
  end
end
