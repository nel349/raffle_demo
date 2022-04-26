import 'package:http/http.dart';
import 'package:smart_contract/Nft.g.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';


const String wsUrl = 'ws://localhost:8545';
const rpcURL = 'https://ropsten.infura.io/v3/a2293dab520a45fba5a5ab184d14e8ab'; // ethereum
const rpcURLRinkeby = 'https://rinkeby.infura.io/v3/a2293dab520a45fba5a5ab184d14e8ab';
const rpcMumbai = 'https://polygon-mumbai.g.alchemy.com/v2/wDKjb83mAC3ok5MgMg1vWvc78NAa59zo'; // Polygon
const String wsUrlMumbai = 'wss://polygon-mumbai.g.alchemy.com/v2/wDKjb83mAC3ok5MgMg1vWvc78NAa59zo';

const String privateKey =
    '12ba688b588f2096b1af28d16cff4037bbc735a38f8c975a6b9a4582dc16fdff';
final EthereumAddress contractAddr =
EthereumAddress.fromHex('0x9aE9F996C208B4224148bA4E1782c8A3d43a0e28');

// final EthereumAddress receiver = EthereumAddress.fromHex('0x6c87E1a114C3379BEc929f6356c5263d62542C13');

class NftContract {
  Future<void> mintWithCid(String cid) async {
    // establish a connection to the ethereum rpc node. The socketConnector
    // property allows more efficient event streams over websocket instead of
    // http-polls. However, the socketConnector property is experimental.
    final client = Web3Client(rpcMumbai, Client(), socketConnector: () {
      return IOWebSocketChannel.connect(wsUrl).cast<String>();
    });
    final credentials = EthPrivateKey.fromHex(privateKey);
    final ownAddress = await credentials.extractAddress();

    // read the contract abi and tell web3dart where it's deployed (contractAddr)
    final nftContract = Nft(address: contractAddr, client: client);

    // listen for the Transfer event when it's emitted by the contract above
    final subscription = nftContract.transferEvents().take(1).listen((event) {
      print('${event.from} sent ${event.tokenId} MetaCoins to ${event.to}!');
    });

    // check the number of NFT tokens by calling the appropriate function
    final ownedTokens = await nftContract.walletOfOwner(ownAddress);
    print('We have ${ownedTokens.length} nft tokens');

    final transactionValue = Transaction(
      to: contractAddr,
      value: EtherAmount.fromUnitAndValue(EtherUnit.gwei, '100000000'), // 0.1 ether
    );

    //unpause contract
    final paused = await nftContract.paused();

    // mint a token
    final mintTransactionData = !paused ?
    await nftContract.mint(BigInt.one, transaction: transactionValue,
        credentials: credentials) : "";

    if (mintTransactionData.isNotEmpty) {

      print('Minting hash: $mintTransactionData');
      nftContract.setHiddenMetadataUri(
          "https://gateway.pinata.cloud/ipfs/$cid",
          credentials: credentials);
    }

    // // send all our MetaCoins to the other address by calling the sendCoin
    // // function
    // await token.sendCoin(receiver, balance, credentials: credentials);
    //
    await subscription.asFuture();
    await subscription.cancel();
    //
    await client.dispose();
  }
}


