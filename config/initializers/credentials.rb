# configure AWS credentials
path = "config/app_credentials"
var_names = Array.new
begin
  File.readlines(path).each do |line|
    values = line.split("=")
    var_name = values[0].chomp.strip
    ENV[var_name] = values[1].chomp.strip
    var_names << var_name
  end
  if var_names.count > 1
    logger.info "[DEBUG] ENV variables %s are set." % var_names.join(' ,')
  elsif var_names.count > 0
    logger.info "[DEBUG] ENV variable %s is set." % var_names.join(' ,')
  else
    logger.info "[DEBUG] No ENV variable is set."
  end
rescue
  logger.info
  logger.info "[ERROR] CANNOT find the credential file at path %s" % path
  logger.info
end
  

AWS.config({
  :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
  :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
})