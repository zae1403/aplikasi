import 'package:flutter/material.dart';
import 'package:flutter_twitter_clone/helper/constant.dart';
import 'package:flutter_twitter_clone/helper/enum.dart';
import 'package:flutter_twitter_clone/helper/utility.dart';
import 'package:flutter_twitter_clone/helper/theme.dart';
import 'package:flutter_twitter_clone/model/feedModel.dart';
import 'package:flutter_twitter_clone/model/user.dart';
import 'package:flutter_twitter_clone/page/profile/widgets/tabPainter.dart';
import 'package:flutter_twitter_clone/state/authState.dart';
import 'package:flutter_twitter_clone/state/chats/chatState.dart';
import 'package:flutter_twitter_clone/state/feedState.dart';
import 'package:flutter_twitter_clone/widgets/customWidgets.dart';
import 'package:flutter_twitter_clone/widgets/newWidget/customLoader.dart';
import 'package:flutter_twitter_clone/widgets/newWidget/customUrlText.dart';
import 'package:flutter_twitter_clone/widgets/newWidget/emptyList.dart';
import 'package:flutter_twitter_clone/widgets/newWidget/rippleButton.dart';
import 'package:flutter_twitter_clone/widgets/tweet/tweet.dart';
import 'package:flutter_twitter_clone/widgets/tweet/widgets/tweetBottomSheet.dart';
import 'package:provider/provider.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key key, this.profileId}) : super(key: key);

  final String profileId;

  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  bool isMyProfile = false;
  int pageIndex = 0;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var authstate = Provider.of<AuthState>(context, listen: false);
      authstate.getProfileUser(userProfileId: widget.profileId);
      isMyProfile =
          widget.profileId == null || widget.profileId == authstate.userId;
    });
    _tabController = TabController(length: 1, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  SliverAppBar getAppbar() {
    var authstate = Provider.of<AuthState>(context);
    return SliverAppBar(
      forceElevated: false,
      expandedHeight: 150,
      elevation: 0,
      stretch: true,
      iconTheme: IconThemeData(color: Colors.amber),
      backgroundColor: Colors.transparent,
      actions: <Widget>[
        authstate.isbusy
            ? SizedBox.shrink()
            : PopupMenuButton<Choice>(
                onSelected: (d) {},
                itemBuilder: (BuildContext context) {
                  return choices.map((Choice choice) {
                    return PopupMenuItem<Choice>(
                      value: choice,
                      child: Text(choice.title),
                    );
                  }).toList();
                },
              ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: <StretchMode>[
          StretchMode.zoomBackground,
          StretchMode.blurBackground
        ],
        background: authstate.isbusy
            ? SizedBox.shrink()
            : Stack(
                alignment: Alignment.topCenter,
                children: <Widget>[
                  SizedBox.expand(
                    child: Container(
                      padding: EdgeInsets.only(top: 30),
                      height: 30,
                      color: Colors.white,
                    ),
                  ),
                  // Container(height: 50, color: Colors.black),

                  /// Banner image
                  Container(
                    height: 200,
                    padding: EdgeInsets.only(top: 60),
                    child: RippleButton(
                      child: customImage(
                        context,
                        authstate.profileUserModel.profilePic,
                        height: 100,
                      ),
                      borderRadius: BorderRadius.circular(40),
                      onPressed: () {
                        Navigator.pushNamed(context, "/ProfileImageView");
                      },
                    ),
                  ),

                  /// User avatar, message icon, profile edit and follow/following button
                  Container(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        AnimatedContainer(
                          duration: Duration(milliseconds: 500),
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 5),
                              shape: BoxShape.circle),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _emptyBox() {
    return SliverToBoxAdapter(child: SizedBox.shrink());
  }

  isFollower() {
    var authstate = Provider.of<AuthState>(context);
    if (authstate.profileUserModel.followersList != null &&
        authstate.profileUserModel.followersList.isNotEmpty) {
      return (authstate.profileUserModel.followersList
          .any((x) => x == authstate.userModel.userId));
    } else {
      return false;
    }
  }

  /// This meathod called when user pressed back button
  /// When profile page is about to close
  /// Maintain minimum user's profile in profile page list
  Future<bool> _onWillPop() async {
    final state = Provider.of<AuthState>(context, listen: false);

    /// It will remove last user's profile from profileUserModelList
    state.removeLastUser();
    return true;
  }

  TabController _tabController;

  @override
  build(BuildContext context) {
    var state = Provider.of<FeedState>(context);
    var authstate = Provider.of<AuthState>(context);
    List<FeedModel> list;
    String id = widget.profileId ?? authstate.userId;

    /// Filter user's tweet among all tweets available in home page tweets list
    if (state.feedlist != null && state.feedlist.length > 0) {
      list = state.feedlist.where((x) => x.userId == id).toList();
    }
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: TwitterColor.mystic,
        body: NestedScrollView(
          // controller: _scrollController,
          headerSliverBuilder: (BuildContext context, bool boxIsScrolled) {
            return <Widget>[
              getAppbar(),
              authstate.isbusy
                  ? _emptyBox()
                  : SliverToBoxAdapter(
                      child: Container(
                        color: Colors.white,
                        child: authstate.isbusy
                            ? SizedBox.shrink()
                            : UserNameRowWidget(
                                user: authstate.profileUserModel,
                                isMyProfile: isMyProfile,
                              ),
                      ),
                    ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Container(
                      color: TwitterColor.white,
                      child: TabBar(
                        controller: _tabController,
                        tabs: <Widget>[
                          Text(
                            "Portfolio",
                            style: TextStyle(color: Colors.black),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              /// Display all independent tweers list
              _tweetList(context, authstate, list, false, false),

              /// Display all reply tweet list

              /// Display all reply and comments tweet list
            ],
          ),
        ),
      ),
    );
  }

  Widget _tweetList(BuildContext context, AuthState authstate,
      List<FeedModel> tweetsList, bool isreply, bool isMedia) {
    List<FeedModel> list;

    /// If user hasn't tweeted yet
    if (tweetsList == null) {
      // cprint('No Tweet avalible');
    } else if (isMedia) {
      /// Display all Tweets with media file
      list = tweetsList.where((x) => x.imagePath != null).toList();
    } else if (!isreply) {
      /// Display all independent Tweets
      /// No comments Tweet will display
      list = tweetsList
          .where((x) => x.parentkey == null || x.childRetwetkey != null)
          .toList();
    } else {
      /// Display all reply Tweets
      /// No intependent tweet will display
      list = tweetsList
          .where((x) => x.parentkey != null && x.childRetwetkey == null)
          .toList();
    }

    /// if [authState.isbusy] is true then an loading indicator will be displayed on screen.
    return authstate.isbusy
        ? Container(
            height: fullHeight(context) - 180,
            child: CustomScreenLoader(
              height: double.infinity,
              width: fullWidth(context),
              backgroundColor: Colors.white,
            ),
          )

        /// if tweet list is empty or null then need to show user a message
        : list == null || list.length < 1
            ? Container(
                padding: EdgeInsets.only(top: 50, left: 30, right: 30),
                child: NotifyText(
                  title: isMyProfile
                      ? ''
                      : '${authstate.profileUserModel.userName} hasn\'t ${isreply ? 'reply to any Tweet' : isMedia ? 'post any media Tweet yet' : 'post any Tweet yet'}',
                  subTitle: isMyProfile ? '' : '',
                ),
              )

            /// If tweets available then tweet list will displayed
            : ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 0),
                itemCount: list.length,
                itemBuilder: (context, index) => Container(
                  color: TwitterColor.white,
                  child: Tweet(
                    model: list[index],
                    isDisplayOnProfile: true,
                    trailing: TweetBottomSheet().tweetOptionIcon(
                      context,
                      list[index],
                      TweetType.Tweet,
                    ),
                  ),
                ),
              );
  }
}

class UserNameRowWidget extends StatelessWidget {
  const UserNameRowWidget({
    Key key,
    @required this.user,
    @required this.isMyProfile,
  }) : super(key: key);

  final bool isMyProfile;
  final User user;

  String getBio(String bio) {
    if (isMyProfile) {
      return bio;
    } else if (bio == "Edit profile untuk update") {
      return "Bio tidak tersedia";
    } else {
      return bio;
    }
  }

  Widget _tappbleText(
      BuildContext context, String count, String text, String navigateTo) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/$navigateTo');
      },
      child: Row(
        children: <Widget>[
          customText(
            '$count ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          customText(
            '$text',
            style: TextStyle(color: AppColor.darkGrey, fontSize: 17),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var authstate = Provider.of<AuthState>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            UrlText(
              text: user.displayName,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(
              width: 3,
            ),
            user.isVerified
                ? customIcon(context,
                    icon: AppIcon.blueTick,
                    istwitterIcon: true,
                    iconColor: AppColor.primary,
                    size: 13,
                    paddingIcon: 3)
                : SizedBox(width: 0),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(top: 6, bottom: 6),
          child: customText(
            '${user.userName}',
            style: subtitleStyle.copyWith(fontSize: 13),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: customText(
            getBio(user.bio),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Icon(
                Icons.location_on,
                size: 14,
                color: Colors.grey,
              ),
            ),
            SizedBox(width: 6),
            Center(
              child: customText(
                user.location,
                style: TextStyle(color: AppColor.darkGrey),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(
                child: Icon(
                  Icons.link,
                  size: 14,
                  color: Colors.grey,
                ),
              ),
              SizedBox(width: 6),
              InkWell(
                child: Text(
                  (user.dob),
                  style: TextStyle(color: AppColor.darkGrey),
                ),
              ),
            ],
          ),
        ),
        Container(
          alignment: Alignment.center,
        ),
        Container(
          margin: EdgeInsets.only(top: 15, bottom: 20),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                RippleButton(
                  splashColor: TwitterColor.dodgetBlue_50.withAlpha(100),
                  borderRadius: BorderRadius.all(Radius.circular(60)),
                  onPressed: () {
                    if (isMyProfile) {
                      Navigator.pushNamed(context, '/EditProfile');
                    } else {
                      final chatState =
                          Provider.of<ChatState>(context, listen: false);
                      chatState.setChatUser = authstate.profileUserModel;
                      Navigator.pushNamed(
                          context, ''); //edit kosong /ChatScreenPage
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: TwitterColor.white,
                      border: Border.all(
                          color: isMyProfile ? Colors.amber : Colors.amber,
                          width: 1),
                      borderRadius: BorderRadius.circular(20),
                    ),

                    /// If [isMyProfile] is true then Edit profile button will display
                    // Otherwise Follow/Following button will be display
                    child: Text(
                      isMyProfile ? 'Edit Profile' : 'Message',
                      style: TextStyle(
                        color: isMyProfile ? Colors.amber : Colors.amber,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}

class Choice {
  const Choice({this.title, this.icon});

  final IconData icon;
  final String title;
}

const List<Choice> choices = const <Choice>[
  const Choice(title: 'aaa', icon: Icons.directions_car),
  const Choice(title: 'srgsrf', icon: Icons.directions_bike),
  const Choice(title: 'rsgsg', icon: Icons.directions_boat),
  const Choice(title: 'grsgrs', icon: Icons.directions_bus),
  const Choice(title: 'eafdafds', icon: Icons.directions_railway),
];

class ChoiceCard extends StatelessWidget {
  const ChoiceCard({Key key, this.choice}) : super(key: key);

  final Choice choice;

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = Theme.of(context).textTheme.display1;
    return Card(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(choice.icon, size: 128.0, color: textStyle.color),
            Text(choice.title, style: textStyle),
          ],
        ),
      ),
    );
  }
}
