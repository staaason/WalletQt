const Web3 = require('web3');
const web3 = new Web3(process.env.GATEWAY_URL);

const ethers = require('ethers');
const EthUtil = require('ethereumjs-util');
const CryptoJS = require("crypto-js");
const Accounts = require('web3-eth-accounts');
const { send } = require('eth-permit/dist/rpc');
const accounts = new Accounts(process.env.GATEWAY_URL);

const adminAddress = process.env.ADMIN_ADDRESS;

let ADMIN_NONCE = 0;
const defaultGasLimit = 90000;

const ADMIN_SIGNER = web3.eth.accounts.privateKeyToAccount(process.env.ADMIN_PRIVATEKEY);
web3.eth.accounts.wallet.add(ADMIN_SIGNER);
web3.eth.accounts.wallet.create();

const contractAbi = require('./abi.json');
const contractAddress = process.env.CONTRACT_ADDRESS;
const contract = new web3.eth.Contract(contractAbi, contractAddress);

//returns ERC20 token balance of address
async function getTokenBalance(address) {
  let balance = await contract.methods.balanceOf(address).call();
  return balance;
}

//returns ETH balance of address from blockhain net
async function getEtherBalance(address) {
  let balance = await web3.eth.getBalance(address);
  return web3.utils.fromWei(balance, 'ether');
}

//returns amount of ETH needed for buying 1 token
async function getExchangeRate() {
  let exchange_rate = web3.utils.fromWei(
    web3.utils.toBN (await contract.methods.getExchangeRate().call()),
    'ether'
    );
	return exchange_rate;
}

//sets amount of ETH needed for buying 1 token
async function setExchangeRate(rate) {
	const setExchangeRateTx = {
		"nonce": ADMIN_NONCE,
		"data": contract.methods
      .setExchangeRate(web3.utils.toWei(rate))
      .encodeABI(),
	  "gasLimit": defaultGasLimit,
	  "gasPrice": web3.utils.toHex(web3.eth.gasPrice || web3.utils.toHex(2 * 1e9)),
		"from": ADMIN_SIGNER.address,
		"to": contractAddress
   };
  sendTransaction(setExchangeRateTx);
  ADMIN_NONCE++;
}

//transferring tokens 
async function transferFrom(from, frompk, to, amount) {
  await permit(from, to, amount, frompk);
  ADMIN_NONCE++;
  await transferTokens(from, to, amount);
  ADMIN_NONCE++;
  return;
}

//function to buy tokens
async function buyTokens (userAddress, pk, tokens, ethers) {
  const exchangeRate = await getExchangeRate();
	
  if(ethers != tokens * exchangeRate) {
		throw new Error("You can't buy this amount of tokens with this amount of ethers");
	}
  
  await transferFromAdmin(
    userAddress, 
    tokens
  );
  
  ADMIN_NONCE++;
  
  await transferEther(
    userAddress, 
    adminAddress, 
    ethers, 
    pk
  );
}

//function to sell tokens
async function sellTokens (userAddress, pk, tokens, ethers) {
  const exchangeRate = await getExchangeRate();
  console.log(`SELL TOKENS ethers ${ethers}`);
  
  await permit(
    userAddress, 
    adminAddress, 
    tokens, 
    pk
  );
  
  ADMIN_NONCE++;
  
  await transferTokens(
    userAddress, 
    adminAddress, 
    tokens
  );
  
  ADMIN_NONCE++;
  
  await transferEther(
    adminAddress, 
    userAddress,
    ethers, 
    process.env.ADMIN_PRIVATEKEY
  );
  
  ADMIN_NONCE++;
}

function log(string) {
  console.log(string);
} 

//permit function from contract, changes allowance
async function permit(from, to, amount, pk) {
  const deadline = currentEpoch() + 600;
 
  const digest = await getDigest ( 
			await contract.methods.domainSeparator().call(), 
			await contract.methods.permitTypehash().call(), 
			from, 
			to, 
			amount, 
			await contract.methods.nonces(from).call(), 
			deadline
		  );
  console.log("digest ready");

	const { v, r, s } = EthUtil.ecsign (
			Buffer.from(digest.slice(2), 'hex'), 
			Buffer.from(pk, 'hex')
		  );
  console.log("vrs ready");

  const permitTx = {
      "nonce": web3.utils.toHex(ADMIN_NONCE), 
      "data": await contract.methods.permit(from, to, amount, deadline, v, r, s).encodeABI(),
			"gasLimit": web3.utils.toHex(90000),
			"gasPrice": web3.utils.toHex(web3.eth.gasPrice || web3.utils.toHex(2 * 1e9)),
      "from": ADMIN_SIGNER.address,
      "to": contractAddress
    };
  console.log(`PERMIT  ${from} ${to} ${amount}`);
  
  const txHash = await sendTransaction(permitTx);
}

// gets transaction count of a specific address
async function getNonce (address) {
  let nonce = await web3.eth.getTransactionCount(address); 
  return nonce;
}

//submits a prebuilt transaction object to the blockchain
async function sendTransaction (txObject) {
	let txHash= "";
  web3.eth.sendTransaction(txObject)
			.on('transactionHash', (hash) => {
        txHash = hash;
			})
      .on('receipt', (receipt) => {
        return txHash;
      })
			.on('error', (error) => {
				console.log(error);
			});
}

//computes the signature for permit function
async function getSignature(private_key, owner, spender, amount, nonce, deadline) {
  const digest = await getDigest ( 
			await contract.methods.getDomainSeparator().call(), 
			await contract.methods.getPermitTypehash().call(), 
			owner, 
			spender, 
			amount, 
			nonce, 
			deadline
		  );
  const { v, r, s } = EthUtil.ecsign (
			Buffer.from(digest.slice(2), 'hex'), 
			Buffer.from(private_key, 'hex')
		  );
  return {v, r, s};
}

//computes a digest for a signature
async function getDigest (domain_separator, permit_typehash, owner, spender, amount, nonce, deadline) {
	return ethers.utils.keccak256(
		ethers.utils.solidityPack(
			['bytes1', 'bytes1', 'bytes32', 'bytes32'],
			[
				'0x19',
				'0x01',
				domain_separator,
				ethers.utils.keccak256(
					ethers.utils.defaultAbiCoder.encode(
						['bytes32', 'address', 'address', 'uint256', 'uint256', 'uint256'],
						[permit_typehash, owner, spender, amount, nonce, deadline]
					)
				)
			]
		)
	);
}

//transfer tokens using transferFrom() contract method
async function transferTokens(from, to, amount){
  log('transferTokens');
  const transferFromTx = {
			"nonce": web3.utils.toHex(ADMIN_NONCE),
      "data": await contract.methods.transferFrom(from, to, amount).encodeABI(),
			"gasLimit": web3.utils.toHex(defaultGasLimit),
			"gasPrice": web3.utils.toHex(web3.eth.gasPrice || web3.utils.toHex(2 * 1e9)),
      "from": ADMIN_SIGNER.address,
      "to": contractAddress
		}
	await sendTransaction(transferFromTx);
}

//transfer tokens using transfer() contract method
async function transferFromAdmin(to, amount) {
  log("transfer from admin");
  const transferTx = {
    "nonce": web3.utils.toHex(ADMIN_NONCE),
    "data": contract.methods.transfer(to, amount).encodeABI(),
		"gasLimit": web3.utils.toHex(defaultGasLimit),
		"gasPrice": web3.utils.toHex(web3.eth.gasPrice || web3.utils.toHex(2 * 1e9)),
    "from": ADMIN_SIGNER.address,
    "to": contractAddress
  }
  await sendTransaction(transferTx);
}

//sends some ETH
async function transferEther(from, to, amount, pk) {
  log("transfer ether");
  const fromAccount = web3.eth.accounts.privateKeyToAccount(pk);
	web3.eth.accounts.wallet.add(fromAccount);
  
  nonce = (from == adminAddress) ? ADMIN_NONCE : await getNonce(from);
  const etherValue = web3.utils.toWei(amount, 'ether');
  console.log(`etherValue = ${etherValue}`);
  const ethersTx = {
		"nonce": web3.utils.toHex(nonce),
		"gasLimit": web3.utils.toHex(defaultGasLimit),
		"gasPrice": web3.utils.toHex(web3.eth.gasPrice || web3.utils.toHex(2 * 1e9)),
		"value" : web3.utils.toHex(web3.utils.toWei(amount, 'ether')),
		"from": fromAccount.address,
		"to": to 
	};
  
	await sendTransaction(ethersTx);
}

//checks if given string is a valid Ethereum address 
function isAddress(address) {
  let res = web3.utils.isAddress(address);
  return res;
}

//returns timestamp NOW
function currentEpoch() {
  return Math.floor(new Date().getTime()/1000.0);
}

async function setAdminNonce() {
  ADMIN_NONCE = await getNonce(adminAddress);
  console.log(`nonce: ${ADMIN_NONCE}`);
}


function decryptAES(ciphertext, key) {
  let iv = "JNwr7WXEQ8Nurauw";
  var ivStr  = CryptoJS.enc.Utf8.parse(iv);
  var keyStr = CryptoJS.enc.Utf8.parse(key);

  var bytes = CryptoJS.AES.decrypt(
    ciphertext, 
    keyStr, 
    {
      iv: ivStr,
      mode: CryptoJS.mode.CBC,
      padding: CryptoJS.pad.Pkcs7
    }
    );
  var plaintext = bytes.toString(CryptoJS.enc.Utf8);
  return plaintext.toString();
}

exports.decrypt = decryptAES;
exports.tokenBalance = getTokenBalance;
exports.etherBalance = getEtherBalance;
exports.exchangeRate = getExchangeRate;
exports.setExchangeRate = setExchangeRate;
exports.transferFrom = transferFrom;
exports.buyTokens = buyTokens;
exports.sellTokens = sellTokens;
exports.isAddress = isAddress;
exports.setAdminNonce = setAdminNonce;
exports.contract = contract;