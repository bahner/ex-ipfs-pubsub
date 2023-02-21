# IPFS RPC API client for Elixir

![](https://ipfs.io/ipfs/QmQJ68PFMDdAsgCZvA1UVzzn18asVcf7HVvCDgpjiSCAse)

[![Unit and integration tests](https://github.com/bahner/ex-ipfs/actions/workflows/testsuite.yaml/badge.svg)](https://github.com/bahner/ex-ipfs/actions/workflows/testsuite.yaml)
[![Coverage Status](https://coveralls.io/repos/github/bahner/ex-ipfs/badge.svg?branch=develop)](https://coveralls.io/github/bahner/ex-ipfs?branch=develop)

## This library is still a work in progress

The reason for starting a new IPFS module is that none of the others seem to work at all.

All commands added, but *not* verified. For your everyday IPFS operations the module should work by now. But no guarantees. :-) Please, please, please - file issues and feature requests.

Version 0.2.0 is substantially better than version 0.1.0. I consider it of beta-quality.

## Install

Add ex_ipfs to your `mix.exs` dependencies:
```elixir
def deps do
[
    {:ex_ipfs, "~> 0.2.0"},
]
end
```

and run `make mix` to install the dependencies.

## Configuration

The default should brobably be OK, but you may override the default with the environment variables.

```
export EX_IPFS_API_URL="http://127.0.0.1:5001"
```

## Documentation
The documentation is very unbalanced. I am feeling my way forward as to how much I should document here. Each command will receive a link to the official documentation at least.

## Usage
Make sure ipfs is running. Then you can start using the module. If ipfs isn't running, you may try `ExIPFS.daemon()`.

To use do:
```elixir
alias ExIPFS, as: IPFS
IPFS.id()

ExIPFS.Refs.refs("/ipns/ex.bahner.com")

alias ExIPFS.Refs
Refs.local()

# Subscribe to a PubSub Channel and send the message to my inbox
ExIPFS.PubSub.Channel.start_link(self(), "mychannel")
flush
```
Some commands, like channel and tail that streams data needs a pid to send messages to. 

The basic commands are in the ExIPFS module. The grouped ipfs commands each have their separate module, eg. ExIPFS.Refs, ExIPFS.Blocks etc.

## Development

If you want to update the IPFS version and create your own docker image to be used for testing, then export the following environment variables.
```
export KUBO_VERSION=0.17.0
export DOCKER_USER=bahner
export DOCKER_IMAGE=${DOCKER_USER}/kubo:${KUBO_VERSION}
make publish-image
```
so a shorthand would be:
```
KUBO_VERSION=v0.19.0rc2 DOCKER_USER=yourdockeraccount make publish-image # The simplest.
# or
KUBO_VERSION=0.17.0 DOCKER_IMAGE=http://my.local.registry:5000/testing-buils/ipfs:testlabl make publish-image
```

