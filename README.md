# Smart contracts of dGE token ("digitaler Gutschein-Euro")

## A blockchain-based voucher system to help citizens to help their local SME

based on the [#WirVsVirusHack](https://wirvsvirushackathon.org/) athon submission. Further developed durig the [#EUvsVirus](https://euvsvirus.org/).

dGE stands for "digitaler Gutschein-Euro" which is german for "digital voucher euro".<br />
Visit our webpage: https://diggi.jetzt

### Smart Contract part of dgE project
This is the blockchain-based backbone of the dGE project.

### Prerequisites
This project is built with npm and truffle.
```bash
Node v14.1.0
npm 6.14.4
Truffle v5.1.23 (core: 5.1.23)
```
You can check your current versions with
`node -v`
`npm -v`
and `truffle version`.

### Getting started
Go to where you code on your local machine in an empty folder...

 `$ git clone`

 `$ cd dGE-smartContracts`

 `$ npm install`

And you're good to go!

### Deployment
You can use the truffle commands to compile, migrate or deploy the smart contracts.

 `truffle compile`

 `truffle migrate`

  `truffle deploy --network` followed by the specification of your chosen testnetwork.

If you're building on your local testnet and have already migrated once, don't forget that for the next migration the command will be `truffle migrate --reset` to clean up all your previous migrations :)

### Built With
This project was mainly built with love. But we also used JavaScript, Solidity and Truffle ;)

### Contributing
If you want to contribute, feel free to raise new issues! We're here to help and to improve <3

### Authors
![Fredo](https://avatars2.githubusercontent.com/u/10088275?s=60&v=4) [Fredo](https://github.com/fredo)
<br />
![Lilith1410](https://avatars2.githubusercontent.com/u/32402989?s=60&v=4) [Lilith1410](https://github.com/lilith1410)

### Contributors
![Niels](https://avatars2.githubusercontent.com/u/3898916?s=60&v=4) [Niels](https://github.com/Dakavon)<br />

### Acknowledgements
Shoutout to all the wonderful people contributing to the WirVsVirus Hackathon! Thank you for the amazing effort the organizers put into making this impossibly spontaneous and overwhelming event happen!