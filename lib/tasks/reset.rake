# initializers are called because the rake task depends on environment
desc "Rebuild database, create a photo bucket and source credentials"
task :reset, [] => :environment do

  puts "[DEBUG] Will drop existing database!"
  Rake::Task['db:drop'].execute
  Rake::Task['db:create'].execute
  Rake::Task['db:migrate'].execute
  puts "[DEBUG] New DB created and migrated."
  
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