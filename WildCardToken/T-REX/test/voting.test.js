const fetch = require('node-fetch');
const log = require('./helpers/logger');
require('chai').use(require('chai-as-promised')).should();
const EVMRevert = require('./helpers/VMExceptionRevert');
const {
    calculateETH
} = require('./helpers/gasAverage');
const {
    deployIdentityProxy
} = require('./helpers/proxy');
const {
    ClaimTopicsRegistry,
    IdentityRegistry,
    TrustedIssuersRegistry,
    IssuerIdentity,
    Token,
    Compliance,
    IdentityRegistryStorage,
    Proxy,
    Implementation,

    //import wild card
    Wildcard
} = require('./helpers/artifacts');

contract('Token(Voting Power)', (accounts) => {
    let claimTopicsRegistry;
    let identityRegistry;
    let identityRegistryStorage;
    let trustedIssuersRegistry;
    let claimIssuerContract;
    let token;
    let defaultCompliance;
    let tokenName;
    let tokenSymbol;
    let tokenDecimals;
    let tokenOnchainID;

    //inital supply declaration
    let initialSupply = 10000;

    //declare wildcard
    let wildcard;
    let gasAverage;
    const signer = web3.eth.accounts.create();
    const signerKey = web3.utils.keccak256(web3.eth.abi.encodeParameter('address', signer.address));
    const tokeny = accounts[0];
    const claimIssuer = accounts[1];
    const user1 = accounts[2];
    const user2 = accounts[3];
    const claimTopics = [1, 7, 3];
    let user1Contract;
    let user2Contract;
    const agent = accounts[8];

    beforeEach(async () => {
        gasAverage = await fetch('https://ethgasstation.info/json/ethgasAPI.json')
            .then((resp) => resp.json())
            .then((data) => data.average);
        claimTopicsRegistry = await ClaimTopicsRegistry.new({
            from: tokeny
        });
        trustedIssuersRegistry = await TrustedIssuersRegistry.new({
            from: tokeny
        });
        defaultCompliance = await Compliance.new({
            from: tokeny
        });
        identityRegistryStorage = await IdentityRegistryStorage.new({
            from: tokeny
        });
        identityRegistry = await IdentityRegistry.new(trustedIssuersRegistry.address, claimTopicsRegistry.address, identityRegistryStorage.address, {
            from: tokeny,
        });

        tokenOnchainID = await deployIdentityProxy(tokeny);
        tokenName = 'TREXDINO';
        tokenSymbol = 'TREX';
        tokenDecimals = '0';


        token = await Token.new();

        implementation = await Implementation.new(token.address);

        proxy = await Proxy.new(
            implementation.address,
            identityRegistry.address,
            defaultCompliance.address,
            tokenName,
            tokenSymbol,
            tokenDecimals,
            tokenOnchainID.address,
        );
        token = await Token.at(proxy.address);


        //deploy wildcard
        wildcard = await Wildcard.new(initialSupply, user1, token.address, {
            from: user2
        });

        await identityRegistryStorage.bindIdentityRegistry(identityRegistry.address, {
            from: tokeny
        });

        await token.addAgentOnTokenContract(agent, {
            from: tokeny
        });
        // Tokeny adds trusted claim Topic to claim topics registry
        await claimTopicsRegistry.addClaimTopic(7, {
            from: tokeny
        }).should.be.fulfilled;

        // Claim issuer deploying identity contract
        claimIssuerContract = await IssuerIdentity.new(claimIssuer, {
            from: claimIssuer
        });

        // Claim issuer adds claim signer key to his contract
        await claimIssuerContract.addKey(signerKey, 3, 1, {
            from: claimIssuer
        }).should.be.fulfilled;

        // Tokeny adds trusted claim Issuer to claimIssuer registry
        await trustedIssuersRegistry.addTrustedIssuer(claimIssuerContract.address, claimTopics, {
            from: tokeny
        }).should.be.fulfilled;

        // user1 deploys his identity contract
        user1Contract = await deployIdentityProxy(user1);

        // user2 deploys his identity contract
        user2Contract = await deployIdentityProxy(user2);

        // identity contracts are registered in identity registry
        await identityRegistry.addAgentOnIdentityRegistryContract(agent, {
            from: tokeny
        });
        await identityRegistry.registerIdentity(user1, user1Contract.address, 91, {
            from: agent,
        }).should.be.fulfilled;
        await identityRegistry.registerIdentity(user2, user2Contract.address, 101, {
            from: agent,
        }).should.be.fulfilled;

        // user1 gets signature from claim issuer
        const hexedData1 = await web3.utils.asciiToHex('Yea no, this guy is totes legit');
        const hashedDataToSign1 = web3.utils.keccak256(
            web3.eth.abi.encodeParameters(['address', 'uint256', 'bytes'], [user1Contract.address, 7, hexedData1]),
        );

        const signature1 = (await signer.sign(hashedDataToSign1)).signature;

        // user1 adds claim to identity contract
        await user1Contract.addClaim(7, 1, claimIssuerContract.address, signature1, hexedData1, '', {
            from: user1
        });

        // user2 gets signature from claim issuer
        const hexedData2 = await web3.utils.asciiToHex('Yea no, this guy is totes legit');
        const hashedDataToSign2 = web3.utils.keccak256(
            web3.eth.abi.encodeParameters(['address', 'uint256', 'bytes'], [user2Contract.address, 7, hexedData2]),
        );

        const signature2 = (await signer.sign(hashedDataToSign2)).signature;

        // user2 adds claim to identity contract
        await user2Contract.addClaim(7, 1, claimIssuerContract.address, signature2, hexedData2, '', {
            from: user2
        }).should.be.fulfilled;

        //minted to user 1
        await token.mint(user1, 1000, {
            from: agent
        });
    });


    //tests

    //user 1 should have voting power of 1000 after mint
    it('user 1 should have voting power of 1000 after mint', async () => {

        //self delegation of user 1 
        const tx = await token.delegate(user1, {
            from: user1
        }).should.be.fulfilled;
        log(`[${calculateETH(gasAverage, tx.receipt.gasUsed)} ETH] --> fees of approve transaction`);

        const votePower = await token.getVotes(user1, {
            from: user1
        }).should.be.fulfilled;
        //log(`[${calculateETH(gasAverage, tx.receipt.gasUsed)} ETH] --> fees of approve transaction`);
        votePower.toString().should.equal('1000');
    });

    // voting power will tranfer from user1 to user2 after tranfer of tokens
    it('tranfer of voting power if token tranfer takes place', async () => {

        //self delegation of user 1 
        const tx1 = await token.delegate(user1, {
            from: user1
        }).should.be.fulfilled;
        log(`[${calculateETH(gasAverage, tx1.receipt.gasUsed)} ETH] --> fees of approve transaction`);

        //self delegation of user 2
        const tx2 = await token.delegate(user2, {
            from: user2
        }).should.be.fulfilled;
        log(`[${calculateETH(gasAverage, tx2.receipt.gasUsed)} ETH] --> fees of approve transaction`);

        //voting power before token transfer
        const bvp1 = await token.getVotes(user1, {
            from: user1
        }).should.be.fulfilled;
        bvp1.toString().should.equal('1000');

        const bvp2 = await token.getVotes(user2, {
            from: user2
        }).should.be.fulfilled;
        bvp2.toString().should.equal('0');

        //transfer of token
        const tx3 = await token.transfer(user2, 300, {
            from: user1
        }).should.be.fulfilled;
        log(`[${calculateETH(gasAverage, tx3.receipt.gasUsed)} ETH] --> fees of approve transaction`);


        // voting power after token transfer
        const avp1 = await token.getVotes(user1, {
            from: user1
        }).should.be.fulfilled;
        avp1.toString().should.equal('700');

        const avp2 = await token.getVotes(user2, {
            from: user2
        }).should.be.fulfilled;
        avp2.toString().should.equal('300');

    });


});