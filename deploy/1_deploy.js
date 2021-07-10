module.exports = async ({ getUnnamedAccounts, deployments }) => {
  const { deploy } = deployments;
  const accounts = await getUnnamedAccounts();
  const lockedApi3 = await deploy("LockedApi3", { from: accounts[0], });
  console.log(`Deployed at ${lockedApi3.address}`);
};
