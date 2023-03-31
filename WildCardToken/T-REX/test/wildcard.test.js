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

contract('Wildcard', (accounts) => {
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



    //user 1 should approve to wild card contract
    it('user 1 set the allownace to wildcard contract', async () => {
        await token.approve('0x0000000000000000000000000000000000000000', 500, {
            from: user1
        }).should.be.rejectedWith(EVMRevert);
        const tx = await token.approve(wildcard.address, 500, {
            from: user1
        }).should.be.fulfilled;
        log(`[${calculateETH(gasAverage, tx.receipt.gasUsed)} ETH] --> fees of approve transaction`);
        const allowance = await token.allowance(user1, wildcard.address).should.be.fulfilled;
        allowance.toString().should.equal('500');
    });

    //wildcard tokens mint to user 2


    //wildcard contract should transfer from user 1 to user 2
    it('Successfuly transfers Token if user 1 is approved, to user 2 via wildcard claim', async () => {
        // should revert if zero address
        await token.approve('0x0000000000000000000000000000000000000000', 300, {
            from: user1
        }).should.be.rejectedWith(EVMRevert);

        //user 1 approves tokens to wildcard contract
        await token.approve(wildcard.address, 300, {
            from: user1
        }).should.be.fulfilled;


        //wildcard claim
        const tx = await wildcard.claimPropertyTokens(300, {
            from: user2
        }).should.be.fulfilled;
        log(`[${calculateETH(gasAverage, tx.receipt.gasUsed)} ETH] --> fees of transferFrom transaction`);
        const balance1 = await token.balanceOf(user1);
        const balance2 = await token.balanceOf(user2);
        balance1.toString().should.equal('700');
        balance2.toString().should.equal('300');
    });

    //burn the same amount of tokens
    //check the balances of the wildcard tokens



});