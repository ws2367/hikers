
desc "Rebuild database, create a photo bucket and source credentials"
task :reset, [] => :environment do

  puts "[DEBUG] Will drop existing database!"
  Rake::Task['db:drop'].execute
  Rake::Task['db:create'].execute
  Rake::Task['db:migrate'].execute
  puts "[DEBUG] New DB created and migrated."

  # String format in script/setenv.sh has to be 
  # export [var name]=[value]
  File.readlines("script/setenv.sh").each do |line|
    values = line.split("=")
    var_name = values[0].split(" ")[1]
    ENV[var_name] = values[1].chomp
    puts "[DEBUG] Env variable %s is set." % var_name
  end
  
  s3 = AWS::S3.new(:access_key_id => ENV['AWS_ACCESS_KEY_ID'],
                   :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY'])

  bucket_name = "moose-" + UUIDTools::UUID.random_create.to_s
  bucket = s3.buckets.create(bucket_name)
  unless bucket.exists?
    puts "[ERROR] CANNOT create a bucket named %s on S3! Reborn aborted." % bucket_name
    return
  end

  File.open('config/photo_bucket_name', 'w') { |file| file.write("photo_bucket_name=%s" % bucket_name) }
  puts "[DEBUG] New S3 bucket %s is created." % bucket_name

  
end