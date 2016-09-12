# Certificates REST API

HTTP-based RESTful API for managing Customers and their Certificates

## Setup Instructions

### Prerequistes

* Ruby(version 2.1.2)
* Postgres
* Bundler
* Rails 

To help set up your environment, you can follow the instructions [here](https://github.com/appacademy/dotfiles)

### Loading up the server

```
bundle install
bundle exec rake db:create
bundle exec rake db:migrate
bundle exec rails s
```

## Index

| Endpoint | Description |
| ---- | --------------- |
| POST /api/v1/customers/ | Create a Customer |
| DELETE /api/v1/customers/:id | Delete a Customer |
| POST /api/v1/customers/:customer_id/certificates | Create a Certicate based on a customer |
| GET /api/v1/customers/:customer_id/certificates/active | Gets all of a Customer’s Active Certificates|
| PUT /api/v1/certificates/activate | Activates a certificate |
| PUT /api/v1/certificates/deactivate | Deactivates a certificate |

## Examples

### Errors

```
HTTP/1.1 422 Unprocessable Entity
X-Frame-Options: SAMEORIGIN
X-Xss-Protection: 1; mode=block
X-Content-Type-Options: nosniff
Content-Type: application/json; charset=utf-8
Cache-Control: no-cache
X-Request-Id: 83e458a7-b3ee-46b9-9e80-082a4fbf7452
X-Runtime: 0.004448
Server: WEBrick/1.3.1 (Ruby/2.1.2/2014-05-08)
Date: Mon, 12 Sep 2016 09:36:15 GMT
Content-Length: 60
Connection: Keep-Alive

{"error":"param is missing or the value is empty: customer"}%
```

### POST /api/v1/customers/

#### Request

##### data.json
```json
{
  "customer":{
    "name": "Mihir",
    "email_address":"mihir@mihirjham.com"
  }
}
```

```
curl -X POST localhost:3000/api/v1/customers/ -d @data.json -H "Content-Type:application/json" -i
```

#### Response

```
HTTP/1.1 201 Created
X-Frame-Options: SAMEORIGIN
X-Xss-Protection: 1; mode=block
X-Content-Type-Options: nosniff
Content-Type: application/json; charset=utf-8
Etag: W/"5ef2dfac36287f8be572d50e98b6dfea"
Cache-Control: max-age=0, private, must-revalidate
X-Request-Id: da098a09-33d6-400e-a5f9-eb413e723f81
X-Runtime: 0.053330
Server: WEBrick/1.3.1 (Ruby/2.1.2/2014-05-08)
Date: Mon, 12 Sep 2016 09:35:17 GMT
Content-Length: 118
Connection: Keep-Alive

{"id":"6a814597-080b-4228-b9ee-144e172265d7","object":"customer","name":"Mihir","email_address":"mihir@mihirjham.com"}%
```

### DELETE /api/v1/customers/:id

#### Request

```
curl -X DELETE localhost:3000/api/v1/customers/6a814597-080b-4228-b9ee-144e172265d7 -i
```

#### Response

```
HTTP/1.1 204 No Content
X-Frame-Options: SAMEORIGIN
X-Xss-Protection: 1; mode=block
X-Content-Type-Options: nosniff
Cache-Control: no-cache
X-Request-Id: aa69e61e-3e87-4ead-ab38-166031256900
X-Runtime: 0.031033
Server: WEBrick/1.3.1 (Ruby/2.1.2/2014-05-08)
Date: Mon, 12 Sep 2016 09:39:02 GMT
Connection: Keep-Alive
```




