
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';

import 'package:velocity_x/velocity_x.dart';
import 'package:web3dart/web3dart.dart';



void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool data = false;

  late Client httpClient;
  late Web3Client ethClient;
  final myAdress = "0x5Ee34750B42a5bb3096caAABc7B4529DBc71f138";
  int myAmount = 0;
  var myData;
  double _value = 0;
  late EthereumAddress address1;
  // var gas = BigInt.from(1);
  EtherAmount k = EtherAmount.inWei(BigInt.from(1));

  @override
  void initState() {
    httpClient = Client();
    ethClient = Web3Client(
        "https://rinkeby.infura.io/v3/906b586831b447c0b2e8ce94cdd4268e",
        httpClient);
    getBalance(myAdress);
    super.initState();
  }

  // -------------------- Contract need to be loaded ------------------    //

  Future<DeployedContract> loadContract() async {
    String abi = await rootBundle.loadString("assets/abi.json");
    String contractAddress = "0xFf0bEBb533eB809db6df9662C73b84033968c237";
    final contract = DeployedContract(
      ContractAbi.fromJson(abi, "LuciferCoin"),
      EthereumAddress.fromHex(contractAddress),
    );
    return contract;
  }

// -------------------- Contract.(FUNCTION_NAME) ------------------    //
  Future<List<dynamic>> query(String functionName, List<dynamic> args) async {
    final contract = await loadContract();
    final ethFunction = contract.function(functionName);
    final result = await ethClient.call(
      //fetching
      contract: contract,
      function: ethFunction,
      params: args,
    );
    return result;
  }

// -------------------- GetBalance() ------------------    //
  Future<void> getBalance(String targetAddress) async {
    EthereumAddress address = EthereumAddress.fromHex(targetAddress);
    address1 = address;
    List<dynamic> result = await query("getBalance", []);
    myData = result[0];
    data = true;
    setState(() {});
  }

  Future<String> submit(String functionName, List<dynamic> args) async {
    String contractAddress = "0xFf0bEBb533eB809db6df9662C73b84033968c237";

    EthPrivateKey credentials = EthPrivateKey.fromHex(
        "7a9855ae14947df080d050a4b843d81594cc792aa3dafa2808f138e56e7ce212");
    // Credentials credentials =
    //     await ethClient.credentialsFromPrivateKey(privateKey);
    DeployedContract contract = await loadContract();
    print(functionName);
    final ethFunction = contract.function(functionName);

    // From smart_contract comaper code , changes - Abi, contract address , minor things

    final result = await ethClient.sendTransaction(
      credentials,
      Transaction.callContract(
        from: EthereumAddress.fromHex(
            "0x5Ee34750B42a5bb3096caAABc7B4529DBc71f138"),
        maxGas: 2,
        gasPrice: k,

        // EthereumAddress.fromHex(myAdress),
        contract: contract,
        function: ethFunction,
        parameters: args,
      ),
    );
    return result;
  }

  Future<String> sendCoin() async {
    var bigAmount = BigInt.from(2);
    print(bigAmount);
    var response = await submit("depositBalance", [bigAmount]);

    return response;
  }

  Future<String> withdrawCoin() async {
    var bigAmount = BigInt.from(myAmount);

    var response = await submit("withdrawBlance", [bigAmount]);

    return response;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Vx.gray300,
        body: ZStack([
          VxBox()
              .blue600
              .size(context.screenWidth, context.percentHeight * 30)
              .make(),
          VStack([
            Container(
              height: context.percentHeight * 30,
              width: context.screenWidth,
              child: Center(
                child: Text(
                  "LuciferCoin",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            VxBox(
              child: VStack(
                [
                  "Balance".text.gray700.xl2.semiBold.makeCentered(),
                  data
                      ? "\$$myData".text.bold.xl2.makeCentered().shimmer()
                      : CircularProgressIndicator().centered()
                ],
              ),
            )
                .py16
                .white
                .size(context.screenWidth, context.percentHeight * 18)
                .rounded
                .shadowXl
                .p16
                .make(),
            30.heightBox,
            Slider(
              min: 0,
              max: 100,
              value: _value,
              onChanged: (value) {
                setState(() {
                  _value = value;
                  myAmount = ((value * 100) / 1000).round();
                  print(myAmount);
                });
              },
            ),
            // SliderWidget(
            //   min: 0,
            //   max: 100,
            //   finalVal: (value) {
            //     setState(() {
            //       myAmount = (value * 100).round();
            //       print(myAmount);
            //       // print(_value)
            //     });
            //   },
            // ).centered(),
            10.heightBox,
            HStack(
              [
                FlatButton.icon(
                  color: Colors.blue,
                  onPressed: () => getBalance(myAdress),
                  shape: Vx.roundedSm,
                  icon: Icon(
                    Icons.refresh,
                    color: Colors.white,
                  ),
                  label: "Refresh".text.white.make(),
                ).h(50),
                FlatButton.icon(
                  color: Colors.green,
                  shape: Vx.roundedSm,
                  onPressed: () => sendCoin(),
                  icon: Icon(
                    Icons.call_made_outlined,
                    color: Colors.white,
                  ),
                  label: "deposit".text.white.make(),
                ).h(50),
                FlatButton.icon(
                  color: Colors.red,
                  shape: Vx.roundedSm,
                  onPressed: () => withdrawCoin(),
                  icon: Icon(
                    Icons.call_received_outlined,
                    color: Colors.white,
                  ),
                  label: "Withdraw".text.white.make(),
                ).h(50),
              ],
              alignment: MainAxisAlignment.spaceAround,
              axisSize: MainAxisSize.max,
            )
          ])
        ]),
      ),
    );
  }
}
