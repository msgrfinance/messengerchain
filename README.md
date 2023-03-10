<!--
parent:
  order: false
-->

<div align="center">
  <h1> MessengerChain </h1>
</div>

<div align="center">
  <a href="https://github.com/msgrfinance/messengerchain/releases/latest">
    <img alt="Version" src="https://img.shields.io/github/tag/msgrfinance/messengerchain.svg" />
  </a>
  <a href="https://github.com/msgrfinance/messengerchain/blob/main/LICENSE">
    <img alt="License: Apache-2.0" src="https://img.shields.io/github/license/msgrfinance/messengerchain.svg" />
  </a>
  <a href="https://pkg.go.dev/github.com/msgrfinance/messengerchain?tab=doc">
    <img alt="GoDoc" src="https://godoc.org/github.com/msgrfinance/messengerchain?status.svg" />
  </a>
  <a href="https://goreportcard.com/report/github.com/msgrfinance/messengerchain">
    <img alt="Go report card" src="https://goreportcard.com/badge/github.com/msgrfinance/messengerchain"/>
  </a>
</div>
<div align="center">
  <a href="https://github.com/msgrfinance/messengerchain">
    <img alt="Lines Of Code" src="https://tokei.rs/b1/github/msgrfinance/messengerchain" />
  </a>
</div>

This repository hosts messengerchain, the implementation of the messengerchain based on the [Cosmos SDK](https://github.com/cosmos/cosmos-sdk).

**Note**: Requires [Go 1.18+](https://golang.org/dl/)

## INSTALL MSGRCD

This guide will explain how to install the msgrcd entrypoints onto your system.

#### Step 1 : Install Go

Install go by following the <a href="https://golang.org/doc/install">official docs</a>. Remember to set your $PATH environment variable, for example:

```bash
mkdir -p $HOME/go/bin  
echo "export PATH=$PATH:$(go env GOPATH)/bin" >> ~/.bash_profile  
echo "export GOPATH=$HOME/go" >> ~/.bash_profile  
echo "export GOBIN=$GOPATH/bin" >> ~/.bash_profile  
echo "export PATH=$PATH:$GOBIN" >> ~/.bash_profile  
source ~/.bash_profile  
```

Under Windows, you may set environment variables(HOME or GO111MODULE) through the “Environment Variables” button on the “Advanced” tab of the “System” control panel. Some versions of Windows provide this control panel through the “Advanced System Settings” option inside the “System” control panel.

```bash
$env:GO111MODULE="on"
```

#### Step 2 : Build install msgrcd

Next, let’s install the latest version of LSBChain. Make sure you git checkout the [latest released version](https://github.com/msgrfinance/messengerchain/releases).  

```bash
git clone -b <latest-release-tag> https://github.com/msgrfinance/messengerchain
export GO111MODULE=on
cd messengerchain && make install
```

If this command fails due to the following error message, you might have already set LDFLAGS prior to running this step.

```bash
flag provided but not defined: -L
usage: link [options] main.o
...
make: *** [install] Error 2
```

Unset this environment variable and try again.

```bash
LDFLAGS="" make install
```

> **NOTE:** If you still have issues at this step, please check that you have the latest stable version of GO installed.  

#### Step 3 : Verify msgrcd

That will install the msgrcd binaries. Verify that everything is OK:

```bash
$ msgrcd version --long
```

msgrcd for instance should output something similar to:

```bash
name: msgrcd
server_name: msgrcd
version: 1.0.0
commit: 3a419991283c48c6d9facfff8771f8a21e30a9a7
build_tags: netgo,ledger
go: go version go1.15.8 darwin/amd64
build_deps:
- github.com/cosmos/cosmos-sdk@v0.39.2
- github.com/tendermint/tendermint@v0.33.9
- ...
```

## REFERENCES

### Cosmos

[Cosmos Hub](https://hub.cosmos.network/)

[Cosmos SDK](https://docs.cosmos.network/)

[Tendermint Core](https://docs.tendermint.com/)

[Cosmos Rest Api](https://cosmos.network/rpc)