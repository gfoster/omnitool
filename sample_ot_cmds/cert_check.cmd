# -*- mode: ruby -*-
# make sure an ssl private key matches up properly with the cert and/or csr

setup do
  @cert_file = @options[:pem]
  @csr_file  = @options[:csr]
  @key_file  = @options[:key]
  @quiet     = @options[:q]

  if @key_file.nil?
    raise "You must specify a key file"
  end

  if @csr_file.nil? and @cert_file.nil?
    raise "You must specify either a cert and/or a csr file"
  end
end


command :check, "verify your private key matches csr and/or certs" do
  rc = 0

  key_md5 = %x(openssl rsa -noout -modulus -in #{@key_file} | openssl md5)
  puts "key_md5: #{key_md5}" unless @quiet

  if @cert_file
    cert_md5 = %x(openssl x509 -noout -modulus -in #{@cert_file} | openssl md5)
    if key_md5 == cert_md5
      puts "key matches cert" unless @quiet
    else
      puts "key does not match cert" unless @quiet
      rc = 1
    end
  end

  if @csr_file
    csr_md5 = %x(openssl req -noout -modulus -in #{@csr_file} | openssl md5)
    if csr_md5 == key_md5
      puts "key matches csr" unless @quiet
    else
      puts "key does not match csr" unless @quiet
      rc = 1
    end
  end

  exit rc
end

option :p, :pem, :description => "<cert filename>"
option :k, :key, :description => "<key filename>"
option :c, :csr, :description => "<csr filename>"

option :q, :switch => true, :description => "quiet mode"
