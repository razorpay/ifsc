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
            $this->bank = $data['BANK'];
            $this->branch = $data['BRANCH'];
            $this->address = $data['ADDRESS'];
            $this->contact = $data['CONTACT'];
            $this->city = $data['CITY'];
            $this->code = $this->ifsc = $data['IFSC'];
            $this->district = $data['DISTRICT'];
            $this->state = $data['STATE'];
            $this->bankCode = $data['BANKCODE'];
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
