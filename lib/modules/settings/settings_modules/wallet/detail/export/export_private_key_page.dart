import 'package:easy_localization/public.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oktoast/oktoast.dart';

@FFRoute(name: "capo://icapo.app/settings/wallets/detail/export_private_key")
class ExportPrivateKeyPage extends StatelessWidget {
  ExportPrivateKeyPage({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(tr("settings.wallets.detail.export_private_key_page.title")),
      ),
      body: SafeArea(child: bodyWidget(context)),
    );
  }

  Widget bodyWidget(context) {
    String privateKey;
    final Map map = ModalRoute.of(context).settings.arguments;
    if (map != null && map.isNotEmpty) {
      privateKey = map['privateKey'];
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Stack(children: [
        ListView(
          children: <Widget>[
            Text(
              tr("settings.wallets.detail.export_private_key_page.export_tip"),
              style: Theme.of(context).textTheme.title.apply(fontSizeDelta: 5),
            ),
            SizedBox(
              height: 14,
            ),
            Text(
              tr("settings.wallets.detail.export_private_key_page.desc"),
              style:
                  Theme.of(context).textTheme.caption.apply(fontSizeDelta: 5),
            ),
            SizedBox(
              height: 25,
            ),
            SizedBox(
              height: 0.5,
              child: Container(
                color: Theme.of(context).textTheme.caption.color,
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Text(
              tr("settings.wallets.detail.export_private_key_page.first_tip"),
              style:
                  Theme.of(context).textTheme.caption.apply(fontSizeDelta: 4),
              maxLines: 2,
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              tr("settings.wallets.detail.export_private_key_page.second_tip"),
              style:
                  Theme.of(context).textTheme.caption.apply(fontSizeDelta: 4),
              maxLines: 2,
            ),
            SizedBox(
              height: 16,
            ),
            Container(
              padding: EdgeInsets.all(8),
              child: Text(
                privateKey,
                style:
                    Theme.of(context).textTheme.caption.apply(fontSizeDelta: 4),
                maxLines: 3,
              ),
              decoration: new BoxDecoration(
                border: new Border.all(
                    width: 1.5, color: Theme.of(context).dividerColor),
                color: Theme.of(context).dividerColor,
                borderRadius: new BorderRadius.all(new Radius.circular(8.0)),
              ),
            )
          ],
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: CupertinoButton(
            padding: EdgeInsets.all(16),
            pressedOpacity: 0.8,
            color: Color.fromARGB(255, 51, 118, 184),
            child: Text(
              tr("settings.wallets.detail.export_private_key_page.btn_title"),
              style: Theme.of(context).textTheme.button,
            ),
            onPressed: () async {
              final data = ClipboardData(text: privateKey);
              await Clipboard.setData(data);
              showToast(
                  tr("settings.wallets.detail.export_private_key_page.copied"));
            },
          ),
        )
      ]),
    );
  }
}
