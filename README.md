# Marketo

## Usage

```
config = {
  rest_endpoint: "https://123-ABC-001.mktorest.com/rest",
  identity_endpoint: "https://123-ABC-001.mktorest.com/identity",
  client_id: "testid",
  client_secret: "testsecret"
}

client = Marketo::Client.new_marketo_client(config)
```

You can also configure it like so:
```
Marketo.configure do |config|
  config.client_id = "myclientid"
  ...
end
```

If you have a lead's ID in marketo, you can use get_lead_by_id to get their attributes.
`client.get_lead_by_id(123456)`

You can also get them by email:
`client.get_lead_by_email("lead_email@synergy.biz")`

To sync a lead and associate them with a new Munchkin cookie (request.cookies["_mkto_trk"]), use sync_lead:
```
lead1 = {"firstName"=>"Joe",
  "lastName"=>"Schmoe",
  "company"=>"Backupify"}

client.sync_lead(lead1, "Program", request.cookies["_mkto_trk"])
```

You can also batch sync leads:
```
lead2 = {"firstName"=>"Joe",
  "lastName"=>"Schmoe Jr.",
  "company"=>"Datto"}
client.sync_multiple([lead1, lead2])
```

## Testing

Create spec/config/marketo.yml by copying the example in the same folder and substituting the correct values for your marketo instance, [which you can find following these instructions.](http://developers.marketo.com/rest-api/authentication/)

## Current Contributors

* [Evan Wheeler](http://github.com/vnwhlr)
