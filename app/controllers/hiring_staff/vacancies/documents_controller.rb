class HiringStaff::Vacancies::DocumentsController < HiringStaff::Vacancies::ApplicationController
  before_action :school, :redirect_unless_vacancy_session_id, only: %i[new create]

  def new
    unless session[:vacancy_attributes]['supporting_documents'] == 'yes'
      redirect_to supporting_documents_school_job_path
    end
  end

  def create
    # WIP
    # temp_file = params[:upload].tempfile
    redirect_to documents_school_job_path
  end
end
