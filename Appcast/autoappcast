#!/usr/bin/env ruby

# Dependencies
require "rubygems"
require "aws-sdk"
require 'cfpropertylist'
require 'yaml'
require 'fileutils'
require 'pathname'
require 'tmpdir'
require 'grit'
require 'open-uri'

CURRENT_DIR =  File.expand_path File.dirname(__FILE__)
SETTINGS = YAML.load_file "#{CURRENT_DIR}/autoappcast_config.yml"

class AutoAppcast

  # Setup shit

  def release!
    
    # puts release_notes_data
    # return
            
    puts "Publishing #{SETTINGS["app_name"]} release #{current_version_number}."
    puts "Compressing app..."
    AutoAppcast.zip_folder(SETTINGS["built_app_path"], temporary_zipped_version_path)
    puts "Uploading application..."
    upload_public_file_to_s3(temporary_zipped_version_path, zipped_filename)
    
    puts "Writing appcast..."
    write_file temporary_appcast_path, appcast_data
    upload_public_file_to_s3(temporary_appcast_path, "appcast.xml")
    
    puts "Writing release notes..."
    write_file temporary_release_notes_path, release_notes_data
    upload_public_file_to_s3(temporary_release_notes_path, "release_notes.html")
    
    puts "Writing head id..."
    write_file temporary_head_path, current_head_id
    upload_public_file_to_s3(temporary_head_path, "head_id.txt")
    
    puts "Writing releases log..."
    write_file temporary_release_list_path, releases_list_data.to_yaml
    upload_public_file_to_s3(temporary_release_list_path, "releases.yml")
        
    puts "Released!"
    
  end
  
  def appcast_data
    file = File.open("#{CURRENT_DIR}/appcast.template.xml", "rb")
    contents = file.read
    contents.sub!("$DESCRIPTION", "Updated to version #{current_version_number}, #{Time.now.to_s}")
    contents.sub!("$VERSION", current_version_number)
    contents.sub!("$URL", s3_url(zipped_filename))
    contents
  end
  
  def release_notes_data
    repo = Grit::Repo.new(Pathname.new(CURRENT_DIR).parent)
    
    file = File.open("#{CURRENT_DIR}/release_notes.template.html", "rb")
    layout = file.read
    
    file = File.open("#{CURRENT_DIR}/release_notes.version.template.html", "rb")
    partial = file.read
    
    rels = releases_list_data
    
    versions_html = ""
    rels.keys.map{|x| x.to_i}.sort.reverse.each do |version|
      
      version = version.to_s
      version_hash = rels[version]
      next_version = (version.to_i + 1).to_s
      next_version_hash = rels[next_version]
      previous_version = (version.to_i - 1).to_s
      previous_version_hash = rels[previous_version]

      # if current_version_number == version
        
      if previous_version_hash
        commits = repo.commits_between(previous_version_hash["head"], version_hash["head"])
      end
      # elsif next_version_hash
      #     commits = repo.commits_between(version_hash["head"], next_version_hash["head"])
      # end
            
      if commits
      
        this_partial = partial + ""

        this_partial.gsub!("$APPNAME", SETTINGS["app_name"])
        this_partial.sub!("$VERSION", version_hash["human_version"])
        this_partial.sub!("$HEAD", version_hash["head"])
        this_partial.sub!("$DATE", version_hash["date"].strftime("%b %d %Y, %I:%M%p"))
      
        lis = ""
        for commit in commits
          lis << "<li>#{commit.message}</li>\n"
        end
        if lis.length < 1
          lis <<"<li><em>Unknown changes.</em></li>"
        end
        this_partial.sub!("$FEATURELIST", lis)
      
        versions_html << this_partial
        
      end
    end
    
    layout.sub!("$VERSIONS", versions_html)
    
    layout
  end
  
  def previous_releases_hash
    file = open("#{SETTINGS["base_url"]}/releases.yml")
    contents = file.read
    yams = YAML::load(contents)
    # puts yams
    yams
  end
  
  def releases_list_data
    hash = previous_releases_hash
    unless hash[current_version_number]
      hash[current_version_number] = {"head" => current_head_id, "date" => Time.now, "human_version" => human_version(current_version_number)}
    end
    hash
  end
    
  def current_head_id
    repo = Grit::Repo.new(Pathname.new(CURRENT_DIR).parent)
    repo.commits.first.id
  end
  
  def human_version(version)
    "b#{version}"
  end
  
  def last_commit
    file = open("#{SETTINGS["base_url"]}/head_id.txt")
    contents = file.read
    contents
  end
  
  def write_file(path, contents)
    File.open(path, 'w') {|f| f.write(contents) }
  end
  
  def upload_public_file_to_s3(file, s3_path)
    s3 = AWS::S3.new( :access_key_id => SETTINGS["s3_access_key_id"], :secret_access_key => SETTINGS["s3_secret_access_key"])
    file_thing = s3.buckets[SETTINGS["s3_bucket"]].objects[s3_path]
    file_thing.write(File.read(file))
    file_thing.acl = :public_read
  end
  
  def s3_url(s3_path)
    s3 = AWS::S3.new( :access_key_id => SETTINGS["s3_access_key_id"], :secret_access_key => SETTINGS["s3_secret_access_key"])
    file_thing = s3.buckets[SETTINGS["s3_bucket"]].objects[s3_path]
    file_thing.public_url(secure: true).to_s
  end
  
  def tempdir
    Dir.tmpdir
  end
  
  def temporary_zipped_version_path
    "#{tempdir}/#{zipped_filename}"
  end
  
  def temporary_appcast_path
    "#{tempdir}/appcast.xml"
  end
  
  def temporary_release_notes_path
    "#{tempdir}/release_notes.html"
  end
  
  def temporary_head_path
    "#{tempdir}/head_id.txt"
  end
  
  def temporary_release_list_path
    "#{tempdir}/releases.yml"
  end
  
  def zipped_filename
    "#{SETTINGS["app_name"]}_#{current_version_number}.zip".downcase
  end
  
  def current_version_number
    plist = CFPropertyList::List.new(:file => "#{SETTINGS["built_app_path"]}/Contents/Info.plist")
    data = CFPropertyList.native_types(plist.value)
    data["CFBundleVersion"]
  end

  def self.zip_folder(folder_in, zip_name)
    `cd #{folder_in};cd ..;zip -r "#{folder_in}.zip" "#{Pathname.new(folder_in).basename}"`
    FileUtils.mv("#{folder_in}.zip", "#{zip_name}")
  end
  
end

AutoAppcast.new.release!
