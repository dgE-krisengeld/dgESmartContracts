const fs = require("fs");
const EthCrypto = require("eth-crypto");
var citizenIdentity = { };
var message, signature;
var vouchersData = { };

//Variables that can be changed as required
const voucherQuantity = 2;
const dGEcontractAddress = '0x0';

//Take input arguments
const args = require('minimist')(process.argv.slice(2));
citizenIdentity.privateKey = args['privateKey'];
//citizenIdentity.privateKey = '0x0';
//console.log(typeof citizenIdentity.privateKey);

//Restore publicKey from privateKey
citizenIdentity.publicKey = EthCrypto.publicKeyByPrivateKey(citizenIdentity.privateKey);
//console.log(citizenIdentity.publicKey);

//Restore address from publicKey
citizenIdentity.address = EthCrypto.publicKey.toAddress(citizenIdentity.publicKey);
//console.log(citizenIdentity.address);

//Log
console.log(`citizen address: ${citizenIdentity.address}`);
console.log(`citizen public key: ${citizenIdentity.publicKey}`);
console.log(`citizen private key: ${citizenIdentity.privateKey}\n`);

//Fill object
vouchersData.address = citizenIdentity.address;
vouchersData.publicKey = citizenIdentity.publicKey;
vouchersData.privateKey = citizenIdentity.privateKey;
vouchersData.vouchers = { };


//Loop to create vouchers
for (let i = 1; i <= voucherQuantity; i++){
  message = EthCrypto.hash.keccak256([
      { type: "address", value: citizenIdentity.address},
      { type: "uint16", value: i},
      { type: "address", value: dGEcontractAddress}
    ]);
  signature = EthCrypto.sign(citizenIdentity.privateKey, message);

  //Log iteration
  console.log(`Voucher no.: ${i}`);
  console.log(`message: ${message}`);
  console.log(`signature: ${signature}\n`);

  //Extend object with message and signature
  vouchersData.vouchers[i] = { };
  vouchersData.vouchers[i].message = message;
  vouchersData.vouchers[i].signature = signature;
}


//Finished object
console.log(vouchersData);

//Write to file in JSON format
fs.writeFile(citizenIdentity.address+"-vouchers.json", JSON.stringify(vouchersData, null, 4), 'utf8', function(err){
  if (err) {
    console.log("An error occured while writing JSON Object to File.");
    return console.log(err);
  }

  console.log("JSON file has been saved.");
});