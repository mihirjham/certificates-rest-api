json.id @certificate.id
json.object "certificate"
json.active @certificate.active
json.private_key @certificate.private_key
json.certificate @certificate.body

if @response
  json.notify_status @response.code
  json.notify_body @response.body
end
