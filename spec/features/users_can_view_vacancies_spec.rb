require 'rails_helper'
RSpec.feature 'Viewing vacancies' do
  scenario 'Only published, non-expired vacancies are visible in the list', elasticsearch: true do
    valid_vacancy = create(:vacancy)

    [:trashed, :draft, :expired,
     %i[expired trashed], %i[expired draft]].each { |args| create(:vacancy, *args) }

    Vacancy.__elasticsearch__.client.indices.flush
    visit vacancies_path

    expect(page).to have_content(valid_vacancy.job_title)
    expect(page).to have_selector('.vacancy', count: 1)
  end

  scenario 'Vacancies should not paginate when under per-page limit', elasticsearch: true do
    allow(Vacancy).to receive(:default_per_page).and_return(2)
    vacancies = create_list(:vacancy, 2)

    Vacancy.__elasticsearch__.client.indices.flush
    visit vacancies_path

    vacancies.each { |v| expect(page).to have_content(v.job_title) }
    expect(page).to have_no_link('2')
  end

  scenario 'Vacancies should paginate when over per-page limit', elasticsearch: true do
    allow(Vacancy).to receive(:default_per_page).and_return(2)
    first_vacancy = create(:vacancy, expires_on: 5.days.from_now)
    second_vacancy = create(:vacancy, expires_on: 6.days.from_now)
    third_vacancy = create(:vacancy, expires_on: 7.days.from_now)

    Vacancy.__elasticsearch__.client.indices.flush
    visit vacancies_path

    expect(page).to have_content(first_vacancy.job_title)
    expect(page).to have_content(second_vacancy.job_title)
    expect(page).to_not have_content(third_vacancy.job_title)

    expect(page).to have_link('2')
  end
end