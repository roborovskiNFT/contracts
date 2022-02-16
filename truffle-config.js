module.exports = {
  contracts_build_directory: './build',

  compilers: {
    solc: {
      version: "0.8.10",
      settings: {
        optimizer: {
          enabled: true,
          runs: 999999
        },
      },
    },
  },
};
