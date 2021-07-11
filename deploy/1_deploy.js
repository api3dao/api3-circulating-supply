module.exports = async ({ getUnnamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const accounts = await getUnnamedAccounts();
  const api3CirculatingSupply = await deploy("Api3CirculatingSupply", { from: accounts[0], });
  console.log(`Deployed at ${api3CirculatingSupply.address}`);
};
