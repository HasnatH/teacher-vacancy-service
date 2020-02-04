class HiringStaff::Vacancies::DocumentsController < HiringStaff::Vacancies::ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]
  before_action :school, :redirect_unless_vacancy_session_id, only: %i[new create]

  def new
    # WIP
  end

  def create
    # WIP
    # temp_file = params[:upload].tempfile
    redirect_to documents_school_job_path
  end
end
