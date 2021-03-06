require 'rails_helper'
require 'export_vacancy_records_to_big_query'

RSpec.shared_examples 'a successful Big Query export' do
  it 'inserts into the dataset' do
    expect(dataset_stub).to receive(:insert).with('vacancies', expected_table_data, autocreate: true)

    subject.run!
  end
end

RSpec.describe ExportVacancyRecordsToBigQuery do
  before do
    ENV['BIG_QUERY_DATASET'] = 'test_dataset'
    expect(bigquery_stub).to receive(:dataset).with('test_dataset').and_return(dataset_stub)
    expect(dataset_stub).to receive(:table).and_return(table_stub)
  end

  subject { ExportVacancyRecordsToBigQuery.new(bigquery: bigquery_stub) }

  let(:bigquery_stub) { instance_double('Google::Cloud::Bigquery::Project') }
  let(:dataset_stub) { instance_double('Google::Cloud::Bigquery::Dataset') }

  context 'when the vacancy table exists in the dataset' do
    let(:table_stub) { instance_double('Google::Cloud::Bigquery::Table') }
    before { create(:vacancy) }

    it 'deletes the table first before inserting new table data' do
      expect(table_stub).to receive(:delete).and_return(true)
      expect(dataset_stub).to receive(:reload!)
      expect(dataset_stub).to receive(:insert)

      subject.run!
    end
  end

  context 'when the vacancy table does not exist in the dataset' do
    let(:table_stub) { nil }

    context 'with one vacancy' do
      let(:publish_on) { format_date_as_timestamp(vacancy.publish_on) }
      let(:expiry_time) { vacancy.expiry_time }
      let(:ends_on) { nil }
      let(:starts_on) { nil }
      let(:subjects) { [vacancy.subject.name] }

      let(:expected_table_data) do
        [
          {
          id: vacancy.id,
          slug: vacancy.slug,
          job_title: vacancy.job_title,
          minimum_salary: vacancy.minimum_salary,
          maximum_salary: vacancy.maximum_salary,
          starts_on: starts_on,
          ends_on: ends_on,
          subjects: subjects,
          min_pay_scale: vacancy.min_pay_scale&.label,
          max_pay_scale: vacancy.max_pay_scale&.label,
          leadership: vacancy.leadership&.title,
          education: vacancy.education,
          qualifications: vacancy.qualifications,
          experience: vacancy.experience,
          status: vacancy.status,
          expiry_time: expiry_time,
          publish_on: publish_on,
          school: {
            urn: vacancy.school.urn,
            county: vacancy.school.county,
          },
          created_at: vacancy.created_at,
          updated_at: vacancy.updated_at,
          application_link: vacancy.application_link,
          newly_qualified_teacher: vacancy.newly_qualified_teacher,
          total_pageviews: vacancy.total_pageviews,
          total_get_more_info_clicks: vacancy.total_get_more_info_clicks,
          working_patterns: vacancy.working_patterns,
          listed_elsewhere: vacancy.listed_elsewhere,
          hired_status: vacancy.hired_status,
          pro_rata_salary: vacancy.pro_rata_salary,
          publisher_user_id: vacancy.publisher_user&.oid,
        }
      ]
      end

      context 'with no expiry_time' do
        let(:vacancy) { create(:vacancy, :with_no_expiry_time).reload }
        let(:expiry_time) { format_date_as_timestamp(vacancy.expires_on) }

        it_behaves_like 'a successful Big Query export'
      end

      context 'when there is a starts_on and ends_on' do
        let(:vacancy) { create(:vacancy, :complete).reload }
        let(:starts_on) { vacancy.starts_on.strftime('%F') }
        let(:ends_on) { vacancy.ends_on.strftime('%F') }

        it_behaves_like 'a successful Big Query export'
      end

      context 'when a vacancy has no publish_on date' do
        let(:vacancy) { create(:vacancy, publish_on: nil).reload }
        let(:publish_on) { nil }

        it_behaves_like 'a successful Big Query export'
      end

      context 'with no subjects' do
        let(:vacancy) { create(:vacancy, subject: nil).reload }
        let(:subjects) { [] }

        it_behaves_like 'a successful Big Query export'
      end

      context 'with only one subject' do
        let(:vacancy) { create(:vacancy).reload }

        it_behaves_like 'a successful Big Query export'
      end

      context 'with multiple subjects' do
        let(:vacancy) { create(:vacancy, :first_supporting_subject, :second_supporting_subject).reload }
        let(:subjects) do
          [vacancy.subject.name, vacancy.first_supporting_subject.name, vacancy.second_supporting_subject.name]
        end

        it_behaves_like 'a successful Big Query export'
      end
    end

    context 'when the number of vacancies is greater than the batch size' do
      before { create_list(:vacancy, 3) }

      it 'inserts into big query twice' do
        expect(dataset_stub).to receive(:insert).twice

        subject.run!(batch_size: 2)
      end
    end

    def format_date_as_timestamp(date)
      date.strftime('%FT%T%:z')
    end
  end
end
