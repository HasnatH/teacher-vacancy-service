require 'google/cloud/bigquery'
require 'rollbar'
require 'export_tables_to_cloud_storage'

class ImportCSVToBigQuery
  def load(bigquery: Google::Cloud::Bigquery.new)
    dataset = bigquery.dataset ENV['BIG_QUERY_DATASET']

    ExportTablesToCloudStorage::TABLES.each do |table_csv|
      import_csv_uri = "gs://#{ENV['CLOUD_STORAGE_BUCKET']}/csv_export/#{table_csv.underscore}.csv"
      table_id = table_csv.underscore

      load_job = dataset.load_job table_id, import_csv_uri, skip_leading: 1, autodetect: true, write: 'truncate'

      load_job.wait_until_done! # Waits for table load to complete.

      table = dataset.table(table_id)
      if table.nil?
        Rollbar.log(:error, "The #{table_id} table failed to load to Big Query")
      else
        Rollbar.log(:info, "Loaded #{table.rows_count} rows to table #{table.id}")
      end
    end
  end
end
