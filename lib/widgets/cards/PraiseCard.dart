import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:extended_text/extended_text.dart';
import 'package:extended_image/extended_image.dart';

import 'package:OpenJMU/api/Api.dart';
import 'package:OpenJMU/model/Bean.dart';
import 'package:OpenJMU/model/SpecialText.dart';
import 'package:OpenJMU/pages/SearchPage.dart';
import 'package:OpenJMU/pages/UserPage.dart';
import 'package:OpenJMU/pages/PostDetailPage.dart';
import 'package:OpenJMU/utils/UserUtils.dart';
import 'package:OpenJMU/widgets/CommonWebPage.dart';
import 'package:OpenJMU/widgets/image/ImageViewer.dart';

class PraiseCard extends StatelessWidget {
  final Praise praise;

  PraiseCard(this.praise, {Key key}) : super(key: key);

  final TextStyle titleTextStyle = TextStyle(fontSize: 18.0);
  final TextStyle subtitleStyle = TextStyle(color: Colors.grey, fontSize: 14.0);
  final TextStyle rootTopicTextStyle = TextStyle(fontSize: 14.0);
  final TextStyle rootTopicMentionStyle = TextStyle(color: Colors.blue, fontSize: 14.0);
  final Color subIconColor = Colors.grey;

  GestureDetector getCommentAvatar(context, praise) {
    return GestureDetector(
        child: Container(
          width: 40.0,
          height: 40.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFECECEC),
            image: DecorationImage(
                image: UserUtils.getAvatarProvider(praise.uid),
                fit: BoxFit.cover
            ),
          ),
        ),
        onTap: () {
          return UserPage.jump(context, praise.uid);
        }
    );
  }

  Text getCommentNickname(praise) {
    return Text(
      praise.nickname ?? praise.uid,
      style: titleTextStyle,
      textAlign: TextAlign.left,
    );
  }

  Row getCommentInfo(praise) {
    String _praiseTime = praise.praiseTime;
    DateTime now = DateTime.now();
    if (int.parse(_praiseTime.substring(0, 4)) == now.year) {
      _praiseTime = _praiseTime.substring(5, 16);
    }
    if (
    int.parse(_praiseTime.substring(0, 2)) == now.month
        &&
        int.parse(_praiseTime.substring(3, 5)) == now.day
    ) {
      _praiseTime = "${_praiseTime.substring(5, 11)}";
    }
    return Row(
        children: <Widget>[
          Icon(
              Icons.access_time,
              color: Colors.grey,
              size: 12.0
          ),
          Text(
              " $_praiseTime",
              style: subtitleStyle
          ),
        ]
    );
  }

  Widget getCommentContent(context, praise) {
    return Row(
        children: <Widget>[
          Expanded(
              child: Container(
                  margin: EdgeInsets.only(bottom: 8.0),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text("赞了这条微博"),
                        getRootContent(context, praise)
                      ]
                  )
              )
          )
        ]
    );
  }

  Widget getRootContent(context, praise) {
    Post _post = PostAPI.createPost(praise.post);
    String topic = "<M ${_post.uid}>@${_post.nickname}<\/M>: ";
    topic += _post.content;
    return Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.only(top: 8.0),
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: BorderRadius.circular(5.0)
        ),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              getExtendedText(context, topic),
            ]
        )
    );
  }

  Widget getExtendedText(context, content) {
    return ExtendedText(
      content != null ? "$content " : null,
      style: TextStyle(fontSize: 16.0),
      onSpecialTextTap: (dynamic data) {
        String text = data['content'];
        if (text.startsWith("#")) {
          return SearchPage.search(context, text.substring(1, text.length-1));
        } else if (text.startsWith("@")) {
          return UserPage.jump(context, data['uid']);
        } else if (text.startsWith("https://wb.jmu.edu.cn")) {
          return CommonWebPage.jump(context, text, "网页链接");
        }
      },
      specialTextSpanBuilder: StackSpecialTextSpanBuilder(),
        overflow: ExtendedTextOverflow.ellipsis,
        maxLines: 7,
    );
  }

  Widget getImages(context, data) {
    if (data != null) {
      List<Widget> imagesWidget = [];
      for (var index = 0; index < data.length; index++) {
        String imageUrl = data[index]['image_original'];
        String urlInsecure = imageUrl.replaceAllMapped(RegExp(r"https://"), (match) => "http://");
        imagesWidget.add(
            GestureDetector(
                onTap: () {
                  Navigator.of(context).push(CupertinoPageRoute(builder: (_) {
                    return ImageViewer(
                      index,
                      data.map<ImageBean>((f) {
                        String _httpsUrl = f['image_original'];
                        String url = _httpsUrl.replaceAllMapped(RegExp(r"https://"), (match) => "http://");
                        return ImageBean(url, this.praise.postId);
                      }).toList(),
                    );
                  }));
                },
                child: Hero(
                    tag: "$urlInsecure${index.toString()}${this.praise.postId.toString()}",
                    child: ExtendedImage.network(
                      urlInsecure,
                      fit: BoxFit.cover,
                      cache: true,
                    )
                )
            )
        );
      }
      int itemCount = 3;
      if (data.length == 1) {
        return Container(
            padding: EdgeInsets.only(top: 8.0),
            child: imagesWidget[0]
        );
      } else if (data.length < 3) {
        itemCount = data.length;
      }
      return Container(
          child: GridView.count(
              padding: EdgeInsets.only(top: 8.0),
              shrinkWrap: true,
              primary: false,
              mainAxisSpacing: 8.0,
              crossAxisCount: itemCount,
              crossAxisSpacing: 8.0,
              children: imagesWidget
          )
      );
    } else {
      return Container();
    }
  }


  @override
  Widget build(BuildContext context) {
    List<Widget> _widgets = [];
    _widgets = [
      ListTile(
        leading: getCommentAvatar(context, this.praise),
        title: getCommentNickname(this.praise),
        subtitle: getCommentInfo(this.praise),
      ),
      getCommentContent(context, this.praise),
    ];
    Post _post = PostAPI.createPost(this.praise.post);
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
          return PostDetailPage(_post, beforeContext: context);
        }));
      },
      child: Container(
        child: Card(
            margin: EdgeInsets.symmetric(vertical: 4.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _widgets,
            ),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero)
        ),
      )
    );
  }

}


class PraiseCardInPost extends StatelessWidget {
  final List<Praise> praises;

  PraiseCardInPost(this.praises, {Key key}) : super(key: key);

  GestureDetector getPostAvatar(context, praise) {
    return GestureDetector(
        child: Container(
          width: 40.0,
          height: 40.0,
          margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFECECEC),
            image: DecorationImage(
                image: UserUtils.getAvatarProvider(praise.uid),
                fit: BoxFit.cover
            ),
          ),
        ),
        onTap: () {
          return UserPage.jump(context, praise.uid);
        }
    );
  }

  Text getPostNickname(context, praise) {
    return Text(
        praise.nickname,
        style: TextStyle(
            color: Theme.of(context).textTheme.body1.color,
            fontSize: 16.0
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Theme.of(context).cardColor,
        padding: EdgeInsets.zero,
        child: this.praises.length > 0
            ? ListView.separated(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            separatorBuilder: (context, index) => Container(
              color: Theme.of(context).dividerColor,
              height: 1.0,
            ),
            itemCount: this.praises.length,
            itemBuilder: (context, index) => Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                getPostAvatar(context, this.praises[index]),
                Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        getPostNickname(context, this.praises[index]),
                      ],
                    )
                )
              ],
            )
        )
            : Container(
            height: 120.0,
            child: Center(
                child: Text(
                    "暂无内容",
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 18.0
                    )
                )
            )
        )
    );
  }

}
