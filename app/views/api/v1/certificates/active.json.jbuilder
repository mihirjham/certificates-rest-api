json.object "list"
json.data do
  json.array! @certificates do |certificate|
    json.id certificate.id
    json.object "certificate"
    json.active certificate.active
    json.certificate certificate.body
  end
end
