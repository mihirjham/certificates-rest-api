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
bundle exec rake db:seed
bundle exec rails s
```

## Libraries

I have used the following libraries
 * Kaminari(Pagination)
 * RestClient(to make POST requests from the CertificatesController#activate and #deactivate methods)
 * OpenSSL - OpenSSL::PKey::RSA and OpenSSL::X509::Certificate for the generation of the private key and certificates.
 * RSpec - Testing framework
 * FactoryGirl - For setting up Ruby objects for test data
 * Shoulda Matchers - Testing helper

## Index

| Endpoint | Description |
| ---- | --------------- |
| POST /api/v1/customers/ | Create a Customer |
| DELETE /api/v1/customers/:id | Delete a Customer |
| POST /api/v1/customers/:customer_id/certificates | Create a Certicate based on a customer |
| GET /api/v1/customers/:customer_id/certificates/active | Gets all of a Customer’s Active Certificates|
| PUT /api/v1/certificates/activate | Activates a certificate |
| PUT /api/v1/certificates/deactivate | Deactivates a certificate |

## Features

* Creating and Deleting Customers
* Creating Certificates for Customers
* Viewing all active Certificates for Customers
* Activating and Deactivating Certificates for Customers
* Notifying other services when a certificate is activated/deactivated
* Pagination on GET requests
* Versioning

## Design Choices

### Postgres
  * RDBMS - The features of having relations between customers and certificates led me to choosing an RDBMS
  * Verified Performance at scale - Postgres has been used by major companies and has allowed them to serve and store millions of records. Potential tradeoff - MongoDB, but the data is not truly denormalized in this case.
  * Keeping joins to a minimum - this make sure this bottleneck is kept at a minimum
  * Indexing only when needed - Indexing allows for faster queries, but comes at a price of having more data stored in memory, rather than disk. I chose to only index fields that were being constantly searched, such as foreign keys and unique fields(such as the email_address column on the customers table)

### Rails
  * Simple to set up
  * Has proven to serve lots of requests - Twitter used it for a while.
  * Has potential to scale but has a peak, due to it being heavy as it comes with lots of features out of the box.

### Versioning
  * BaseApiController has lots of shared methods between CustomersController and CertificatesController
  * We might reach the point where we must have a break change because the requirements changed. All we have to do is define the same routes but for V2 namespace, define the V2 controllers that inherit from V1 controllers and override any method we want.

### Pagination
  * GET requests
  * Limits number of records served - increases the performance since it renders only a fraction of the total resources.
  * Prevention from possible attack by overload - the per_page resource can be changed to a very large number. There's a limit of up to 100 to prevent this kind of attack.

### Appropriate HTTP Status Codes
  * 200,201,204 - Success codes
  * 404,409,422 - Error codes
  * 500 - Internal server error codes

### 

## Potential Optimizations
  
  * Rate Limit - Rate limit is a good way to filter unwanted bots or users that abuse our API. Can use the `redis-throttle` gem, which uses redis to store the limits based on the user's IP.
  * CORS - A specification that "that enables many resources (e.g. fonts, JavaScript, etc.) on a web page to be requested from another domain outside the domain from which the resource originated". We allow access from anywhere, as a proper API. We can set restrictions on which clients are allowed to access the API by specifying the hostnames in origins.
  * Caching most requested items - Using Redis or memcached
  * Message Queue - Having a message queue that does the POST requests in the CertificatesController #activate and #deactivate methods. Right now, I wait for the response to come back, and this could take really long. Having a message queue like a RabbitMQ will add it to the queue and we will process these requests asynchronously. Ofcourse, we lose the abiity to return the notify status and notify response to the initial request.

## Testing

Used RSpec to write model unit tests and controller action tests.
Have to add more tests:
  * CertificatesController

```
bundle exec rspec
```

```
Customer
  name should not be too long
  email_address should not be too long
  email_address should be present
  should be valid?
  valid email_address should be accepted
  invalid email_address should be rejected
  name should be present
  email_address should be unique

Api::V1::CustomersController
  destroy
    returns a status of 404 if not found
    returns a status of 204 if successful
  create
    returns a status of 201
    returns a status of 409 if already exists

Certificate
  should be valid?
  should have a body
  should belong to only one customer
  should have a unique private_key
```

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

### POST /api/v1/customers/:customer_id/certificates

#### Request

```
curl -X POST localhost:3000/api/v1/customers/515a498e-e397-46dd-805d-4d88c08db64e/certificates -i -d ''
```

#### Response

```
HTTP/1.1 201 Created
X-Frame-Options: SAMEORIGIN
X-Xss-Protection: 1; mode=block
X-Content-Type-Options: nosniff
Content-Type: application/json; charset=utf-8
Etag: W/"909851c13f1e903b3ca01a18d535615e"
Cache-Control: max-age=0, private, must-revalidate
X-Request-Id: 7eb00a5a-f1eb-4580-811e-5e11b3c0d1d4
X-Runtime: 0.220635
Server: WEBrick/1.3.1 (Ruby/2.1.2/2014-05-08)
Date: Mon, 12 Sep 2016 10:24:41 GMT
Content-Length: 2082
Connection: Keep-Alive

{"id":"ff639488-72f7-4e6b-b369-b3ad0e84f2d9","object":"certificate","active":true,"private_key":"-----BEGIN RSA PRIVATE KEY-----\nMIIEowIBAAKCAQEA2i/a6djRPSFh5qBxDtytCbcXSgsC/yveudRYCxQOhjn/kgrh\nEm+ALQyV4EN7/kR1z5mLSJbwkwQXRtKXsQ/OT/jN0/AlAP2T65uTltnKVesCh/27\ndNVHdtlCDrbj7XjecUuD/Q3qs1LUg3682OfxSIp9g2OnJ3rZhdJaNxoC9sASSlb1\nr2R+gpt6kky2vfQ9sW4zfFmwdHmjK3F8l3nxeRAWspR+qNJTkymmZVFmZUgV+a8W\n+XTqfJ5dN4X5kw5ay1Ms+1IAq3m+ZvfFg1LDllyh5sJUMRfoNkEDXicVy1aInKfg\nD20jU2lTj+wt/5uvZFf6+MAhGzIhSisaGHeEkQIDAQABAoIBAQCSbdF+ZWuvmgrJ\nK94UeleLEJyJrbA6LmgQ0QixjqlcveneSnzY0Yn1MeAYHVJGyA1E4ShP9DTKhdFV\nT5pMU25Dz5fbZ+x9qLEwSz4W3F1log4V1FyNQWHvykkB9Q4s3pRy9ppDJ6be6HUF\nNvZon+kXpRItLqEM5u67V/wBxOw+SlVJbV1CTxgrN1r7ToHd6V8g/7k3w+mGLIsB\nS3HEw2cttL0Weu/uZfgl/tA/VQLxIanjCDo6lcFb6mk5nUx0DVSNwIs0ZjXn85L/\npb/vOrdyjY+JDwSKxePecKa8q++dynd77KGa101Q7ukpY/cN+d6fpltTj3PWQLyp\npuMqZ7QRAoGBAPzTjizQ7l1u2YVMgPK/ndesi3gwfxXrsFZWOm+P/T8B6e87CQYt\nBMufdnDclbp0JvimxT9oLh4b6LG//K8NgHYKi+Sj5PkOyyVZFRmAkw0boC7DXcM6\nEQ1Q0koTmdcd8p7AH2+aiNjK5GODYis4c/IMP3SM37BWDf5H6KikSfYVAoGBANzs\n/NatTM6j/xs8RtZso5s1uE4klqp4XFW1wMSKV00bmZeLPbIWIdS8O0cZbXAJhmtF\n2gs8jfEZzPlWnOZVJCT7I6un5ZGu8BtrQJ82NBmbChr9c7mZPVqVOVT647AtYwtv\n70iAntdCHq8OaZybQI3wg/nnsLF1xrgmNwfGwM+NAoGATnSTzQJ0xZetdnj8Ftgx\ncgkAKqbZ+QJvcQtHDPGgw5mjb3JhZYI417s/NNyutfJvWX/e+8MndH5yoh4SmnvV\nHkw9hxD47/SQQ6G2M3i7qTimZ3yGrxtoyToIV6ZneeK4NF0oJCjPSH8Fin/tyb21\n9Smp01AX5g9+PicwYozAytUCgYBozR9P81vZNuDAmcJ824JtEXnB0AeNDJW4rwSn\n93xcfrhItGvq/CbGVRjFrKFGoa4bW0KJTAuFkRi0O0so1MDVrjEIsBfuGQ+b4jAA\nluT2NJ8BmLP6GmCJhPpyfqXeIFm4xju7qBAxyxLlNjARc3CXJL5moWsnc9h16OL4\nFGfIzQKBgBDr2FjVQ3CwJTq85NX6Fo/SW2Vf/COMSdTQwV27DDRgd/leFvZqmWwG\n69fXh2XIe+e3Ps/F9ybqVOhbxmptuj6kji8l9q8M3mAusJ5igLoUoEUbO1RX0Bwq\nvSVMwoXOCciwXJSkZ4vUvIvadYG/ap/U2+poETBhDmj628DtbB1b\n-----END RSA PRIVATE KEY-----\n","certificate":"-----BEGIN CERTIFICATE-----\nMIGRMIGHoAMCAQICAQAwAgYAMDQxDjAMBgNVBAMMBU1paGlyMSIwIAYJKoZIhvcN\nAQkBFhNtaWhpcmpoYW1AZ21haWwuY29tMAQfAB8AMDQxDjAMBgNVBAMMBU1paGly\nMSIwIAYJKoZIhvcNAQkBFhNtaWhpcmpoYW1AZ21haWwuY29tMAcwAgYAAwEAMAIG\nAAMBAA==\n-----END CERTIFICATE-----\n"}%
```

### GET /api/v1/customers/:customer_id/certificates/active

#### Request

```
curl -X GET localhost:3000/api/v1/customers/515a498e-e397-46dd-805d-4d88c08db64e/certificates/active -i -d per_page=2
```

#### Response

```
HTTP/1.1 200 OK
X-Frame-Options: SAMEORIGIN
X-Xss-Protection: 1; mode=block
X-Content-Type-Options: nosniff
Content-Type: application/json; charset=utf-8
Etag: W/"73871018bc66f3d69606bf05fcfb5b63"
Cache-Control: max-age=0, private, must-revalidate
X-Request-Id: 447e3f9f-30c3-427b-946e-abea47016f75
X-Runtime: 0.014547
Server: WEBrick/1.3.1 (Ruby/2.1.2/2014-05-08)
Date: Mon, 12 Sep 2016 10:30:08 GMT
Content-Length: 848
Connection: Keep-Alive

{"object":"list","data":[{"id":"ff5496d8-0953-41f2-a031-ff08cef4aed5","object":"certificate","active":true,"certificate":"-----BEGIN CERTIFICATE-----\nMIGRMIGHoAMCAQICAQAwAgYAMDQxDjAMBgNVBAMMBU1paGlyMSIwIAYJKoZIhvcN\nAQkBFhNtaWhpcmpoYW1AZ21haWwuY29tMAQfAB8AMDQxDjAMBgNVBAMMBU1paGly\nMSIwIAYJKoZIhvcNAQkBFhNtaWhpcmpoYW1AZ21haWwuY29tMAcwAgYAAwEAMAIG\nAAMBAA==\n-----END CERTIFICATE-----\n"},{"id":"35f305a4-aace-451a-947c-3eaf5fd67dfd","object":"certificate","active":true,"certificate":"-----BEGIN CERTIFICATE-----\nMIGRMIGHoAMCAQICAQAwAgYAMDQxDjAMBgNVBAMMBU1paGlyMSIwIAYJKoZIhvcN\nAQkBFhNtaWhpcmpoYW1AZ21haWwuY29tMAQfAB8AMDQxDjAMBgNVBAMMBU1paGly\nMSIwIAYJKoZIhvcNAQkBFhNtaWhpcmpoYW1AZ21haWwuY29tMAcwAgYAAwEAMAIG\nAAMBAA==\n-----END CERTIFICATE-----\n"}],"meta":{"current_page":1,"next_page":2,"prev_page":null,"total_pages":501,"total_count":1001}}%
```

### PUT localhost:3000/api/v1/certificates/activate

#### Request

##### data.json
```json
{
  "certificate": {
    "private_key":"-----BEGIN RSA PRIVATE KEY-----\nMIIEpAIBAAKCAQEAw75sFGcjBOlS//8pC0qLFD0XMoji9o28GoRjgORt+VMh2irG\ni0dVUgVzWtYtr563P96MD3a6wcliZoQP+CS9gJMhVJEP21j0+VosbFCZlDwkwTBy\njBz3+zOlrTpfyv6pRu5ruZcYY9VDjFJTWPV+XhjXp26EkDjApS4rSjqBzXdNjprM\nnBo6m9QJo/hw2ZujjrD16psEbwpCTsrC+G+iMXUsNhao2UuWHeojcDYdoqzzoPOZ\n+itPxr4I+c4JezKSNOrw5Yy6eHujO/zuTgXJBaLUm7SE9GpMeivj9yThFQtMZVGU\nNChZX5ft3dLSErvWTaNG7y0X3B96bA3PiwvJNQIDAQABAoIBAGVKT3FLYYK0HmAc\nMKgIHeoOJsfer9u3wkPSiA71pbbj/tt/URhXhF4aNfQmaqO7NMZXKhECdme7BzFX\nW1Aj6u/ysseo/RSbdsDlmaE/IAnmCXry0AOTJfuWYUA/ubw4hW4QCCyUdGmMvRSK\nsViSSJ72qfmZJf3fcEjJmFsj5XFlSC2ZaddqE69WaODbyp+VVJD/dlv2s/YmEpYm\niUYmx5/MrvTtarGXrVDJMvsgPxUS29pVJTYH4Q/L5FWLLVgMyjWCYX2/my16/d+D\nhq/MVa9pT4/xvnnqTsI0ggd8K8I2NoJclkWXKPof0mOtH7nS7NX35wFkt1DNkW6K\nPv03/S0CgYEA53zeyNK1HdawVkA8M2ntz/x0SnqzczkIsVVh1PB0KVMMcfBZfE9N\nuxu553Lp0SZCP6UM8BTr5EX3ooxsSju5bMmkGb4bXEagNfledluh3DkQO4fZcgUk\nN1qwR7kZ+RlLiIJIcMystVCOhxHjXUC5MLUbjUd1xWSUokq8vSCv+9MCgYEA2Hic\nkD9GydQ+ZiJGdgqUSbiwo1lmvb/kE08UV9YlLEpFQgv5KLY1ksdhQ9w9jfYUgTPG\n13dBKbnSMqHVhdKz3aLM+ziOGVWo0zO1D3R0alI+3DD91Sp+wsUhT4hArIbXl1CY\n4kmd8CAHyi/cjw9kRQK6R3xnUqq3T+HhLkJbqdcCgYBvC1mboGg9jhU86sd2KmRo\nF0R5ze5zYXKoDrtFeKtgf3RC2/cxSKGTFjPRsTA0olO5UCWqrX6THHU0RoRT/95t\nLzVHHAjn9QE5owwLXt2AVOdSh1Jp/clnvFs/rK2m7tlq/IRfh+95ctFMPeqBe2Da\n2qYC2brHG/6o840idKG2/QKBgQCkvFTZaW4jlkPOUfMxTae/2q+CAD0x1eBp2Vpv\n5eXwKK1AMABzPQbUJqsci3TEnirIkHCX9IdAi8stAP+PkeOTnZtE66soGIocAFOf\n6U3Ww7RWuWnSWT6SVpadAeHF6fATlSBjxQZOgPGsqnO840e5RPQiBshSntxWDF3j\naFh9jQKBgQDObHQdNRFi60BqpT4zIXyxQvF2Z60CEWCxMfl13LbZud87yZwTThvl\np5xP+FRNp2SuuXsZ+MamQ3y0+fno6qdPYEGrGDMSvwR8EaChlh0qiB4x0bcwMU5e\n/L4IVxoXYjrGA50OxpMoxndiSRHmO7pKcYe3f179Kcyq3LJBwzYQBg==\n-----END RSA PRIVATE KEY-----\n"
  },
  "notify": {
    "host": "http://requestb.in/1ksusmw1",
    "attributes": {
      "attr_1": {
        "a": "b"
      }
    }
  }
}

```

```
curl -X PUT localhost:3000/api/v1/certificates/activate -d @data.json -H "Content-Type:application/json" -i
```

#### Response

```
HTTP/1.1 200 OK
X-Frame-Options: SAMEORIGIN
X-Xss-Protection: 1; mode=block
X-Content-Type-Options: nosniff
Content-Type: application/json; charset=utf-8
Etag: W/"87a7b5519529ebe4f1e50db81b787568"
Cache-Control: max-age=0, private, must-revalidate
X-Request-Id: ef1eca3a-0fc3-4300-99fd-11108691b63d
X-Runtime: 0.314664
Server: WEBrick/1.3.1 (Ruby/2.1.2/2014-05-08)
Date: Mon, 12 Sep 2016 10:38:09 GMT
Content-Length: 2125
Connection: Keep-Alive

{"id":"ffbe609c-2a57-4ecb-ac74-a1f131258ae2","object":"certificate","active":true,"private_key":"-----BEGIN RSA PRIVATE KEY-----\nMIIEpAIBAAKCAQEAw75sFGcjBOlS//8pC0qLFD0XMoji9o28GoRjgORt+VMh2irG\ni0dVUgVzWtYtr563P96MD3a6wcliZoQP+CS9gJMhVJEP21j0+VosbFCZlDwkwTBy\njBz3+zOlrTpfyv6pRu5ruZcYY9VDjFJTWPV+XhjXp26EkDjApS4rSjqBzXdNjprM\nnBo6m9QJo/hw2ZujjrD16psEbwpCTsrC+G+iMXUsNhao2UuWHeojcDYdoqzzoPOZ\n+itPxr4I+c4JezKSNOrw5Yy6eHujO/zuTgXJBaLUm7SE9GpMeivj9yThFQtMZVGU\nNChZX5ft3dLSErvWTaNG7y0X3B96bA3PiwvJNQIDAQABAoIBAGVKT3FLYYK0HmAc\nMKgIHeoOJsfer9u3wkPSiA71pbbj/tt/URhXhF4aNfQmaqO7NMZXKhECdme7BzFX\nW1Aj6u/ysseo/RSbdsDlmaE/IAnmCXry0AOTJfuWYUA/ubw4hW4QCCyUdGmMvRSK\nsViSSJ72qfmZJf3fcEjJmFsj5XFlSC2ZaddqE69WaODbyp+VVJD/dlv2s/YmEpYm\niUYmx5/MrvTtarGXrVDJMvsgPxUS29pVJTYH4Q/L5FWLLVgMyjWCYX2/my16/d+D\nhq/MVa9pT4/xvnnqTsI0ggd8K8I2NoJclkWXKPof0mOtH7nS7NX35wFkt1DNkW6K\nPv03/S0CgYEA53zeyNK1HdawVkA8M2ntz/x0SnqzczkIsVVh1PB0KVMMcfBZfE9N\nuxu553Lp0SZCP6UM8BTr5EX3ooxsSju5bMmkGb4bXEagNfledluh3DkQO4fZcgUk\nN1qwR7kZ+RlLiIJIcMystVCOhxHjXUC5MLUbjUd1xWSUokq8vSCv+9MCgYEA2Hic\nkD9GydQ+ZiJGdgqUSbiwo1lmvb/kE08UV9YlLEpFQgv5KLY1ksdhQ9w9jfYUgTPG\n13dBKbnSMqHVhdKz3aLM+ziOGVWo0zO1D3R0alI+3DD91Sp+wsUhT4hArIbXl1CY\n4kmd8CAHyi/cjw9kRQK6R3xnUqq3T+HhLkJbqdcCgYBvC1mboGg9jhU86sd2KmRo\nF0R5ze5zYXKoDrtFeKtgf3RC2/cxSKGTFjPRsTA0olO5UCWqrX6THHU0RoRT/95t\nLzVHHAjn9QE5owwLXt2AVOdSh1Jp/clnvFs/rK2m7tlq/IRfh+95ctFMPeqBe2Da\n2qYC2brHG/6o840idKG2/QKBgQCkvFTZaW4jlkPOUfMxTae/2q+CAD0x1eBp2Vpv\n5eXwKK1AMABzPQbUJqsci3TEnirIkHCX9IdAi8stAP+PkeOTnZtE66soGIocAFOf\n6U3Ww7RWuWnSWT6SVpadAeHF6fATlSBjxQZOgPGsqnO840e5RPQiBshSntxWDF3j\naFh9jQKBgQDObHQdNRFi60BqpT4zIXyxQvF2Z60CEWCxMfl13LbZud87yZwTThvl\np5xP+FRNp2SuuXsZ+MamQ3y0+fno6qdPYEGrGDMSvwR8EaChlh0qiB4x0bcwMU5e\n/L4IVxoXYjrGA50OxpMoxndiSRHmO7pKcYe3f179Kcyq3LJBwzYQBg==\n-----END RSA PRIVATE KEY-----\n","certificate":"-----BEGIN CERTIFICATE-----\nMIGRMIGHoAMCAQICAQAwAgYAMDQxDjAMBgNVBAMMBU1paGlyMSIwIAYJKoZIhvcN\nAQkBFhNtaWhpcmpoYW1AZ21haWwuY29tMAQfAB8AMDQxDjAMBgNVBAMMBU1paGly\nMSIwIAYJKoZIhvcNAQkBFhNtaWhpcmpoYW1AZ21haWwuY29tMAcwAgYAAwEAMAIG\nAAMBAA==\n-----END CERTIFICATE-----\n","notify_status":200,"notify_body":"ok"}%
```


