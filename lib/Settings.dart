import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:i18n_extension/i18n_widget.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:todo/ColorChooser.dart';
import 'Translations.i18n.dart';
import 'main.dart';

String appVersion = '1.0.0'; //TODO: change after update
String language;

class SettingsWidget extends StatefulWidget {
  @override
  createState() => new SettingsState();
}

class SettingsState extends State {
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
        ),
        themeMode: TodoApp.getThemeMode(),
        home: new Scaffold(
          appBar: new AppBar(
            backgroundColor: TodoApp.getAppColor(),
            leading: Padding(
                padding: EdgeInsets.only(left: 20.0),
                child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(
                      Icons.arrow_back,
                      size: 23.0,
                    ))),
            title: new Text('Settings'.i18n),
          ),
          body: _buildSettings(),
        ));
  }

  Widget _buildSettings() {
    _showLanguage();
    return SettingsList(
      sections: [
        SettingsSection(title: 'Basic'.i18n, tiles: [
          SettingsTile(
              title: 'Language'.i18n,
              subtitle: language,
              leading: Icon(Icons.language),
              onPressed: (BuildContext context) {
                setState(() {
                  _languageSelector();
                });
              })
        ]),
        SettingsSection(title: 'Personalization'.i18n, tiles: [
          SettingsTile(
              title: 'Color'.i18n,
              subtitle: getSubtitle(),
              leading: Icon(Icons.color_lens),
              onPressed: (BuildContext context) {
                _colorChooser();
              }),
          SettingsTile(
            title: 'Theme Mode'.i18n,
            subtitle: _getThemeToShow(),
            leading: Icon(Icons.brightness_3_outlined),
            onPressed: (BuildContext context) {
              setState(() {
                _themeSelector();
              });
            },
          )
        ]),
        SettingsSection(
          title: 'Contact'.i18n,
          tiles: [
            SettingsTile(
              title: 'Report a Bug'.i18n,
              subtitle: 'Report a Bug to the developer'.i18n,
              leading: Icon(Icons.bug_report_outlined),
              onPressed: (BuildContext context) {
                _email();
              },
            ),
          ],
        ),
        SettingsSection(
          title: 'About'.i18n,
          tiles: [
            SettingsTile(
                title: 'Info'.i18n,
                subtitle: 'Information about the App'.i18n,
                leading: Icon(Icons.info_outline_rounded),
                onPressed: (BuildContext context) {
                  _information();
                })
          ],
        )
      ],
    );
  }

  void _languageSelector() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new SimpleDialog(
            title: new Text('Please select a language'.i18n),
            children: [
              SimpleDialogOption(
                  child: new Text('English'.i18n),
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _languageEnglish();
                      _showLanguage();
                    });
                  }),
              SimpleDialogOption(
                  child: new Text('German'.i18n),
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _languageGerman();
                      _showLanguage();
                    });
                  }),
            ],
          );
        });
  }

  void _languageEnglish() {
    I18n.of(context).locale = Locale('en', 'US');
    TodoApp.setSelectedLanguage(Locale('en', 'US'));
  }

  void _languageGerman() {
    I18n.of(context).locale = Locale('de', 'DE');
    TodoApp.setSelectedLanguage(Locale('de', 'DE'));
  }

  String _getThemeToShow() {
    if (TodoApp.getThemeMode() == ThemeMode.light) {
      return 'Lighttheme'.i18n;
    } else if (TodoApp.getThemeMode() == ThemeMode.dark) {
      return 'Darktheme'.i18n;
    } else {
      return 'System'.i18n;
    }
  }

  void _showLanguage() {
    if (TodoApp.getSelectedLanguage() == Locale('de', 'DE')) {
      language = 'German'.i18n;
    } else {
      language = 'English'.i18n;
    }
  }

  void _themeSelector() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new SimpleDialog(
            title: new Text('Select Thememode'.i18n),
            children: [
              SimpleDialogOption(
                child: new Text('Lighttheme'.i18n),
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    TodoApp.setThemeMode(ThemeMode.light);
                    TodoApp.setDarkmode(false);
                  });
                },
              ),
              SimpleDialogOption(
                child: new Text('Darktheme'.i18n),
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    TodoApp.setThemeMode(ThemeMode.dark);
                    TodoApp.setDarkmode(true);
                  });
                },
              ),
              SimpleDialogOption(
                child: new Text('System'.i18n),
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    TodoApp.setThemeMode(ThemeMode.system);
                    TodoApp.setDarkmode(null);
                  });
                },
              )
            ],
          );
        });
  }

  Future<void> _colorChooser() async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return ColorChooser();
    }));
    setState(() {});
  }

  void _information() {
    showAboutDialog(
      context: context,
      applicationName: 'Todo App'.i18n,
      applicationVersion: appVersion,
      applicationLegalese: '©Julian Schumacher 2021 All rights reserved'.i18n,
    );
  }

  getSubtitle() {
    var color = TodoApp.getAppColor();
    if (color != null) {
      for (int colorIndex = 0;
          colorIndex < ColorChooserState.colors.length;
          colorIndex++) {
        var colorInArray = ColorChooserState.colors[colorIndex];
        if (colorInArray.value == color.value) {
          return ColorChooserState.namesOfColors[colorIndex];
        }
      }
    }
    return 'Default'.i18n;
  }

  final String _mailAdresse =
      'mailto:jules.mediadesign@gmail.com?subject=Bug%20Report&body_';

  _email() {
    launch(_mailAdresse);
  }
}
