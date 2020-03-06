import 'package:capo/modules/balance/send/view_model/send_view_model.dart';
import 'package:capo/provider/provider_widget.dart';
import 'package:capo/utils/capo_utils.dart';
import 'package:easy_localization/public.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

@FFRoute(name: "capo://icapo.app/balance/send")
class SendPage extends StatelessWidget {
  final _sendViewModel = SendViewModel();

  SendPage({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('sendPage.title')),
        actions: <Widget>[
          IconButton(
            icon: Icon(IconData(0xeb1f, fontFamily: 'iconfont')),
            onPressed: () {
              _sendViewModel.scan();
            },
          )
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanDown: (_) {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ProviderWidget<SendViewModel>(
            model: _sendViewModel,
            onModelReady: (model) {
              model.getRevBalance(context);
            },
            builder: (context, viewModel, __) => Theme(
              data: Theme.of(context).copyWith(
                primaryColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black54,
              ),
              child: ListView(children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    boxShadow: [
                      new BoxShadow(
                        color: Colors.black12,
                        offset: new Offset(0.0, 1.0),
                        blurRadius: 2.0,
                      )
                    ],

                    color: Theme.of(context).cardColor,
                    borderRadius: new BorderRadius.circular((10.0)), // 圆角度
                  ),
                  child: Column(
                    children: <Widget>[
                      TextField(
                        cursorColor: Theme.of(context).textTheme.subhead.color,
                        maxLines: viewModel.transferAddress.length > 0 ? 2 : 1,
                        keyboardType: TextInputType.text,
                        style: TextStyle(
                            fontSize:
                                viewModel.transferAddress.length > 0 ? 12 : 18),
                        controller: viewModel.addressEditController,
                        enabled: !viewModel.fromDonate,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            labelText: tr("sendPage.to_hint"),
                            labelStyle: TextStyle(fontSize: 18),
                            suffixIcon: CupertinoButton(
                              onPressed: () async {
                                await Future.delayed(Duration(milliseconds: 50))
                                    .then((_) async {
                                  ClipboardData r =
                                      await Clipboard.getData('text/plain');

                                  if (r != null &&
                                      r.text != null &&
                                      r.text.length > 0) {
                                    viewModel.addressEditController.text =
                                        r.text;
                                  }
                                });
                              },
                              padding: EdgeInsets.all(0),
                              child: Text(
                                tr("sendPage.paste"),
                                style: TextStyle(
                                    color: HexColor.mainColor, fontSize: 14),
                              ),
                            )),
                      ),
                      Divider(
                        height: 5,
                      ),
                      TextField(
                        controller: viewModel.transferAmountEditController,
                        cursorColor: Theme.of(context).textTheme.subhead.color,
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            labelText: tr("sendPage.amount_hint"),
                            labelStyle: TextStyle(fontSize: 18),
                            suffixIcon: CupertinoButton(
                              onPressed: () async {
                                await Future.delayed(Duration(milliseconds: 50))
                                    .then((_) {
                                  viewModel.transferAmountEditController.text =
                                      viewModel.maxTransferAmount;
                                });
                              },
                              padding: EdgeInsets.all(0),
                              child: Text(
                                tr("sendPage.max"),
                                style: TextStyle(
                                    color: HexColor.mainColor, fontSize: 14),
                              ),
                            )),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Text(tr("sendPage.balance",
                        args: [viewModel.selfRevBalance])),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                CupertinoButton(
                  color: Color.fromARGB(255, 51, 118, 184),
                  padding: EdgeInsets.all(16),
                  pressedOpacity: 0.8,
                  child: Text(
                    tr("sendPage.btn_title"),
                    style: Theme.of(context).textTheme.button,
                  ),
                  onPressed:
                      viewModel.btnEnable ? viewModel.tappedSendBtn : null,
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
