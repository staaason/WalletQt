const express = require('express');
const app = express();
const port = 5000;

const { MongoClient } = require("mongodb");
const client = new MongoClient(process.env['MONGO']);

const bodyParser = require("body-parser");
app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());
const CryptoJS = require("crypto-js");
const contract = require('./app.js').contract;


app.get('/', async (req, res) => {
  res.send("APRIWALLET SERVER");
});

app.post('/get-tx-data', async (req, res) => {
  const userAddress = req.body.address;
  let cursor; 
  if(userAddress == process.env.ADMIN_ADDRESS)
   cursor = await transactions.find();
  else
  {
    cursor = await transactions.find({
    $or: [{ from: userAddress },
    { to: userAddress }]
  });
  }
  let document;
  let txList = [];
  do {
    document = await cursor.hasNext() ? await cursor.next() : null;
    if (document != null) {
      txList.unshift(document);

    }
  } while (document != null);
  res.send({ txList });
});

app.post('/get-user-data', async (req, res) => {
  const userAddress = req.body.address;
  const user = await users.find({ user: userAddress }).toArray();
  const isChanged = user[0].isChanged;
  res.send({isChanged});
});

app.post('/update-user-database', async (req, res) => {
  await users.updateOne({user: req.body.userAddress},{$set:{isChanged:false}});
});

const getTokenBalance = require('./app.js').tokenBalance;
app.post('/get-token-balance', async (req, res) => {
  console.log("get token balance");
  const balance = await getTokenBalance(req.body.address);
  res.send({ "balance": parseInt(balance) });
});

const getEtherBalance = require('./app.js').etherBalance;
app.post('/get-ether-balance', async (req, res) => {
  console.log("get ether balance");
  const balance = await getEtherBalance(req.body.address);
  res.send({ "eth_balance": balance });
});

const getExchangeRate = require('./app.js').exchangeRate;
app.get('/get-exchange-rate', async (req, res) => {
  const exchangeRate = await getExchangeRate();
  res.send({ "exchange_rate": exchangeRate });
});

const transferFrom = require('./app.js').transferFrom;
app.post('/transfer-from', async (req, res) => {
  try {
    const canDoTx = await lastTransactionIsTenMinutesAgo(req.body.from);
    if(!canDoTx)
     throw 'You must wait!';
    
    const decryptedPrivateKey = decrypt(req.body.privateKey, process.env.key_);
    const txHash = await transferFrom(
      req.body.from,
      decryptedPrivateKey,
      req.body.to,
      req.body.value
    );
    await transactions.insertOne({
      date: new Date().toLocaleString(),
      from: req.body.from,
      to: req.body.to,
      ether_value: "0",
      token_value: req.body.value
    });
    await updateTimestamp(req.body.from);
  } catch (err) {
    console.log(`TRANSFER FROM ERROR: ${err}`);
    res.send(`TRANSFER FROM ERROR: ${err}`);
  }
  users.updateOne({user: req.body.from},{$set:{isChanged:true}})
  users.updateOne({user: req.body.to},{$set:{isChanged:true}})
});

const setExchangeRate = require('./app.js').setExchangeRate;
app.post('/set-exchange-rate', async (req, res) => {
  try {
    setExchangeRate(req.body.exchangeRate);
    users.updateMany({},{$set:{isChanged:true}});
  } catch (err) {
    console.log(`SET EXCHANGE RATE ERROR: ${err}`);
    res.send(`SET EXCHANGE RATE ERROR: ${err}`);
  }
});

const buyTokens = require('./app.js').buyTokens;
app.post('/buy-tokens', async (req, res) => {
  try {
    const canDoTx = await lastTransactionIsTenMinutesAgo(req.body.buyer);
    if(!canDoTx)
      throw 'You must wait!';
    
    const decryptedPrivateKey = decrypt(req.body.privateKey, process.env.key_);
    buyTokens(
      req.body.buyer,
      decryptedPrivateKey,
      req.body.tokensToBuy,
      req.body.ethersToPay
    );
    await transactions.insertOne({
      date: new Date().toLocaleString(),
      from: process.env.CONTRACT_ADDRESS,
      to: req.body.buyer,
      ether_value: "-" + req.body.ethersToPay,
      token_value: "+" + req.body.tokensToBuy
    });
    await updateTimestamp(req.body.buyer);
  } catch (err) {
    console.log(`BUY TOKENS ERROR: ${err}`);
    res.send(`BUY TOKENS ERROR: ${err}`);
  }
  users.updateOne({user: req.body.buyer},{$set:{isChanged:true}})
});

const sellTokens = require('./app.js').sellTokens;
app.post('/sell-tokens', async (req, res) => {
  try {
    const canDoTx = await lastTransactionIsTenMinutesAgo(req.body.seller);
    if(!canDoTx)
     throw 'You must wait!';
    
    const decryptedPrivateKey = decrypt(req.body.sellerPrivateKey, process.env.key_);
    await sellTokens(
      req.body.seller,
      decryptedPrivateKey,
      req.body.tokensToSell,
      req.body.ethersToGet
    );
    await transactions.insertOne({
      date: new Date().toLocaleString(),
      from: req.body.seller,
      to: process.env.CONTRACT_ADDRESS,
      ether_value: "+" + req.body.ethersToGet,
      token_value: "-" + req.body.tokensToSell
    });
    await updateTimestamp(req.body.seller);
    
  } catch (err) {
    console.log(`SELL TOKENS ERROR: ${err}`);
    res.send(`SELL TOKENS ERROR: ${err}`);
  }
  users.updateOne({user:req.body.seller},{$set:{isChanged:true}})
});

const decrypt = require('./app.js').decrypt;
const isAddress = require('./app.js').isAddress;
app.post('/is-address', async (req, res) => {
  const isValid = isAddress(req.body.address);
  const count = await users.find({ user: req.body.address }).count();
  if (isValid && count == 0) {
    users.insertOne({  
      user: req.body.address,
      isChanged: false
    });
  }
  res.send({ isAddress: isValid });
});

const setAdminNonce = require('./app.js').setAdminNonce;
app.listen(port, async () => {
  setAdminNonce();
  console.log(`Now listening on port ${port}`);
  await client.connect();
  db = client.db('EasyPay');
  transactions = db.collection('transactions');
  users = db.collection('users');
});

function currentEpoch() {
  return Math.floor(new Date().getTime()/1000.0);
}

async function lastTransactionIsTenMinutesAgo(user) {
  //шукаємо запис з користувачем
  const cursor = await users.find ({ user: user }).toArray();
  const isTenMinutesAgo = cursor[0].lastTransaction < (currentEpoch() - 600); 
  return isTenMinutesAgo;
}

async function updateTimestamp(user) {
  await users.updateOne({user: user},{$set:{lastTransaction: currentEpoch()}});
}