import 'package:capo/modules/settings/settings_modules/dark_mode/view_model/view_model.dart';
import 'package:capo/provider/provider_widget.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:ff_annotation_route/ff_annotation_route.dart';
import 'package:flutter/material.dart';

@FFRoute(name: "capo://icapo.app/settings/dark_mode")
class SettingDarkModePage extends StatelessWidget {
  SettingDarkModePage({Key key}) : super(key: key);
  final settingDarkModeViewModel = SettingDarkModeViewModel();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr("settings.dark_mode_setting.title")),
      ),
      body: ProviderWidget<SettingDarkModeViewModel>(
        model: settingDarkModeViewModel,
        onModelReady: settingDarkModeViewModel.getUserSetting(context),
        builder: ((_, viewModel, __) {
          return ListView.builder(
              itemCount: viewModel.listModel.length,
              itemBuilder: (_, index) {
                return viewModel.listModel == null ||
                        viewModel.listModel.isEmpty
                    ? Container()
                    : Column(
                        children: <Widget>[
                          viewModel.listModel[index].showDivider
                              ? Divider(
                                  height: 1,
                                  indent: 16,
                                )
                              : Container(),
                          ListTile(
                            title: Text(viewModel.listModel[index].title),
                            trailing: viewModel.listModel[index].selected
                                ? Container(
                                    width: 20.0,
                                    height: 20.0,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color:
                                            Color.fromARGB(255, 255, 255, 255)),
                                    child: Icon(
                                      Icons.check_circle,
                                      size: 20,
                                      color: Color.fromARGB(255, 51, 118, 184),
                                    ),
                                  )
                                : null,
                            onTap: () {
                              viewModel.tappedCell(index, context);
                            },
                          ),
                        ],
                      );
              });
        }),
      ),
    );
  }
}
