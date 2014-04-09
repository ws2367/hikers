# configure AWS credentials
path = "script/setenv.sh"
begin
  File.readlines(path).each do |line|
    values = line.split("=")
    var_name = values[0].split(" ")[1]
    ENV[var_name] = values[1].chomp
    puts "[DEBUG] Env variable %s is set." % var_name
  end
rescue
  puts
  puts "[ERROR] CANNOT find the credential file at path %s" % path
  puts
end
  
AWS.config({
  :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
  :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
})