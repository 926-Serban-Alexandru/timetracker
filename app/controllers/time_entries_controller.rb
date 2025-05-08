class TimeEntriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_time_entry, only: [ :edit, :update, :destroy ]
  include ActionView::RecordIdentifier


  def index
    @from = params[:from]
    @to = params[:to]
    @time_entry = TimeEntry.new
    # Set target user - admin can view others, regular users only see their own
    @target_user = if params[:user_id].present? && current_user.admin?
                     User.find(params[:user_id])
    else
                     current_user
    end
    if params[:user_id].present?
      unless current_user.admin?
        redirect_to time_entries_path, alert: "You don't have permission to view other users' time entries."
        return
      end

    end
    @time_entries = @target_user.time_entries.order(date: :desc)

    @time_entries = @time_entries.where("date >= ?", @from) if @from.present?
    @time_entries = @time_entries.where("date <= ?", @to) if @to.present?

    @weekly_report = TimeEntry.weekly_stats(current_user)
  end

  def create
    # Set the user for the new entry - admin can create for others
    if params[:user_id].present? && current_user.admin?
      @target_user = User.find(params[:user_id])
    else
      @target_user = current_user
    end

    @time_entry = @target_user.time_entries.build(time_entry_params)

    respond_to do |format|
      if @time_entry.save
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.append("time_entries", partial: "entry", locals: { entry: @time_entry }),
            turbo_stream.replace("weekly_report", partial: "weekly_report",
                             locals: { weekly_report: TimeEntry.weekly_stats(@target_user) })
          ]
        end
        format.html { redirect_to time_entries_path(user_id: @target_user.id), notice: "Time entry logged." }
      else
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "new_time_entry_form",
            partial: "form",
            locals: { time_entry: @time_entry }
          )
        end
        format.html { render :index, status: :unprocessable_entity }
      end
    end
  end

  def edit
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          dom_id(@time_entry),
          partial: "edit_form",
          locals: { time_entry: @time_entry }
        )
      end
      format.html { redirect_to time_entries_path }
    end
  end

  def update
    if @time_entry.update(time_entry_params)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace(dom_id(@time_entry), partial: "entry", locals: { entry: @time_entry }),
            turbo_stream.replace("weekly_report", partial: "weekly_report",
                                 locals: { weekly_report: TimeEntry.weekly_stats(current_user) })
          ]
        end
        format.html { redirect_to time_entries_path, notice: "Entry updated" }
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @time_entry.destroy
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove(@time_entry),
          turbo_stream.replace("weekly_report", partial: "weekly_report",
                               locals: { weekly_report: TimeEntry.weekly_stats(current_user) })
        ]
      end
      format.html { redirect_to time_entries_path, notice: "Time entry deleted." }
    end
  end

  def show
    @time_entry = current_user.time_entries.find(params[:id])
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          dom_id(@time_entry),
          partial: "entry",
          locals: { entry: @time_entry }
        )
      end
      format.html { redirect_to time_entries_path }
    end
  end



  private

  def set_time_entry
    # Admins can access any entry, regular users only their own
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
