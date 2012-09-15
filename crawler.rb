require "nokogiri"
require "open-uri"
require 'fileutils'

BASE_URL =  "http://www.radiokrishna.com/rkc_archive_new/"
BASE_ARTISTS_URL = "http://www.radiokrishna.com/rkc_archive_new/index.php?q=f&f=/Musica%20-%20Music%20"
BASE_RADIO_URL =  "http://www.radiokrishna.com"

def init
	folders = collect_artists_folders
	collect_mp3_files folders
end
def collect_artists_folders
	indexes = ["A-K","L-Z"]
	artists = []
	indexes.each do |index|
		url = "#{BASE_ARTISTS_URL}#{index}"
		begin
    		Nokogiri::HTML(open(url)).css("a").each do |link|
    			if /index\.php\?q\=f\&f\=\%2FMusica\+\-\+Music/ =~ link[:href]
					artists << link[:href] unless artists.include? link[:href]
    			end
    		end
  		rescue OpenURI::HTTPError => e
    		p "Collecting Artists Error: #{e.message}"
  		end
	end

	artists
end
def collect_mp3_files artists
	artists.each do |artist|
		url = "#{BASE_ARTISTS_URL}#{artist}"
		begin
			file_path = artist.split("%2F").last.gsub("+", " ").strip
			unless Dir.exist? file_path
				Dir.mkdir file_path
				Dir.chdir file_path
				p "downloading #{file_path}"
			end
    		Nokogiri::HTML(open(url)).css("a").each do |link|
    			if /\.mp3/ =~ link[:href]
    				mp3 = link[:href]
    				mp3_file_name = mp3.split("/").last.gsub("%20","_")
					unless File.exist? mp3_file_name
				        open("#{mp3_file_name}", 'wb') do |file|
				            p "     > downloading #{mp3_file_name}"
				            begin
				              file << open("#{BASE_RADIO_URL}#{mp3}", "Referer" => url).read
				            rescue OpenURI::HTTPError => e
				              p "Parsin mp3 file Error: #{e.message}"
				            end
				        end
				    end
    			end
    		end
    		Dir.chdir("../")
  		rescue OpenURI::HTTPError => e
    		p "Collecting mp3 Error: #{e.message}"
  		end
	end
end

init
