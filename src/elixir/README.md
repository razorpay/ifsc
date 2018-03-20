# IFSC

[![Hex pm](http://img.shields.io/hexpm/v/ifsc.svg?style=flat)](https://hex.pm/packages/ifsc)

A simple package by @razorpay to help you validate your IFSC codes.

IFSC codes are bank codes within India

## Documentation

[https://hexdocs.pm/ifsc](https://hexdocs.pm/ifsc)

## Installation

Add `ifsc` to your list of dependencies in `mix.exs`:


```elixir
def deps do
  [
    {:ifsc, "~> 1.1.0"}
  ]
end
```

## Development and Publishing

Remember to run `mix ifsc.copy_json` to populate the `priv/ifsc-data` directory,
or the `Razorpay.IFSC.validate` function will not run.

This is because the root repository generates the IFSC data in `src/`, and to
access these files when the `ifsc` package is included in another project,
they must be inside `priv/`.

Thus `priv/ifsc-data` is gitignore'd but populated and included when publishing to Hex.
For local development, the task must be run manually.
