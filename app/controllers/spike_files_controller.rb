require "google/apis/drive_v3"

class SpikeFilesController < ApplicationController
  def new
    upload_path = "eicar.com"

    drive_service = Google::Apis::DriveV3::DriveService.new
    uploaded = drive_service.create_file(
      {alt: 'media'},
      fields: 'id, web_view_link, web_content_link',
      upload_source: upload_path,
    )
    drive_service.create_permission(uploaded.id, Google::Apis::DriveV3::Permission.new(type: 'anyone', role: 'reader'))

    begin
      download_path = "#{uploaded.id}"
      downloaded = drive_service.get_file(uploaded.id, acknowledge_abuse: false, download_dest: download_path)
      puts "No virus detected\nDownload file at #{uploaded.web_content_link}\nView file at #{uploaded.web_view_link}"
    rescue Google::Apis::ClientError
      deleted = drive_service.delete_file(uploaded.id)
      puts "Virus detected\nDownload file at #{uploaded.web_content_link}\nView file at #{uploaded.web_view_link}" 
    ensure 
      File.delete(download_path) if File.exist?(download_path)
    end

    respond_to do |format|
      format.all { render status: :not_found, body: nil }
    end
  end
end
