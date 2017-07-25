# Razorpay IFSC gem

### Install

```sh
gem install ifsc
```

### Usage

Validating a code

```rb
# valid?

Razorpay::IFSC::Code.valid? 'KKBK0000261'# => true
Razorpay::IFSC::Code.valid? 'BOTM0XEEMRA' # => false

# validate!

Razorpay::IFSC::Code.validate! 'KKBK0000261'# => true
Razorpay::IFSC::Code.validate! 'BOTM0XEEMRA' # => Razorpay::IFSC::InvalidCodeError
```

Retrieving details from the server

```rb
# 1. using find
code = Razorpay::IFSC::Code.find 'KKBK0000261'

# 2. using new(...).get
code = Razorpay::IFSC::Code.new('KKBK0000261')
code.get

# result
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
Razorpay::IFSC::Code.validate! '...'
Razorpay::IFSC::Code.find '...'
code = Razorpay::IFSC::Code.new '...'; code.get

# these raise `Razorpay::IFSC::ServerError` if there is an error
# communicating with the server
Razorpay::IFSC::Code.find '...'
code = Razorpay::IFSC::Code.new '...'; code.get
```
