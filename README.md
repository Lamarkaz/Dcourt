# Dcourt Smart Contracts (WIP)

Dcourt is a decentralized dispute arbitration 2nd-layer infrastructure based on the Ethereum platform that functions similar to a jury court.
This truffle project contains the core Solidity smart contracts of the [Dcourt](https://dcourt.io) project.
More information about the functionality of the smart contracts and the Dcourt project is available on the [Dcourt whitepaper](https://dcourt.io/whitepaper.pdf)


## Features

* [ERC20-compliant](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md) token
* Decentralized governance system
* Bounty system
* Pluggable dispute arbitration contract
* [Relayed transactions](https://blog.lamarkaz.com/2018/03/01/relayed-transactions-a-solution/) implementation
* Using safe practices from the [OpenZeppelin](https://openzeppelin.org/) project.
* Mocha unit tests

## Development

To set up your own development environment on an Ubuntu machine:

1. Clone this repo
`https://github.com/Lamarkaz/Dcourt & cd ./Dcourt`

2. Install truffle
`npm i -g truffle`

3. Run truffle development console
`truffle develop`

4. Run migration scripts
`migrate`

## Tests

<aside class="warning">
Tests are deprecated. To be updated soon.
</aside>

Each Solidity contract is packaged with Mocha unit tests.
Inside the truffle development console, run:
`test`

For a better test experience, we advise you to use Ganache, update truffle-config.js file accordingly then simply run:
`truffle test`

## Directories

Description | Location
--- | ---
*Contracts* | [contracts/](/contracts/)
*DCT Token Contracts* | [contracts/Token/](/contracts/Token/)
*Dcourt Arbitration Contracts* | [contracts/Arbitration/](/contracts/Arbitration/)
*Dcourt Token Presale Contracts* | [contracts/Presale/](/contracts/Presale/)
*Migrations* | [migrations/](/migrations)
*Tests* | [test/](/test)

## Authors
[Ihab McShea](https://github.com/ihabshea) & [Nour Haridy](https://github.com/nourharidy) 
