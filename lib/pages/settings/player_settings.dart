import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:fvp/fvp.dart' as fvp;
import 'package:hive/hive.dart';
import 'package:kazumi/bean/appbar/sys_app_bar.dart';
import 'package:kazumi/bean/settings/settings.dart';
import 'package:kazumi/utils/constants.dart';
import 'package:kazumi/utils/storage.dart';

class PlayerSettingsPage extends StatefulWidget {
  const PlayerSettingsPage({super.key});

  @override
  State<PlayerSettingsPage> createState() => _PlayerSettingsPageState();
}

class _PlayerSettingsPageState extends State<PlayerSettingsPage> {
  Box setting = GStorage.setting;
  late double defaultPlaySpeed;

  @override
  void initState() {
    super.initState();
    defaultPlaySpeed =
        setting.get(SettingBoxKey.defaultPlaySpeed, defaultValue: 1.0);
  }

  void onBackPressed(BuildContext context) {
    // Navigator.of(context).pop();
  }

  void updateDefaultPlaySpeed(double speed) {
    setting.put(SettingBoxKey.defaultPlaySpeed, speed);
    setState(() {
      defaultPlaySpeed = speed;
    });
  }

  void updateFvp() async {
    bool hAenable =
        await setting.get(SettingBoxKey.hAenable, defaultValue: true);
    bool lowMemoryMode =
        await setting.get(SettingBoxKey.lowMemoryMode, defaultValue: false);
    if (hAenable) {
      if (lowMemoryMode) {
        fvp.registerWith(options: {
          'platforms': ['windows', 'linux', 'macos'],
          'player': {
            'avio.reconnect': '1',
            'avio.reconnect_delay_max': '7',
            'buffer': '2000+10000',
          }
        });
      } else {
        fvp.registerWith(options: {
          'platforms': ['windows', 'linux', 'macos'],
          'player': {
            'avio.reconnect': '1',
            'avio.reconnect_delay_max': '7',
            'buffer': '2000+1500000',
            'demux.buffer.ranges': '8',
          }
        });
      }
    } else {
      if (lowMemoryMode) {
        fvp.registerWith(options: {
          'video.decoders': ['FFmpeg'],
          'player': {
            'avio.reconnect': '1',
            'avio.reconnect_delay_max': '7',
            'buffer': '2000+10000',
          }
        });
      } else {
        fvp.registerWith(options: {
          'video.decoders': ['FFmpeg'],
          'player': {
            'avio.reconnect': '1',
            'avio.reconnect_delay_max': '7',
            'buffer': '2000+1500000',
            'demux.buffer.ranges': '8',
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {});
    return WillPopScope(
      onWillPop: () async {
        onBackPressed(context);
        // 返回true表示允许路由弹出，返回false表示阻止路由弹出
        return true;
      },
      child: Scaffold(
        appBar: const SysAppBar(title: Text('播放设置')),
        body: Column(
          children: [
            InkWell(
              child: SetSwitchItem(
                title: '硬件解码',
                setKey: SettingBoxKey.hAenable,
                callFn: (_) => updateFvp(),
                defaultVal: true,
              ),
            ),
            InkWell(
              child: SetSwitchItem(
                title: '低内存模式',
                subTitle: '禁用高级缓存以减少内存占用',
                setKey: SettingBoxKey.lowMemoryMode,
                callFn: (_) => updateFvp(),
                defaultVal: false,
              ),
            ),
            const InkWell(
              child: SetSwitchItem(
                title: '自动跳转',
                subTitle: '跳转到上次播放位置',
                setKey: SettingBoxKey.playResume,
                defaultVal: true,
              ),
            ),
            ListTile(
              onTap: () async {
                SmartDialog.show(
                    animationTime: const Duration(milliseconds: 100),
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('默认倍速'),
                        content: StatefulBuilder(builder:
                            (BuildContext context, StateSetter setState) {
                          final List<double> playSpeedList;
                          if (Platform.isIOS &&
                              setting.get(SettingBoxKey.hAenable,
                                  defaultValue: true)) {
                            playSpeedList = defaultPlaySpeedList;
                          } else {
                            playSpeedList =
                                defaultPlaySpeedList + extendPlaySpeedList;
                          }
                          return Wrap(
                            spacing: 8,
                            runSpacing: 2,
                            children: [
                              for (final double i in playSpeedList) ...<Widget>[
                                if (i == defaultPlaySpeed) ...<Widget>[
                                  FilledButton(
                                    onPressed: () async {
                                      updateDefaultPlaySpeed(i);
                                      SmartDialog.dismiss();
                                    },
                                    child: Text(i.toString()),
                                  ),
                                ] else ...[
                                  FilledButton.tonal(
                                    onPressed: () async {
                                      updateDefaultPlaySpeed(i);
                                      SmartDialog.dismiss();
                                    },
                                    child: Text(i.toString()),
                                  ),
                                ]
                              ]
                            ],
                          );
                        }),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => SmartDialog.dismiss(),
                            child: Text(
                              '取消',
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.outline),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              updateDefaultPlaySpeed(1.0);
                              SmartDialog.dismiss();
                            },
                            child: const Text('默认设置'),
                          ),
                        ],
                      );
                    });
              },
              dense: false,
              title: const Text('默认倍速'),
              subtitle: Text('$defaultPlaySpeed',
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium!
                      .copyWith(color: Theme.of(context).colorScheme.outline)),
            ),
          ],
        ),
      ),
    );
  }
}
