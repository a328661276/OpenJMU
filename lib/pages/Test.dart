import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'package:OpenJMU/utils/ThemeUtils.dart';

class TestPage extends StatefulWidget {
  @override
  _TestPageState createState() => new _TestPageState();
}

class _TestPageState extends State<TestPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        backgroundColor: ThemeUtils.currentColorTheme,
        android: (BuildContext context) => MaterialAppBarData(
          centerTitle: true,
          elevation: 0,
        ),
        title: Text("测试页", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}