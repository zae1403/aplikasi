// import 'package:fancy_bottom_navigation/internal/tab_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/helper/constant.dart';
import 'package:flutter_twitter_clone/state/appState.dart';
import 'package:flutter_twitter_clone/state/authState.dart';
import 'package:flutter_twitter_clone/widgets/bottomMenuBar/tabItem.dart';
import 'package:provider/provider.dart';
import '../customWidgets.dart';
// import 'customBottomNavigationBar.dart';

class BottomMenubar extends StatefulWidget {
  const BottomMenubar({this.pageController});
  final PageController pageController;
  _BottomMenubarState createState() => _BottomMenubarState();
}

class _BottomMenubarState extends State<BottomMenubar> {
  PageController _pageController;
  int _selectedIcon = 0;
  @override
  void initState() {
    _pageController = widget.pageController;
    super.initState();
  }

  Widget _iconRow() {
    var state = Provider.of<AppState>(
      context,
    );

    return Container(
      child: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 6.0,
        elevation: 9.0,
        clipBehavior: Clip.antiAlias,
        color: Colors.transparent,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0)),
              color: Colors.white),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 50.0,
                width: MediaQuery.of(context).size.width / 2 - 40.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    _icon(null, 0,
                        icon: 0 == state.pageIndex
                            ? AppIcon.iconhomecircled
                            : AppIcon.iconhome,
                        isCustomIcon: true),
                    _icon(null, 1,
                        icon: 1 == state.pageIndex
                            ? AppIcon.iconsearchcircled
                            : AppIcon.iconsearch,
                        isCustomIcon: true),
                  ],
                ),
              ),
              Container(
                height: 50.0,
                width: MediaQuery.of(context).size.width / 2 - 40.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    _icon(null, 2,
                        icon: 2 == state.pageIndex
                            ? AppIcon.iconcwcircled
                            : AppIcon.iconcw,
                        isCustomIcon: true),
                    _icon(null, 3,
                        icon: 3 == state.pageIndex
                            ? AppIcon.iconmailcircled
                            : AppIcon.iconmail,
                        isCustomIcon: true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _icon(IconData iconData, int index,
      {bool isCustomIcon = false, int icon}) {
    var state = Provider.of<AppState>(
      context,
    );
    return Expanded(
      child: Container(
        height: double.infinity,
        width: double.infinity,
        child: AnimatedAlign(
          duration: Duration(milliseconds: ANIM_DURATION),
          curve: Curves.easeIn,
          alignment: Alignment(0, ICON_ON),
          child: AnimatedOpacity(
            duration: Duration(milliseconds: ANIM_DURATION),
            opacity: ALPHA_ON,
            child: IconButton(
              icon: isCustomIcon
                  ? customIcon(context,
                      icon: icon,
                      size: 18,
                      istwitterIcon: true,
                      isEnable: index == state.pageIndex)
                  : Icon(
                      iconData,
                      color: index == state.pageIndex
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).textTheme.caption.color,
                    ),
              onPressed: () {
                setState(() {
                  _selectedIcon = index;
                  state.setpageIndex = index;
                });
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _iconRow();
  }
}
