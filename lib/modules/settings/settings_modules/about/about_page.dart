import 'package:capo/modules/settings/settings_modules/about/view_model/about_view_model.dart';
import 'package:capo/provider/provider_widget.dart';
import 'package:capo/utils/capo_utils.dart';
import 'package:easy_localization/public.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:oktoast/oktoast.dart';

@FFRoute(name: "capo://icapo.app/settings/about")
class CapoAboutPage extends StatelessWidget {
  CapoAboutPage({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Color.fromARGB(255, 48, 48, 48)
          : Color.fromARGB(255, 241, 242, 246),
      appBar: AppBar(
        title: Text(tr("settings.about_page.title")),
      ),
      body: SafeArea(
        child: ProviderWidget<AboutViewModel>(
          model: AboutViewModel(),
          onModelReady: (model) {
            model.getVersionNumber();
          },
          builder: (_, viewModel, __) {
            return ListView(
              padding: EdgeInsets.all(16),
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "resources/images/app_icon/capo_icon.png",
                      fit: BoxFit.cover,
                      height: 50.0,
                      width: 50.0,
                    ),
                    Container(
//                      color: Colors.red,
                      width: 80,
                      child: ListTile(
                        title: FittedBox(
                          child: Text(
                            "Capo",
                            style: Theme.of(context).textTheme.title,
                          ),
                        ),
                        subtitle: Text(
                          viewModel.version != null ? viewModel.version : "",
                          style: Theme.of(context).textTheme.subtitle.apply(
                              color: Theme.of(context).textTheme.caption.color),
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                Divider(
                  height: 3,
                ),
                SizedBox(
                  height: 16,
                ),
                Text(
                  tr("settings.about_page.terms_and_privacy"),
                  style: Theme.of(context)
                      .textTheme
                      .subtitle
                      .apply(color: HexColor.mainColor),
                ),
                SizedBox(
                  height: 8,
                ),
                MarkdownBody(
                  data: tr("settings.about_page.terms"),
                  onTapLink: (href) {
                    if (href.startsWith(RegExp(r'https?:'))) {
                      showBottomSheet(context, href);
                      return;
                    } else if (href.startsWith("capo://icapo.app/")) {
                      String routeUrl = href +
                          "?revAddress=11116jG2AWyfB8LXPUtqkgzE6rNrS3E3VcJHi9JqBG5SPMjYYZTAK&donate=true";
                      Navigator.pushNamed(context, routeUrl);
                    }
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  showBottomSheet(BuildContext context, String copyContent) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Stack(children: <Widget>[
          Container(
            height: 100 + MediaQuery.of(context).padding.bottom,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
          ),
          Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Container(
                height: 50,
                width: double.infinity,
                child: Center(
                    child: Text(
                  copyContent,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.caption,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                )),
              ),
            ),
            Container(
              color: Theme.of(context).highlightColor,
              height: 1,
            ),
            Container(
              height: 50,
              width: double.infinity,
              child: CupertinoButton(
                padding: EdgeInsets.all(0),
                child: Text(
                  tr("transaction_detail.copy_btn_title"),
                  style: TextStyle(
                      color: HexColor.mainColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                ),
                onPressed: () async {
                  final data = ClipboardData(text: copyContent);
                  await Clipboard.setData(data);
                  showToast(tr("transaction_detail.copy_hint"));
                  Navigator.pop(context);
                },
              ),
            ),
//            Divider(),
          ])
        ]);
      },
    );
  }
}
