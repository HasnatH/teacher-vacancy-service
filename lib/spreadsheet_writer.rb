require 'google_drive'
require "google/cloud/bigquery"

module Spreadsheet
  class Writer
    def initialize(spreadsheet_id, worksheet_pos = 0, use_gid = false)
      @spreadsheet_id = spreadsheet_id
      @worksheet_pos = worksheet_pos
      @use_gid = use_gid
      bigquery = Google::Cloud::Bigquery.new(credentials: Google::Apis::RequestOptions.default.authorization, project_id: "teacher-vacancy-service")
      dataset = bigquery.dataset "trial_dataset"
      @table = dataset.create_table "my_table"
    end

    def append_rows(rows)
      pos = worksheet.num_rows
      rows.each_with_index do |row, i|
        append_row(row, pos + i, false)
      end
      worksheet.save
    end

    def append_row(row, last_pos = worksheet.num_rows, save = true)
      pos = last_pos + 1
      row.each_with_index do |cell, index|
        worksheet[pos, index + 1] = cell
      end
      worksheet.save if save
      @table.insert row
    end

    def last_row
      return nil if worksheet.num_rows <= 1

      worksheet.rows[worksheet.num_rows - 1]
    end

    private

    def key
      @key ||= StringIO.new(GOOGLE_DRIVE_JSON_KEY)
    end

    def session
      @session ||= GoogleDrive::Session.from_service_account_key(key)
    end

    def worksheet
      @worksheet ||= use_gid ? spreadsheet.worksheet_by_gid(worksheet_pos) : spreadsheet.worksheets[worksheet_pos]
    end

    def spreadsheet
      @spreadsheet ||= session.spreadsheet_by_key(spreadsheet_id)
    end

    attr_reader :spreadsheet_id, :worksheet_pos, :use_gid
  end
end
