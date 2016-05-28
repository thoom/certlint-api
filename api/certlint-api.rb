$LOAD_PATH.unshift '/usr/local/certlint/lib'

require 'sinatra'
require 'certlint'
require 'json'

configure do
  set show_exceptions: false
end

before do
  content_type 'text/plain'
end

get '/' do
  'Certificate Utilities'
end

post '/parse' do
  raw = request.body.read
  halt 400, 'invalid request' if raw.empty?

  if raw.include? '-BEGIN CERTIFICATE-'
    m, der = CertLint::PEMLint.lint(raw, 'CERTIFICATE')
  else
    m = []
    der = raw
  end

  content_type 'text/plain'
  OpenSSL::X509::Certificate.new(der).to_text
end

post '/lint' do
  raw = request.body.read
  halt 400, 'invalid request' if raw.empty?

  if raw.include? '-BEGIN CERTIFICATE-'
    m, der = CertLint::PEMLint.lint(raw, 'CERTIFICATE')
  else
    m = []
    der = raw
  end

  errors = []
  warnings = []
  infos = []
  fatals = []
  bugs = []
  notices = []
  other = []

  m += CertLint::CABLint.lint(der)
  m.each do |msg|
    status = msg[0...1]
    message = msg[2..-1].strip

    case status
    when 'B'
      bugs << message
    when 'N'
      notices << message
    when 'E'
      errors << message
    when 'W'
      warnings << message
    when 'I'
      infos << message
    when 'F'
      fatals << message
    else
      other << msg
    end
  end

  json = {}
  json[:fatals] = fatals unless fatals.empty?
  json[:errors] = errors unless errors.empty?
  json[:infos] = infos unless infos.empty?
  json[:notices] = notices unless notices.empty?
  json[:warnings] = warnings unless warnings.empty?
  json[:bugs] = bugs unless bugs.empty?
  json[:other] = other unless other.empty?

  content_type 'application/json'
  json.to_json
end

not_found do
  "How'd you get here?"
end

error do
  'Oops, I did it again'
end
