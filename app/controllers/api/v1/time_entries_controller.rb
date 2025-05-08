module Api
  module V1
    class TimeEntriesController < BaseController
      before_action :set_time_entry, only: [ :show, :update, :destroy ]

      def index
        if params[:user_id].present? && (current_user.admin? || current_user.manager?)
          @time_entries = User.find(params[:user_id]).time_entries.order(date: :desc)
        else
          @time_entries = current_user.time_entries.order(date: :desc)
        end

        @time_entries = @time_entries.where("date >= ?", params[:from]) if params[:from].present?
        @time_entries = @time_entries.where("date <= ?", params[:to]) if params[:to].present?

        render json: @time_entries.as_json(methods: [ :average_speed ])
      end

      def show
        render json: @time_entry.as_json(methods: [ :average_speed ])
      end

      def create
        @time_entry = current_user.time_entries.build(time_entry_params)
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

      private

      def set_time_entry
        @time_entry = if current_user.admin? || current_user.manager?
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
