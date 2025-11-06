const hre = require("hardhat");

async function main() {
  const [deployer, coopAdmin, producer, transporter, inspector, buyer] = await hre.ethers.getSigners();
  const BatchRegistry = await hre.ethers.getContractFactory("BatchRegistry");
  const registry = await BatchRegistry.deploy(coopAdmin.address);
  await registry.deployed();
  console.log("BatchRegistry deployed to:", registry.address);

  // assign roles (demo)
  await registry.connect(coopAdmin).assignRole(producer.address, hre.ethers.utils.id("PRODUCER"));
  await registry.connect(coopAdmin).assignRole(transporter.address, hre.ethers.utils.id("TRANSPORTER"));
  await registry.connect(coopAdmin).assignRole(inspector.address, hre.ethers.utils.id("INSPECTOR"));
  await registry.connect(coopAdmin).assignRole(buyer.address, hre.ethers.utils.id("BUYER"));

  console.log("Roles assigned to demo accounts");

  // create demo batch and checkpoints
  const tx1 = await registry.connect(producer).createBatch("COOP-TRACE-001", "Mixed-Agribusiness", 500, "QmSampleIpfsHash1");
  await tx1.wait();
  await registry.connect(transporter).addCheckpoint(1, "TRANSPORTER", "collected", "QmPhoto1", "Picked up at 07:00");
  await registry.connect(inspector).addCheckpoint(1, "INSPECTOR", "tested", "QmLab1", "Passed quality checks");
  console.log("Demo batch and checkpoints created");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
