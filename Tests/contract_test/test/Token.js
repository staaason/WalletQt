const { expect } = require("chai")
const { ethers } = require("hardhat")
const Web3 = require("web3");
const web3 = new Web3("http://127.0.0.1:8545/");
const EthUtil = require('ethereumjs-util');
const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const {AddressZero} = require("@ethersproject/constants");


const name = 'Test token';
const symbol = 'TST';
const decimals = 18;
const totalSupply = 10000;

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


function currentEpoch() {
  return Math.floor(new Date().getTime()/1000.0);
}

describe('Token', async function(){
  async function deployTokenFixture() {
    const Token = await ethers.getContractFactory("Token");
    const [owner, addr1, addr2] = await ethers.getSigners();

    const token = await Token.deploy(name, symbol, decimals, owner.address, totalSupply);
    await token.deployed();
    return { Token, token, owner, addr1, addr2 };
  }
  describe('Deployment', async function(){
    it("Should assign the total supply of tokens to the owner", async function () {
      const {token, owner } = await loadFixture(deployTokenFixture);
      const ownerBalance = await token.balanceOf(owner.address);
      expect(await token.totalSupply()).to.equal(ownerBalance);
    });

    it("Should assign the name of token", async function(){
      const {token, owner } = await loadFixture(deployTokenFixture);
      expect(await token.name()).to.equal(name);
    })

    it("Should assign the symbol of token", async function(){
      const {token, owner } = await loadFixture(deployTokenFixture);
      expect(await token.symbol()).to.equal(symbol);
    })

  })
  describe('Transactions', async function(){
    it("Should set random ETH - Token exchange rate", async function(){
      const {token, owner } = await loadFixture(deployTokenFixture);
      const rate =  web3.utils.toWei(Math.random().toString(), "ether");
      await token.setExchangeRate(rate);
      expect(await token.getExchangeRate()).to.equal(rate);
    })

    it("Should buy 5 tokens to user account", async function(){
      const {token, owner, addr1 } = await loadFixture(deployTokenFixture);
      const rate =  web3.utils.toWei(Math.random().toString(), "ether");
      const amount = 5;
      await token.setExchangeRate(rate);
      expect(await token.buyTokens(addr1.address, amount, {value : ((await token.getExchangeRate()).mul(amount)).toString()})).to.changeTokenBalances(token, [owner, addr1], [-amount, amount]);
    })

    it("Should give permit and sell 5 tokens from user account", async function(){
      const {token, owner, addr1 } = await loadFixture(deployTokenFixture);
      const rate =  web3.utils.toWei(Math.random().toString(), "ether");
      const privateKey = '59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d';
      const deadline = currentEpoch() + 600;
      const amount = 5;
      await token.setExchangeRate(rate);
      await token.buyTokens(addr1.address, amount, {value : ((await token.getExchangeRate()).mul(amount)).toString()});
      const digest = await getDigest ( 
        await token.domainSeparator(), 
        await token.permitTypehash(), 
        addr1.address, 
        owner.address, 
        amount, 
        await token.nonces(addr1.address), 
        deadline
          );
      const { v, r, s } = EthUtil.ecsign (
        Buffer.from(digest.slice(2), 'hex'), 
        Buffer.from(privateKey, 'hex')
          );
      await token.permit(addr1.address, owner.address, amount, deadline, v, r, s); 
      expect(await token.sellTokens(addr1.address, amount)).to.changeTokenBalances(token, [owner, addr1], [-amount, amount]);
    })

    it("Should give permit and transfer tokens between accounts", async function () {
      const { token, owner, addr1, addr2 } = await loadFixture(
        deployTokenFixture
      );
      const amount = 5;
      const privateKey = '59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d';
      const deadline = currentEpoch() + 600;
      const rate =  web3.utils.toWei(Math.random().toString(), "ether");
      await token.setExchangeRate(rate);
      await token.buyTokens(addr1.address, amount, {value : ((await token.getExchangeRate()).mul(amount)).toString()});
      const digest = await getDigest ( 
        await token.domainSeparator(), 
        await token.permitTypehash(), 
        addr1.address, 
        addr2.address, 
        amount, 
        await token.nonces(addr1.address), 
        deadline);
      const { v, r, s } = EthUtil.ecsign (
      Buffer.from(digest.slice(2), 'hex'), 
      Buffer.from(privateKey, 'hex'));
      await token.permit(addr1.address, addr2.address, amount, deadline, v, r, s);
      expect(await token.transferFrom(addr1.address, addr2.address, amount)).to.changeTokenBalances(token, [addr1, addr2], [-amount, amount]);
    });

    it("Should fail if sender isn't admin", async function () {
      const { token, owner, addr1 } = await loadFixture(
        deployTokenFixture
      );
      const initialOwnerBalance = await token.balanceOf(owner.address);
      await expect(token.connect(addr1).transfer(owner.address, 1)
      ).to.be.revertedWith("action is restricted");
      await expect(token.connect(addr1).approve(owner.address, 1)
      ).to.be.revertedWith("action is restricted");
      expect(await token.balanceOf(owner.address)).to.equal(
        initialOwnerBalance
      );
    });

    it("Should fail if user doesn't have enough tokens", async function () {
      const { token, owner, addr1, addr2 } = await loadFixture(
        deployTokenFixture
      );
      const initialOwnerBalance = await token.balanceOf(addr2.address);
      const privateKey = '59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d';
      // Try to send 1 token from addr1 (0 tokens) to addr2 (0 tokens).

      const deadline = currentEpoch() + 600;
      const amount = 1;
      const digest = await getDigest ( 
        await token.domainSeparator(), 
        await token.permitTypehash(), 
        addr1.address, 
        addr2.address, 
        amount, 
        await token.nonces(addr1.address), 
        deadline);
  
      const { v, r, s } = EthUtil.ecsign (
        Buffer.from(digest.slice(2), 'hex'), 
        Buffer.from(privateKey, 'hex'));
      await expect(token.permit(addr1.address, addr2.address, amount, deadline, v, r, s)).to.be.revertedWith('amount exceeds balance');
      await expect(token.transferFrom(addr1.address, addr2.address, amount)).to.be.revertedWith("insufficient allowance");
      // Owner balance shouldn't have changed.
      expect(await token.balanceOf(addr2.address)).to.equal(
        initialOwnerBalance
      );
    });
    it("Should fail if user permitting not enough tokens for transfer", async function () {
      const { token, owner, addr1, addr2 } = await loadFixture(
        deployTokenFixture
      );
      const initialOwnerBalance = await token.balanceOf(addr2.address);
      const privateKey = '59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d';
      const deadline = currentEpoch() + 600;
      const amount = 10;
      const rate =  web3.utils.toWei(Math.random().toString(), "ether");
      await token.setExchangeRate(rate);
      await token.buyTokens(addr1.address, amount, {value : ((await token.getExchangeRate()).mul(amount)).toString()});
      const digest = await getDigest ( 
        await token.domainSeparator(), 
        await token.permitTypehash(), 
        addr1.address, 
        addr2.address, 
        5, 
        await token.nonces(addr1.address), 
        deadline);
  
      const { v, r, s } = EthUtil.ecsign (
        Buffer.from(digest.slice(2), 'hex'), 
        Buffer.from(privateKey, 'hex'));
      await token.permit(addr1.address, addr2.address, 5, deadline, v, r, s);
      await expect(token.transferFrom(addr1.address, addr2.address, amount)).to.be.revertedWith("insufficient allowance");
      // Owner balance shouldn't have changed.
      expect(await token.balanceOf(addr2.address)).to.equal(
        initialOwnerBalance
      );
    });
    describe('Testing permit', async function(){
      it('Should behave like permit', async function(){
        const { token, owner, addr1, addr2 } = await loadFixture(
          deployTokenFixture
        );
        const amount = 5;
        const deadline = currentEpoch() + 600;
        const privateKey = '59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d';
        const rate =  web3.utils.toWei(Math.random().toString(), "ether");
        await token.setExchangeRate(rate);
        await token.buyTokens(addr1.address, amount, {value : ((await token.getExchangeRate()).mul(amount)).toString()});
        const digest = await getDigest ( 
          await token.domainSeparator(), 
          await token.permitTypehash(), 
          addr1.address, 
          addr2.address, 
          amount, 
          await token.nonces(addr1.address), 
          deadline);
        const { v, r, s } = EthUtil.ecsign (
        Buffer.from(digest.slice(2), 'hex'), 
        Buffer.from(privateKey, 'hex'));
       token.permit(addr1.address, addr2.address, amount, deadline, v, r, s);
       expect(await token.allowance(addr1.address, addr2.address)).to.equal(await token.balanceOf(addr1.address));

      })
      it('Should fail when signature is invalid', async function(){
        const { token, owner, addr1, addr2 } = await loadFixture(
          deployTokenFixture
        );
        const privateKey = '0000000000000000000000000000000000000000000000000000000000000001';
        const deadline = currentEpoch() + 600;
        const digest = await getDigest ( 
          await token.domainSeparator(), 
          await token.permitTypehash(), 
          AddressZero, 
          addr2.address, 
          0, 
          await token.nonces(AddressZero), 
          deadline);
    
        const { v, r, s } = EthUtil.ecsign (
          Buffer.from(digest.slice(2), 'hex'), 
          Buffer.from(privateKey, 'hex'));
        await expect(token.permit(AddressZero, addr2.address, 0, deadline, v, r, s)).to.be.revertedWith("invalid signature");
      })

      it('Should fail when the spender is the zero address', async function(){
        const { token, owner, addr1, addr2 } = await loadFixture(
          deployTokenFixture
        );

        const privateKey = '59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d';
        const deadline = currentEpoch() + 600;
        const digest = await getDigest ( 
          await token.domainSeparator(), 
          await token.permitTypehash(), 
          addr1.address, 
          AddressZero, 
          0, 
          await token.nonces(addr1.address), 
          deadline);
    
        const { v, r, s } = EthUtil.ecsign (
          Buffer.from(digest.slice(2), 'hex'), 
          Buffer.from(privateKey, 'hex'));

        await expect(token.permit(addr1.address, AddressZero, 0, deadline, v, r, s)).to.be.revertedWith("spender is zero adress");
      })

      it('Should fail when the deadline is in the past', async function(){
        const deadline = BigInt("946656000");
        const { token, owner, addr1, addr2 } = await loadFixture(
          deployTokenFixture
        );
        const amount = 5;
        const privateKey = '59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d';
        const rate =  web3.utils.toWei(Math.random().toString(), "ether");
        await token.setExchangeRate(rate);
        await token.buyTokens(addr1.address, amount, {value : ((await token.getExchangeRate()).mul(amount)).toString()});
        const digest = await getDigest ( 
          await token.domainSeparator(), 
          await token.permitTypehash(), 
          addr1.address, 
          addr2.address, 
          amount, 
          await token.nonces(addr1.address), 
          deadline);
        const { v, r, s } = EthUtil.ecsign (
        Buffer.from(digest.slice(2), 'hex'), 
        Buffer.from(privateKey, 'hex'));
        await expect(token.permit(addr1.address, addr2.address, amount, deadline, v, r, s)).to.be.revertedWith("expired deadline");
      })

      it("increases the nonce of the user", async function () {
        const deadline = currentEpoch() + 600;
        const { token, owner, addr1, addr2 } = await loadFixture(
          deployTokenFixture
        );
        const amount = 5;
        const privateKey = '59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d';
        const rate =  web3.utils.toWei(Math.random().toString(), "ether");
        await token.setExchangeRate(rate);
        await token.buyTokens(addr1.address, amount, {value : ((await token.getExchangeRate()).mul(amount)).toString()});
        const digest = await getDigest ( 
          await token.domainSeparator(), 
          await token.permitTypehash(), 
          addr1.address, 
          addr2.address, 
          amount, 
          await token.nonces(addr1.address), 
          deadline);
        const { v, r, s } = EthUtil.ecsign (
        Buffer.from(digest.slice(2), 'hex'), 
        Buffer.from(privateKey, 'hex'));
        const oldNonce = await token.nonces(addr1.address);
        await token.permit(addr1.address, addr2.address, amount, deadline, v, r, s);
        const newNonce = await token.nonces(addr1.address);;
        expect(oldNonce).to.equal(newNonce.sub(1));
      });
    })
  })
})
