import '../../domain/entities/dingbat.dart';

/// 딩벳 데이터 소스
class DingbatDataSource {
  static List<Dingbat> get _dingbats {
    final List<Dingbat> dingbats = [];
    
    // Sandstone SVG 딩벳 데이터
    final List<Map<String, dynamic>> dingbatData = [
      // Device 관련 딩벳들
      {'file': 'accessibility.svg', 'name': 'Accessibility', 'tags': ['device']},
      {'file': 'ai.svg', 'name': 'AI', 'tags': ['device']},
      {'file': 'appscontents.svg', 'name': 'Apps Contents', 'tags': ['device']},
      {'file': 'aspectratio.svg', 'name': 'Aspect Ratio', 'tags': ['device']},
      {'file': 'auracast.svg', 'name': 'Aura Cast', 'tags': ['device']},
      {'file': 'bluetooth.svg', 'name': 'Bluetooth', 'tags': ['device']},
      {'file': 'browser.svg', 'name': 'Browser', 'tags': ['device']},
      {'file': 'btspeaker.svg', 'name': 'BT Speaker', 'tags': ['device']},
      {'file': 'camera.svg', 'name': 'Camera', 'tags': ['device']},
      {'file': 'cameradis.svg', 'name': 'Camera Disabled', 'tags': ['device']},
      {'file': 'changepassword.svg', 'name': 'Change Password', 'tags': ['device']},
      {'file': 'colorpicker.svg', 'name': 'Color Picker', 'tags': ['device']},
      {'file': 'contrast.svg', 'name': 'Contrast', 'tags': ['device']},
      {'file': 'controller.svg', 'name': 'Controller', 'tags': ['device']},
      {'file': 'demooptions.svg', 'name': 'Demo Options', 'tags': ['device']},
      {'file': 'deviceconnect.svg', 'name': 'Device Connect', 'tags': ['device']},
      {'file': 'dns.svg', 'name': 'DNS', 'tags': ['device']},
      {'file': 'fileppt.svg', 'name': 'PowerPoint File', 'tags': ['device']},
      {'file': 'files.svg', 'name': 'Files', 'tags': ['device']},
      {'file': 'folder.svg', 'name': 'Folder', 'tags': ['device']},
      {'file': 'folderupper.svg', 'name': 'Folder Upper', 'tags': ['device']},
      {'file': 'ftp.svg', 'name': 'FTP', 'tags': ['device']},
      {'file': 'gamepad.svg', 'name': 'Gamepad', 'tags': ['device']},
      {'file': 'gamepaddis.svg', 'name': 'Gamepad Disabled', 'tags': ['device']},
      {'file': 'gear.svg', 'name': 'Gear', 'tags': ['device']},
      {'file': 'googledrive.svg', 'name': 'Google Drive', 'tags': ['device']},
      {'file': 'googlephotos.svg', 'name': 'Google Photos', 'tags': ['device']},
      {'file': 'guide.svg', 'name': 'Guide', 'tags': ['device']},
      {'file': 'headset.svg', 'name': 'Headset', 'tags': ['device']},
      {'file': 'help.svg', 'name': 'Help', 'tags': ['device']},
      {'file': 'home.svg', 'name': 'Home', 'tags': ['device']},
      {'file': 'index.svg', 'name': 'Index', 'tags': ['device']},
      {'file': 'input.svg', 'name': 'Input', 'tags': ['device']},
      {'file': 'keyboard.svg', 'name': 'Keyboard', 'tags': ['device']},
      {'file': 'keymouse.svg', 'name': 'Key Mouse', 'tags': ['device']},
      {'file': 'keymousedis.svg', 'name': 'Key Mouse Disabled', 'tags': ['device']},
      {'file': 'language.svg', 'name': 'Language', 'tags': ['device']},
      {'file': 'light.svg', 'name': 'Light', 'tags': ['device']},
      {'file': 'location.svg', 'name': 'Location', 'tags': ['device']},
      {'file': 'lock.svg', 'name': 'Lock', 'tags': ['device']},
      {'file': 'lockcircle.svg', 'name': 'Lock Circle', 'tags': ['device']},
      {'file': 'mobile.svg', 'name': 'Mobile', 'tags': ['device']},
      {'file': 'moodmode.svg', 'name': 'Mood Mode', 'tags': ['device']},
      {'file': 'mouse.svg', 'name': 'Mouse', 'tags': ['device']},
      {'file': 'mycontents.svg', 'name': 'My Contents', 'tags': ['device']},
      {'file': 'network.svg', 'name': 'Network', 'tags': ['device']},
      {'file': 'pagewidth.svg', 'name': 'Page Width', 'tags': ['device']},
      {'file': 'pcnotconnected.svg', 'name': 'PC Not Connected', 'tags': ['device']},
      {'file': 'picturemode.svg', 'name': 'Picture Mode', 'tags': ['device']},
      {'file': 'pointersize.svg', 'name': 'Pointer Size', 'tags': ['device']},
      {'file': 'pointerspeed.svg', 'name': 'Pointer Speed', 'tags': ['device']},
      {'file': 'popupscale.svg', 'name': 'Popup Scale', 'tags': ['device']},
      {'file': 'power.svg', 'name': 'Power', 'tags': ['device']},
      {'file': 'power_circle.svg', 'name': 'Power Circle', 'tags': ['device']},
      {'file': 'profile.svg', 'name': 'Profile', 'tags': ['device']},
      {'file': 'profilecheck.svg', 'name': 'Profile Check', 'tags': ['device']},
      {'file': 'r2rappcall.svg', 'name': 'R2R App Call', 'tags': ['device']},
      {'file': 'router.svg', 'name': 'Router', 'tags': ['device']},
      {'file': 'scheduler.svg', 'name': 'Scheduler', 'tags': ['device']},
      {'file': 'screenpower.svg', 'name': 'Screen Power', 'tags': ['device']},
      {'file': 'shopping.svg', 'name': 'Shopping', 'tags': ['device']},
      {'file': 'smartfunction.svg', 'name': 'Smart Function', 'tags': ['device']},
      {'file': 'spanner.svg', 'name': 'Spanner', 'tags': ['device']},
      {'file': 'speaker.svg', 'name': 'Speaker', 'tags': ['device']},
      {'file': 'speakerbass.svg', 'name': 'Speaker Bass Boost', 'tags': ['device']},
      {'file': 'speakercenter.svg', 'name': 'Speaker Center', 'tags': ['device']},
      {'file': 'speakersurround.svg', 'name': 'Speaker Surround', 'tags': ['device']},
      {'file': 'support.svg', 'name': 'Support', 'tags': ['device']},
      {'file': 'textinput.svg', 'name': 'Text Input', 'tags': ['device']},
      {'file': 'timer.svg', 'name': 'Timer', 'tags': ['device']},
      {'file': 'transponder.svg', 'name': 'Transponder', 'tags': ['device']},
      {'file': 'trashlock.svg', 'name': 'Trash Lock', 'tags': ['device']},
      {'file': 'unlockcircle.svg', 'name': 'Unlock Circle', 'tags': ['device']},
      {'file': 'usb.svg', 'name': 'USB', 'tags': ['device']},
      {'file': 'wallpaper.svg', 'name': 'Wallpaper', 'tags': ['device']},
      {'file': 'wifi1.svg', 'name': 'WiFi 1', 'tags': ['device']},
      {'file': 'wifi15g.svg', 'name': 'WiFi 1.5G', 'tags': ['device']},
      {'file': 'wifi2.svg', 'name': 'WiFi 2', 'tags': ['device']},
      {'file': 'wifi25g.svg', 'name': 'WiFi 2.5G', 'tags': ['device']},
      {'file': 'wifi3.svg', 'name': 'WiFi 3', 'tags': ['device']},
      {'file': 'wifi35g.svg', 'name': 'WiFi 3.5G', 'tags': ['device']},
      {'file': 'wifi4.svg', 'name': 'WiFi 4', 'tags': ['device']},
      {'file': 'wifi45g.svg', 'name': 'WiFi 4.5G', 'tags': ['device']},
      {'file': 'wifilock1.svg', 'name': 'WiFi Lock 1', 'tags': ['device']},
      {'file': 'wifilock15g.svg', 'name': 'WiFi Lock 1.5G', 'tags': ['device']},
      {'file': 'wifilock2.svg', 'name': 'WiFi Lock 2', 'tags': ['device']},
      {'file': 'wifilock25g.svg', 'name': 'WiFi Lock 2.5G', 'tags': ['device']},
      {'file': 'wifilock3.svg', 'name': 'WiFi Lock 3', 'tags': ['device']},
      {'file': 'wifilock35g.svg', 'name': 'WiFi Lock 3.5G', 'tags': ['device']},
      {'file': 'wifilock4.svg', 'name': 'WiFi Lock 4', 'tags': ['device']},
      {'file': 'wifilock45g.svg', 'name': 'WiFi Lock 4.5G', 'tags': ['device']},
      {'file': 'wisa.svg', 'name': 'WISA', 'tags': ['device']},

      // Control 관련 딩벳들
      {'file': 'arrowcurveright.svg', 'name': 'Arrow Curve Right', 'tags': ['control']},
      {'file': 'arrowhookleft.svg', 'name': 'Arrow Hook Left', 'tags': ['control']},
      {'file': 'arrowhookright.svg', 'name': 'Arrow Hook Right', 'tags': ['control']},
      {'file': 'arrowlargedown.svg', 'name': 'Arrow Large Down', 'tags': ['control']},
      {'file': 'arrowlargeleft.svg', 'name': 'Arrow Large Left', 'tags': ['control']},
      {'file': 'arrowlargeright.svg', 'name': 'Arrow Large Right', 'tags': ['control']},
      {'file': 'arrowlargeup.svg', 'name': 'Arrow Large Up', 'tags': ['control']},
      {'file': 'arrowrightskip.svg', 'name': 'Arrow Right Skip', 'tags': ['control']},
      {'file': 'arrowsmalldown.svg', 'name': 'Arrow Small Down', 'tags': ['control']},
      {'file': 'arrowsmallleft.svg', 'name': 'Arrow Small Left', 'tags': ['control']},
      {'file': 'arrowsmallright.svg', 'name': 'Arrow Small Right', 'tags': ['control']},
      {'file': 'arrowsmallup.svg', 'name': 'Arrow Small Up', 'tags': ['control']},
      {'file': 'arrowup.svg', 'name': 'Arrow Up', 'tags': ['control']},
      {'file': 'arrowupdown.svg', 'name': 'Arrow Up Down', 'tags': ['control']},
      {'file': 'arrowuphollow.svg', 'name': 'Arrow Up Hollow', 'tags': ['control']},
      {'file': 'arrowupwhite.svg', 'name': 'Arrow Up White', 'tags': ['control']},
      {'file': 'backspace.svg', 'name': 'Backspace', 'tags': ['control']},
      {'file': 'backsward.svg', 'name': 'Backward', 'tags': ['control']},
      {'file': 'calibration.svg', 'name': 'Calibration', 'tags': ['control']},
      {'file': 'channel.svg', 'name': 'Channel', 'tags': ['control']},
      {'file': 'channelscheduling.svg', 'name': 'Channel Scheduling', 'tags': ['control']},
      {'file': 'chdown.svg', 'name': 'Channel Down', 'tags': ['control']},
      {'file': 'chup.svg', 'name': 'Channel Up', 'tags': ['control']},
      {'file': 'closex.svg', 'name': 'Close', 'tags': ['control']},
      {'file': 'create.svg', 'name': 'Create', 'tags': ['control']},
      {'file': 'download.svg', 'name': 'Download', 'tags': ['control']},
      {'file': 'edit.svg', 'name': 'Edit', 'tags': ['control']},
      {'file': 'eject.svg', 'name': 'Eject', 'tags': ['control']},
      {'file': 'eraser.svg', 'name': 'Eraser', 'tags': ['control']},
      {'file': 'exit.svg', 'name': 'Exit', 'tags': ['control']},
      {'file': 'exitfullscreen.svg', 'name': 'Exit Fullscreen', 'tags': ['control']},
      {'file': 'fifteenbackward.svg', 'name': '15 Seconds Backward', 'tags': ['control']},
      {'file': 'fifteenforward.svg', 'name': '15 Seconds Forward', 'tags': ['control']},
      {'file': 'forward.svg', 'name': 'Forward', 'tags': ['control']},
      {'file': 'fullscreen.svg', 'name': 'Fullscreen', 'tags': ['control']},
      {'file': 'hide.svg', 'name': 'Hide', 'tags': ['control']},
      {'file': 'input.svg', 'name': 'Input', 'tags': ['control']},
      {'file': 'jumpbackward.svg', 'name': 'Jump Backward', 'tags': ['control']},
      {'file': 'jumpbackward10.svg', 'name': 'Jump Backward 10', 'tags': ['control']},
      {'file': 'jumpforward.svg', 'name': 'Jump Forward', 'tags': ['control']},
      {'file': 'jumpforward10.svg', 'name': 'Jump Forward 10', 'tags': ['control']},
      {'file': 'magnify.svg', 'name': 'Magnify', 'tags': ['control']},
      {'file': 'minus.svg', 'name': 'Minus', 'tags': ['control']},
      {'file': 'move.svg', 'name': 'Move', 'tags': ['control']},
      {'file': 'movecursor.svg', 'name': 'Move Cursor', 'tags': ['control']},
      {'file': 'oneminplay.svg', 'name': 'One Minute Play', 'tags': ['control']},
      {'file': 'oneminrecord.svg', 'name': 'One Minute Record', 'tags': ['control']},
      {'file': 'pause.svg', 'name': 'Pause', 'tags': ['control']},
      {'file': 'pausebackward.svg', 'name': 'Pause Backward', 'tags': ['control']},
      {'file': 'pausecircle.svg', 'name': 'Pause Circle', 'tags': ['control']},
      {'file': 'pauseforward.svg', 'name': 'Pause Forward', 'tags': ['control']},
      {'file': 'pausejumpbackward.svg', 'name': 'Pause Jump Backward', 'tags': ['control']},
      {'file': 'pausejumpforward.svg', 'name': 'Pause Jump Forward', 'tags': ['control']},
      {'file': 'pen.svg', 'name': 'Pen', 'tags': ['control']},
      {'file': 'play.svg', 'name': 'Play', 'tags': ['control']},
      {'file': 'playcircle.svg', 'name': 'Play Circle', 'tags': ['control']},
      {'file': 'playspeed.svg', 'name': 'Play Speed', 'tags': ['control']},
      {'file': 'plus.svg', 'name': 'Plus', 'tags': ['control']},
      {'file': 'quickstart.svg', 'name': 'Quick Start', 'tags': ['control']},
      {'file': 'record.svg', 'name': 'Record', 'tags': ['control']},
      {'file': 'refresh.svg', 'name': 'Refresh', 'tags': ['control']},
      {'file': 'remotecontrol.svg', 'name': 'Remote Control', 'tags': ['control']},
      {'file': 'repeatall.svg', 'name': 'Repeat All', 'tags': ['control']},
      {'file': 'repeatnone.svg', 'name': 'Repeat None', 'tags': ['control']},
      {'file': 'repeatone.svg', 'name': 'Repeat One', 'tags': ['control']},
      {'file': 'replay.svg', 'name': 'Replay', 'tags': ['control']},
      {'file': 'rotate.svg', 'name': 'Rotate', 'tags': ['control']},
      {'file': 'share.svg', 'name': 'Share', 'tags': ['control']},
      {'file': 'show.svg', 'name': 'Show', 'tags': ['control']},
      {'file': 'skip.svg', 'name': 'Skip', 'tags': ['control']},
      {'file': 'stop.svg', 'name': 'Stop', 'tags': ['control']},
      {'file': 'trash.svg', 'name': 'Trash', 'tags': ['control']},
      {'file': 'triangledown.svg', 'name': 'Triangle Down', 'tags': ['control']},
      {'file': 'triangleleft.svg', 'name': 'Triangle Left', 'tags': ['control']},
      {'file': 'trianglelefthollow.svg', 'name': 'Triangle Left Hollow', 'tags': ['control']},
      {'file': 'triangleleftwhite.svg', 'name': 'Triangle Left White', 'tags': ['control']},
      {'file': 'triangleright.svg', 'name': 'Triangle Right', 'tags': ['control']},
      {'file': 'trianglerighthollow.svg', 'name': 'Triangle Right Hollow', 'tags': ['control']},
      {'file': 'trianglerightwhite.svg', 'name': 'Triangle Right White', 'tags': ['control']},
      {'file': 'triangleup.svg', 'name': 'Triangle Up', 'tags': ['control']},
      {'file': 'zoom.svg', 'name': 'Zoom', 'tags': ['control']},
      {'file': 'zoomin.svg', 'name': 'Zoom In', 'tags': ['control']},
      {'file': 'zoomout.svg', 'name': 'Zoom Out', 'tags': ['control']},

      // Media 관련 딩벳들
      {'file': 'bgm.svg', 'name': 'BGM', 'tags': ['media']},
      {'file': 'bgmoff.svg', 'name': 'BGM Off', 'tags': ['media']},
      {'file': 'channel.svg', 'name': 'Channel', 'tags': ['media']},
      {'file': 'closecaption.svg', 'name': 'Closed Caption', 'tags': ['media']},
      {'file': 'dlna.svg', 'name': 'DLNA', 'tags': ['media']},
      {'file': 'liveplay.svg', 'name': 'Live Play', 'tags': ['media']},
      {'file': 'liveplayoff.svg', 'name': 'Live Play Off', 'tags': ['media']},
      {'file': 'liveplayon.svg', 'name': 'Live Play On', 'tags': ['media']},
      {'file': 'liverecord.svg', 'name': 'Live Record', 'tags': ['media']},
      {'file': 'lyrics.svg', 'name': 'Lyrics', 'tags': ['media']},
      {'file': 'mediaplayer.svg', 'name': 'Media Player', 'tags': ['media']},
      {'file': 'mediaserver.svg', 'name': 'Media Server', 'tags': ['media']},
      {'file': 'miniplayer.svg', 'name': 'Mini Player', 'tags': ['media']},
      {'file': 'movies.svg', 'name': 'Movies', 'tags': ['media']},
      {'file': 'music.svg', 'name': 'Music', 'tags': ['media']},
      {'file': 'musicsrc.svg', 'name': 'Music Source', 'tags': ['media']},
      {'file': 'mute.svg', 'name': 'Mute', 'tags': ['media']},
      {'file': 'nowplaying.svg', 'name': 'Now Playing', 'tags': ['media']},
      {'file': 'onnow.svg', 'name': 'On Now', 'tags': ['media']},
      {'file': 'ostsearch.svg', 'name': 'OST Search', 'tags': ['media']},
      {'file': 'picture.svg', 'name': 'Picture', 'tags': ['media']},
      {'file': 'recording.svg', 'name': 'Recording', 'tags': ['media']},
      {'file': 'samples.svg', 'name': 'Samples', 'tags': ['media']},
      {'file': 'sound.svg', 'name': 'Sound', 'tags': ['media']},
      {'file': 'soundmode.svg', 'name': 'Sound Mode', 'tags': ['media']},
      {'file': 'soundout.svg', 'name': 'Sound Out', 'tags': ['media']},
      {'file': 'subtitle.svg', 'name': 'Subtitle', 'tags': ['media']},
      {'file': 'subtitlecn.svg', 'name': 'Subtitle Chinese', 'tags': ['media']},
      {'file': 'subtitlekr.svg', 'name': 'Subtitle Korean', 'tags': ['media']},
      {'file': 'trailer.svg', 'name': 'Trailer', 'tags': ['media']},
      {'file': 'tvguidefvp.svg', 'name': 'TV Guide FVP', 'tags': ['media']},
      {'file': 'voice.svg', 'name': 'Voice', 'tags': ['media']},
      {'file': 'voiced.svg', 'name': 'Voiced', 'tags': ['media']},
      {'file': 'view360.svg', 'name': '360 View', 'tags': ['media']},
      {'file': 'wowcast.svg', 'name': 'Wow Cast', 'tags': ['media']},
      {'file': 'youtube.svg', 'name': 'YouTube', 'tags': ['media']},

      // Symbol 관련 딩벳들
      {'file': 'alert01.svg', 'name': 'Alert 01', 'tags': ['symbol']},
      {'file': 'alert02.svg', 'name': 'Alert 02', 'tags': ['symbol']},
      {'file': 'bookmark.svg', 'name': 'Bookmark', 'tags': ['symbol']},
      {'file': 'check.svg', 'name': 'Check', 'tags': ['symbol']},
      {'file': 'checker.svg', 'name': 'Checker', 'tags': ['symbol']},
      {'file': 'circle.svg', 'name': 'Circle', 'tags': ['symbol']},
      {'file': 'ear.svg', 'name': 'Ear', 'tags': ['symbol']},
      {'file': 'ellipsis.svg', 'name': 'Ellipsis', 'tags': ['symbol']},
      {'file': 'exclamation.svg', 'name': 'Exclamation', 'tags': ['symbol']},
      {'file': 'hand.svg', 'name': 'Hand', 'tags': ['symbol']},
      {'file': 'heart.svg', 'name': 'Heart', 'tags': ['symbol']},
      {'file': 'heartadd.svg', 'name': 'Add to Heart', 'tags': ['symbol']},
      {'file': 'heartblack.svg', 'name': 'Heart Black', 'tags': ['symbol']},
      {'file': 'hearthollow.svg', 'name': 'Heart Hollow', 'tags': ['symbol']},
      {'file': 'heartlist.svg', 'name': 'Heart List', 'tags': ['symbol']},
      {'file': 'info.svg', 'name': 'Info', 'tags': ['symbol']},
      {'file': 'link.svg', 'name': 'Link', 'tags': ['symbol']},
      {'file': 'list.svg', 'name': 'List', 'tags': ['symbol']},
      {'file': 'newfeature.svg', 'name': 'New Feature', 'tags': ['symbol']},
      {'file': 'notification.svg', 'name': 'Notification', 'tags': ['symbol']},
      {'file': 'seemore.svg', 'name': 'See More', 'tags': ['symbol']},
      {'file': 'selected.svg', 'name': 'Selected', 'tags': ['symbol']},
      {'file': 'sketch.svg', 'name': 'Sketch', 'tags': ['symbol']},
      {'file': 'space.svg', 'name': 'Space', 'tags': ['symbol']},
      {'file': 'star.svg', 'name': 'Star', 'tags': ['symbol']},
      {'file': 'stargroup.svg', 'name': 'Star Group', 'tags': ['symbol']},
      {'file': 'starhalf.svg', 'name': 'Star Half', 'tags': ['symbol']},
      {'file': 'starhollow.svg', 'name': 'Star Hollow', 'tags': ['symbol']},
      {'file': 'verticalellipsis.svg', 'name': 'Vertical Ellipsis', 'tags': ['symbol']},

      // Sports 관련 딩벳들 (symbol 카테고리에 포함)
      {'file': 'baseball.svg', 'name': 'Baseball', 'tags': ['symbol']},
      {'file': 'basketball.svg', 'name': 'Basketball', 'tags': ['symbol']},
      {'file': 'cricket.svg', 'name': 'Cricket', 'tags': ['symbol']},
      {'file': 'football.svg', 'name': 'Football', 'tags': ['symbol']},
      {'file': 'golf.svg', 'name': 'Golf', 'tags': ['symbol']},
      {'file': 'hockey.svg', 'name': 'Hockey', 'tags': ['symbol']},
      {'file': 'soccer.svg', 'name': 'Soccer', 'tags': ['symbol']},
      {'file': 'volleyball.svg', 'name': 'Volleyball', 'tags': ['symbol']},
    ];
    
    // 딩벳 데이터를 Dingbat 객체로 변환
    for (final data in dingbatData) {
      final fileName = data['file'] as String;
      final name = fileName.replaceAll('.svg', '');
      final tags = List<String>.from(data['tags'] as List);
      
      // 파일명에서 확장자 제거하여 ID 생성
      final id = fileName.replaceAll('.svg', '');
      
      // asset 경로 생성
      final assetPath = 'assets/dingbats/$fileName';
      
      // Unicode 설정 (기본값)
      const unicode = '🔹';
      
      dingbats.add(Dingbat(
        id: id,
        name: name,
        assetPath: assetPath,
        tags: tags,
        unicode: unicode,
      ));
    }
    
    return dingbats;
  }

  /// 모든 딩벳 목록을 반환
  List<Dingbat> getAllDingbats() {
    return List.unmodifiable(_dingbats);
  }

  /// 특정 태그로 필터링된 딩벳 목록을 반환
  List<Dingbat> getDingbatsByTag(String tag) {
    return _dingbats.where((dingbat) => dingbat.hasTag(tag)).toList();
  }

  /// 여러 태그로 필터링된 딩벳 목록을 반환
  List<Dingbat> getDingbatsByTags(List<String> tags) {
    return _dingbats.where((dingbat) => dingbat.hasAllTags(tags)).toList();
  }

  /// 사용 가능한 모든 태그 목록을 반환
  List<String> getAllTags() {
    final Set<String> tags = {};
    for (final dingbat in _dingbats) {
      tags.addAll(dingbat.tags);
    }
    return tags.toList()..sort();
  }
} 