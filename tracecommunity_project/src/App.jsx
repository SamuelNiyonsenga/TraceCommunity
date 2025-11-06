import React, { useEffect, useState } from "react";
import { ethers } from "ethers";
import QRCode from "qrcode.react";
import BatchRegistryABI from "./BatchRegistryABI.json"; // paste compiled ABI

const CONTRACT_ADDRESS = "REPLACE_WITH_DEPLOYED_ADDRESS";

function App() {
  const [provider, setProvider] = useState(null);
  const [contract, setContract] = useState(null);
  const [batchId, setBatchId] = useState("");
  const [batchInfo, setBatchInfo] = useState(null);
  const [checkpoints, setCheckpoints] = useState([]);

  useEffect(() => {
    if (window.ethereum) {
      const p = new ethers.providers.Web3Provider(window.ethereum);
      setProvider(p);
      const c = new ethers.Contract(CONTRACT_ADDRESS, BatchRegistryABI, p);
      setContract(c);
    } else {
      console.warn("Install MetaMask for demo");
    }
  }, []);

  async function loadBatch() {
    if (!contract || !batchId) return;
    try {
      const b = await contract.getBatch(batchId);
      const count = await contract.getCheckpointsCount(batchId);
      const cps = [];
      for (let i = 0; i < count; i++) {
        const cp = await contract.getCheckpoint(batchId, i);
        cps.push(cp);
      }
      setBatchInfo(b);
      setCheckpoints(cps);
    } catch (err) {
      console.error(err);
      alert("Error reading batch. Check console.");
    }
  }

  return (
    <div style={{ padding: 16, maxWidth: 800, margin: "0 auto", fontFamily: "Arial, sans-serif" }}>
      <h1 style={{ fontSize: 24 }}>TraceCommunity — Batch verifier</h1>
      <div style={{ marginBottom: 12 }}>
        <input style={{ padding: 8, border: "1px solid #ccc", width: 200 }} placeholder="Batch ID (number)" value={batchId} onChange={(e)=>setBatchId(e.target.value)} />
        <button style={{ marginLeft: 8, padding: "8px 12px" }} onClick={loadBatch}>Load</button>
      </div>

      {batchInfo && (
        <div style={{ border: "1px solid #eee", padding: 12, borderRadius: 8 }}>
          <h2 style={{ margin: "4px 0" }}>Batch #{batchInfo.id.toString()}</h2>
          <p><strong>Producer:</strong> {batchInfo.producer}</p>
          <p><strong>Coop:</strong> {batchInfo.cooperativeId}</p>
          <p><strong>Product:</strong> {batchInfo.productType}</p>
          <p><strong>Quantity:</strong> {batchInfo.quantity.toString()}</p>
          <p><strong>Created:</strong> {new Date(batchInfo.createdAt.toNumber()*1000).toLocaleString()}</p>
          <div style={{ marginTop: 8 }}>
            <QRCode value={window.location.href + `?batch=${batchInfo.id.toString()}`} />
          </div>
          <h3 style={{ marginTop: 12 }}>Checkpoints</h3>
          <ul>
            {checkpoints.map((cp, i) => (
              <li key={i} style={{ marginBottom: 8 }}>
                <div><strong>{cp.role}</strong> — {cp.status} — by {cp.actor}</div>
                <div>{cp.note}</div>
                <div>At: {new Date(cp.timestamp.toNumber()*1000).toLocaleString()}</div>
                {cp.ipfsHash && <div>Evidence: {cp.ipfsHash}</div>}
              </li>
            ))}
          </ul>
        </div>
      )}
    </div>
  );
}

export default App;
