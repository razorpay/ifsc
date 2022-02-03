<?php

namespace Razorpay\IFSC;

use Psr\Http\Message\ResponseInterface;

class Entity
{
    protected $bankCode;
    protected $bank;
    protected $code;
    protected $branch;
    protected $address;
    protected $contact;
    protected $city;
    protected $district;
    protected $state;

    public function __construct(ResponseInterface $response)
    {
        $data = json_decode($response->getBody(), true);

        if ($data) {
            $this->branch = $data['BRANCH'];
            $this->bank = $data['BANK'];

            $this->code = $this->ifsc = $data['IFSC'];
            $this->bankCode = $data['BANKCODE'];

            $this->address = $data['ADDRESS'];
            $this->contact = $data['CONTACT'];
            $this->district = $data['DISTRICT'];
            $this->state = $data['STATE'];
            $this->city = $data['CITY'];
            $this->centre = $data['CENTRE'];

            $this->neft = $data['NEFT'];
            $this->rtgs = $data['RTGS'];
            $this->upi = $data['UPI'];
            $this->imps = $data['IMPS'];
            $this->micr = $data['MICR'];
            $this->swift = $data['SWIFT'];
        }
    }

    public function getBankCode()
    {
        return $this->bankCode;
    }

    public function getBankName()
    {
        return IFSC::getBankName($this->getBankCode());
    }

    public function __get ($name)
    {
        return $this->$name ?? null;
    }
}
