const ethers = require("ethers");
const Api3CirculatingSupply = require("../deployments/mainnet/Api3CirculatingSupply.json");

module.exports.getCirculatingSupply = async function () {
  try {
    const provider = new ethers.providers.JsonRpcProvider(process.env.PROVIDER_URL);
    const api3CirculatingSupply = new ethers.Contract(
      Api3CirculatingSupply.address,
      ["function getCirculatingSupply() view returns (uint256)"],
      provider
    );
    const circulatingSupply = await api3CirculatingSupply.getCirculatingSupply();
    return { statusCode: 200, body: circulatingSupply.toString() };
  }
  catch (err) {
    return { statusCode: 500, body: err };
  }
}
