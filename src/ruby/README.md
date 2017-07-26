# Razorpay IFSC gem

### Install

```sh
gem install ifsc
```

### Usage

Validating a code offline. (Remember to keep the gem up to date!)

```rb
# valid?

Razorpay::IFSC::IFSC.valid? 'KKBK0000261'# => true
Razorpay::IFSC::IFSC.valid? 'BOTM0XEEMRA' # => false

# validate!

Razorpay::IFSC::IFSC.validate! 'KKBK0000261'# => true
Razorpay::IFSC::IFSC.validate! 'BOTM0XEEMRA' # => Razorpay::IFSC::InvalidCodeError
```

Validate online and retrieve details from the server

If you call `code.valid?` before calling `code.get`, the validation will be performed offline.

```rb
# 1. using find
code = Razorpay::IFSC::IFSC.find 'KKBK0000261'

# 2. using new(...).get
code = Razorpay::IFSC::IFSC.new 'KKBK0000261'
code.get

# result
code.valid?
# => true
code.bank
# => "Kotak Mahindra Bank"
code.branch
# => "GURGAON"
code.address
# => "JMD REGENT SQUARE,MEHRAULI GURGAON ROAD,OPPOSITE BRISTOL HOTEL,"
code.contact
# => "4131000"
code.city
# => "GURGAON"
code.district
# => "GURGAON"
code.state
# => "HARYANA"

```

### Error handling

```rb
# all these `Razorpay::IFSC::InvalidCodeError` for an invalid code
Razorpay::IFSC::IFSC.validate! '...'
Razorpay::IFSC::IFSC.find '...'
code = Razorpay::IFSC::IFSC.new '...'; code.get

# these raise `Razorpay::IFSC::ServerError` if there is an error
# communicating with the server
Razorpay::IFSC::IFSC.find '...'
code = Razorpay::IFSC::IFSC.new '...'; code.get
```
