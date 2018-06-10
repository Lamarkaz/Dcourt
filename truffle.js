module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "5777" // Match any network id,
    }
  },
  solc: {
  optimizer: {
    enabled: true,
    runs: 200
  }
}
};
