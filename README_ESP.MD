# dApp de Libro de Visitas en Core

Las aplicaciones descentralizadas (dApps) utilizan una blockchain o contratos inteligentes en cadena para almacenar y referenciar datos, en lugar de depender de bases de datos centralizadas tradicionales. Una estructura común y simple de una dApp generalmente consiste en un front-end en React.js o Vue.js que utiliza Web3.js o Ethers.js para interactuar con contratos inteligentes desplegados en una blockchain compatible con EVM.

## ¿Qué puedes hacer en este tutorial?

En este tutorial, aprenderás a crear una dApp para un libro de visitas en donde los usuarios podrán agregar mensajes en la red CORE.

## Requisitos de Software

* [Git](https://git-scm.com/) v2.44.0
* [Node.js](https://nodejs.org/en) v20.11.1
* [npm](https://docs.npmjs.com/downloading-and-installing-node-js-and-npm) v10.2.4
* [Hardhat](https://hardhat.org/hardhat-runner/docs/getting-started#installation) v10.2.4
* [MetaMask Web Wallet Extension](https://metamask.io/download/)

## Configuración del entorno de desarrollo

1. Descarga este repositorio

2. Instala las dependencias en la ruta /contract.
   
```bash
npm install
```

3. Instala y configura la Extensión MetaMask para Chrome para usar con Core Testnet. Consulta [aquí](https://docs.coredao.org/docs/Dev-Guide/core-testnet-wallet-config) para una guía detallada.

4. Crea un archivo secret.json en la carpeta /contract y almacena la clave privada de tu billetera MetaMask en él. Consulta [aquí](https://metamask.zendesk.com/hc/en-us/articles/360015290032-How-to-reveal-your-Secret-Recovery-Phrase) para detalles sobre cómo obtener la clave privada de la cuenta MetaMask. Ejemplo:

```json
{"PrivateKey":"ef1150b212a53b053a3dee265cb26cd010065b9340b4ac6cf5d895a7cf39c923"}
```

:::Advertencia: 
No olvides añadir este archivo al archivo .gitignore en la carpeta raíz de tu proyecto para evitar que tu clave privada/frases secretas se suban accidentalmente a un repositorio público. ¡Asegúrate de mantener este archivo en un lugar absolutamente seguro!
:::

5. Copia lo siguiente en tu archivo hardhat.config.js en /contract

```js
/**
 * @type import('hardhat/config').HardhatUserConfig
 */


require('@nomiclabs/hardhat-ethers');
require("@nomiclabs/hardhat-waffle");


const { PrivateKey } = require('./secret.json');


module.exports = {
   defaultNetwork: 'testnet',


   networks: {
      hardhat: {
      },
      testnet: {
         url: 'https://rpc.test.btcs.network',
         accounts: [PrivateKey],
         chainId: 1115,
      }
   },
   solidity: {
      compilers: [
        {
           version: '0.8.24',
           settings: {
            evmVersion: 'paris',
            optimizer: {
                 enabled: true,
                 runs: 200,
              },
           },
        },
      ],
   },
   paths: {
      sources: './contracts',
      cache: './cache',
      artifacts: './artifacts',
   },
   mocha: {
      timeout: 20000,
   },
};
```

## Escritura del Contrato Inteligente

1. Dentro de la carpeta /contract/contracts se encuentra el archivo `Guestbook.sol` que contendrá el código del contrato inteligente a utilizar en este tutorial.

```javascript
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Guestbook {
    struct Entry {
        address user;
        string message;
        uint timestamp;
    }

    Entry[] public entries;

    event EntryAdded(address indexed user, string message, uint timestamp);

    function addEntry(string calldata _message) external {
        entries.push(Entry({
            user: msg.sender,
            message: _message,
            timestamp: block.timestamp
        }));
        emit EntryAdded(msg.sender, _message, block.timestamp);
    }

    function getEntries(uint _startIndex, uint _limit) external view returns (Entry[] memory) {
        require(_startIndex < entries.length, "Start index out of bounds");

        uint endIndex = _startIndex + _limit > entries.length ? entries.length : _startIndex + _limit;
        uint numEntries = endIndex - _startIndex;
        Entry[] memory paginatedEntries = new Entry[](numEntries);

        for (uint i = 0; i < numEntries; i++) {
            paginatedEntries[i] = entries[_startIndex + i];
        }

        return paginatedEntries;
    }
}
```

## Compilación del Contrato Inteligente

1. Para compilar el contrato inteligente `Guestbook` definido en `Guestbook.sol`, desde el directorio /contract ejecuta el siguiente comando. (Cada vez que se realice un cambio en el código del contrato, debemos recompilarlo).

```bash
npx hardhat compile
```

## Despliegue e Interacción con el Contrato Inteligente

1. Antes de desplegar tu contrato inteligente en la cadena Core, es aconsejable ejecutar una serie de pruebas para asegurarse de que el contrato funciona como se desea. Consulta la guía detallada [aquí](https://docs.coredao.org/docs/Dev-Guide/hardhat#contract-testing) para más detalles.

2. Crea una carpeta `scripts` en el directorio /contract de tu proyecto. Dentro de esta carpeta, crea un archivo `deploy.js`; pega el siguiente script en él.

```javascript
async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploy contract with the account:", deployer.address);

  const Guestbook = await ethers.getContractFactory("Guestbook");

  const guestbook = await Guestbook.deploy();

  console.log("Contract Address:", guestbook.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
```

3. Asegúrate de que tu billetera MetaMask tenga tokens de prueba tCORE para la Red de Pruebas Core. Consulta [aquí](https://docs.coredao.org/docs/Dev-Guide/core-faucet) para detalles sobre cómo obtener tokens tCORE.

4. Ejecuta el siguiente comando desde el directorio raíz de tu proyecto para desplegar tu contrato inteligente en la cadena Core.

```bash
npx hardhat run scripts/deploy.js
```

## Configuración del Frontend

1. En la carpeta raíz, instala todas las dependencias.

```bash
npm install
```

2. En la ruta src/contractABI debemos copiar el ABI de nuestro contrato inteligente en caso de hacer modificaciones, esta información se obtendrá de contract/artifacts/contracts/Guestbook.json.

3. Una vez que el contrato inteligente esté desplegado, es necesario copiar la dirección y reemplazarla en cada uno de los componentes donde realizamos llamadas al contrato, en este caso src/components/New.tsx y src/components/Get.tsx.

4. Para probar si todo está funcionando correctamente, ejecuta la aplicación utilizando el siguiente comando. Esto servirá la aplicación con la función de recarga en caliente en [http://localhost:5173](http://localhost:5173/)

```bash
npm run dev
```

## Añadir Mensaje

 1. Para añadir un nuevo mensaje, primero deberás introducir el texto del nuevo mensaje.
 2. Una vez hecho esto, haz clic en el botón "Add Message" y acepta la transacción en metamask.

<img src="https://raw.githubusercontent.com/open-web-academy/GuestBook-Tutorial-CORE/master/src/public/NewMessage.gif" width="50%">

## Obtener Mensajes

1. Para obtener el listado de mensajes añadidos por los usuarios solo tienes que ir a la opción "Message List" del menú donde se mostrará una tabla con el listado completo de mensajes guardados en el contrato inteligente.

<img src="https://raw.githubusercontent.com/open-web-academy/GuestBook-Tutorial-CORE/master/src/public/MessagesList.gif" width="50%">
