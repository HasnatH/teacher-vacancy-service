require 'rails_helper'

RSpec.feature 'Hiring staff can upload documents to a vacancy' do
  let(:school) { create(:school) }
  let!(:pay_scales) { create_list(:pay_scale, 3) }
  let!(:subjects) { create_list(:subject, 3) }
  let!(:leaderships) { create_list(:leadership, 3) }
  let(:vacancy) do
    VacancyPresenter.new(build(:vacancy, :complete,
                               school: school,
                               min_pay_scale: pay_scales.sample,
                               max_pay_scale: pay_scales.sample,
                               subject: subjects[0],
                               first_supporting_subject: subjects[1],
                               second_supporting_subject: subjects[2],
                               leadership: leaderships.sample,
                               working_patterns: ['full_time', 'part_time'],
                               publish_on: Time.zone.today))
  end

  before do
    allow(ENV).to receive(:[])
    allow(ENV).to receive(:[]).with('FEATURE_UPLOAD_DOCUMENTS').and_return(true)
    stub_hiring_staff_auth(urn: school.urn)
  end

  context 'when a user wants to upload documents to a vacancy' do
    before do
      visit new_school_job_path
      fill_in_job_specification_form_fields(vacancy)
      click_on 'Save and continue'
    end

    it 'displays upload a file text' do
      visit documents_school_job_path
      expect(page).to have_content('Upload a file')
    end

    scenario 'hiring staff can select a file for upload' do
      visit documents_school_job_path
      page.attach_file('upload', Rails.root.join('spec/fixtures/files/blank_job_spec.pdf'))
      expect(page.find('#upload').value).to_not be nil
    end
  end
end
