import '../../domain/entities/dingbat.dart';

/// 딩벳 데이터 소스
class DingbatDataSource {
  static List<Dingbat> get _dingbats {
    final List<Dingbat> dingbats = [];
    
    // 모든 딩벳 파일들을 동적으로 생성
    final List<Map<String, dynamic>> dingbatData = [
      // 기본 딩벳들
      {'file': 'accessibility.svg', 'name': 'Accessibility', 'tags': ['device']},
      {'file': 'appscontents.svg', 'name': 'Apps Contents', 'tags': ['device']},
      {'file': 'arrow_curve_right.svg', 'name': 'Arrow Curve Right', 'tags': ['control']},
      {'file': 'arrowrightskip.svg', 'name': 'Arrow Right Skip', 'tags': ['control']},
      {'file': 'arrowup.svg', 'name': 'Arrow Up', 'tags': ['control']},
      {'file': 'arrowupdown.svg', 'name': 'Arrow Up Down', 'tags': ['control']},
      {'file': 'aspectratio.svg', 'name': 'Aspect Ratio', 'tags': ['device']},
      {'file': 'auracast.svg', 'name': 'Aura Cast', 'tags': ['media']},
      {'file': 'baseball.svg', 'name': 'Baseball', 'tags': ['sports']},
      {'file': 'basketball.svg', 'name': 'Basketball', 'tags': ['sports']},
      {'file': 'bgm.svg', 'name': 'BGM', 'tags': ['media']},
      {'file': 'bgmoff.svg', 'name': 'BGM Off', 'tags': ['media']},
      {'file': 'bluetooth.svg', 'name': 'Bluetooth', 'tags': ['device']},
      {'file': 'bookmark.svg', 'name': 'Bookmark', 'tags': ['symbol']},
      {'file': 'browser.svg', 'name': 'Browser', 'tags': ['device']},
      {'file': 'bt_speaker.svg', 'name': 'BT Speaker', 'tags': ['device']},
      {'file': 'camera.svg', 'name': 'Camera', 'tags': ['device']},
      {'file': 'camera_dis.svg', 'name': 'Camera Disabled', 'tags': ['device']},
      {'file': 'caret_down_large.svg', 'name': 'Caret Down Large', 'tags': ['control']},
      {'file': 'caret_down_small.svg', 'name': 'Caret Down Small', 'tags': ['control']},
      {'file': 'caret_left_large.svg', 'name': 'Caret Left Large', 'tags': ['control']},
      {'file': 'caret_left_small.svg', 'name': 'Caret Left Small', 'tags': ['control']},
      {'file': 'caret_right_large.svg', 'name': 'Caret Right Large', 'tags': ['control']},
      {'file': 'caret_right_small.svg', 'name': 'Caret Right Small', 'tags': ['control']},
      {'file': 'caret_up_large.svg', 'name': 'Caret Up Large', 'tags': ['control']},
      {'file': 'caret_up_small.svg', 'name': 'Caret Up Small', 'tags': ['control']},
      {'file': 'changepassword.svg', 'name': 'Change Password', 'tags': ['device']},
      {'file': 'channel.svg', 'name': 'Channel', 'tags': ['media']},
      {'file': 'channelscheduling.svg', 'name': 'Channel Scheduling', 'tags': ['media']},
      {'file': 'chdown.svg', 'name': 'Channel Down', 'tags': ['control']},
      {'file': 'checker.svg', 'name': 'Checker', 'tags': ['symbol']},
      {'file': 'checkmark.svg', 'name': 'Checkmark', 'tags': ['symbol']},
      {'file': 'chup.svg', 'name': 'Channel Up', 'tags': ['control']},
      {'file': 'close_x.svg', 'name': 'Close', 'tags': ['control']},
      {'file': 'closedcaption.svg', 'name': 'Closed Caption', 'tags': ['media']},
      {'file': 'colorpicker.svg', 'name': 'Color Picker', 'tags': ['device']},
      {'file': 'contrast.svg', 'name': 'Contrast', 'tags': ['device']},
      {'file': 'controller.svg', 'name': 'Controller', 'tags': ['device']},
      {'file': 'create.svg', 'name': 'Create', 'tags': ['control']},
      {'file': 'cricket.svg', 'name': 'Cricket', 'tags': ['sports']},
      {'file': 'demo_options.svg', 'name': 'Demo Options', 'tags': ['device']},
      {'file': 'deviceconnect.svg', 'name': 'Device Connect', 'tags': ['device']},
      {'file': 'dlna.svg', 'name': 'DLNA', 'tags': ['media']},
      {'file': 'dns.svg', 'name': 'DNS', 'tags': ['device']},
      {'file': 'download.svg', 'name': 'Download', 'tags': ['control']},
      {'file': 'ear.svg', 'name': 'Ear', 'tags': ['symbol']},
      {'file': 'edit.svg', 'name': 'Edit', 'tags': ['control']},
      {'file': 'eject.svg', 'name': 'Eject', 'tags': ['control']},
      {'file': 'exclamation.svg', 'name': 'Exclamation', 'tags': ['symbol']},
      {'file': 'exit.svg', 'name': 'Exit', 'tags': ['control']},
      {'file': 'fifteenbackward.svg', 'name': '15 Seconds Backward', 'tags': ['control']},
      {'file': 'fifteenforward.svg', 'name': '15 Seconds Forward', 'tags': ['control']},
      {'file': 'file_ppt.svg', 'name': 'PowerPoint File', 'tags': ['device']},
      {'file': 'files.svg', 'name': 'Files', 'tags': ['device']},
      {'file': 'folder.svg', 'name': 'Folder', 'tags': ['device']},
      {'file': 'folder_upper.svg', 'name': 'Folder Upper', 'tags': ['device']},
      {'file': 'football.svg', 'name': 'Football', 'tags': ['sports']},
      {'file': 'forward.svg', 'name': 'Forward', 'tags': ['control']},
      {'file': 'ftp.svg', 'name': 'FTP', 'tags': ['device']},
      {'file': 'gamepad.svg', 'name': 'Gamepad', 'tags': ['device']},
      {'file': 'gamepad_dis.svg', 'name': 'Gamepad Disabled', 'tags': ['device']},
      {'file': 'gear.svg', 'name': 'Gear', 'tags': ['device']},
      {'file': 'gear_large.svg', 'name': 'Gear Large', 'tags': ['device']},
      {'file': 'golf.svg', 'name': 'Golf', 'tags': ['sports']},
      {'file': 'googledrive.svg', 'name': 'Google Drive', 'tags': ['device']},
      {'file': 'googlephotos.svg', 'name': 'Google Photos', 'tags': ['device']},
      {'file': 'guide.svg', 'name': 'Guide', 'tags': ['device']},
      {'file': 'hand.svg', 'name': 'Hand', 'tags': ['symbol']},
      {'file': 'headset.svg', 'name': 'Headset', 'tags': ['device']},
      {'file': 'heart.svg', 'name': 'Heart', 'tags': ['symbol']},
      {'file': 'heartadd.svg', 'name': 'Add to Heart', 'tags': ['symbol']},
      {'file': 'heartlist.svg', 'name': 'Heart List', 'tags': ['symbol']},
      {'file': 'help.svg', 'name': 'Help', 'tags': ['device']},
      {'file': 'hide.svg', 'name': 'Hide', 'tags': ['control']},
      {'file': 'hockey.svg', 'name': 'Hockey', 'tags': ['sports']},
      {'file': 'home.svg', 'name': 'Home', 'tags': ['device']},
      {'file': 'home_large.svg', 'name': 'Home Large', 'tags': ['device']},
      {'file': 'hyphen.svg', 'name': 'Hyphen', 'tags': ['symbol']},
      {'file': 'index.svg', 'name': 'Index', 'tags': ['device']},
      {'file': 'indicator_begin.svg', 'name': 'Indicator Begin', 'tags': ['symbol']},
      {'file': 'indicator_end.svg', 'name': 'Indicator End', 'tags': ['symbol']},
      {'file': 'info.svg', 'name': 'Info', 'tags': ['symbol']},
      {'file': 'input.svg', 'name': 'Input', 'tags': ['device']},
      {'file': 'jumpbackward_10.svg', 'name': 'Jump Backward 10', 'tags': ['control']},
      {'file': 'jumpforward_10.svg', 'name': 'Jump Forward 10', 'tags': ['control']},
      {'file': 'key_mouse.svg', 'name': 'Key Mouse', 'tags': ['device']},
      {'file': 'key_mouse_dis.svg', 'name': 'Key Mouse Disabled', 'tags': ['device']},
      {'file': 'keyboard.svg', 'name': 'Keyboard', 'tags': ['device']},
      {'file': 'language.svg', 'name': 'Language', 'tags': ['device']},
      {'file': 'light.svg', 'name': 'Light', 'tags': ['device']},
      {'file': 'link.svg', 'name': 'Link', 'tags': ['symbol']},
      {'file': 'list_simple.svg', 'name': 'Simple List', 'tags': ['symbol']},
      {'file': 'live_play.svg', 'name': 'Live Play', 'tags': ['media']},
      {'file': 'live_record.svg', 'name': 'Live Record', 'tags': ['media']},
      {'file': 'liveplayoff.svg', 'name': 'Live Play Off', 'tags': ['media']},
      {'file': 'liveplayon.svg', 'name': 'Live Play On', 'tags': ['media']},
      {'file': 'location.svg', 'name': 'Location', 'tags': ['device']},
      {'file': 'lock.svg', 'name': 'Lock', 'tags': ['device']},
      {'file': 'lock_circle.svg', 'name': 'Lock Circle', 'tags': ['device']},
      {'file': 'logout.svg', 'name': 'Logout', 'tags': ['control']},
      {'file': 'lyrics.svg', 'name': 'Lyrics', 'tags': ['media']},
      {'file': 'magnify.svg', 'name': 'Magnify', 'tags': ['control']},
      {'file': 'maximize.svg', 'name': 'Maximize', 'tags': ['control']},
      {'file': 'midline_ellipsis.svg', 'name': 'Midline Ellipsis', 'tags': ['symbol']},
      {'file': 'minimize.svg', 'name': 'Minimize', 'tags': ['control']},
      {'file': 'miniplayer.svg', 'name': 'Mini Player', 'tags': ['media']},
      {'file': 'mobile.svg', 'name': 'Mobile', 'tags': ['device']},
      {'file': 'moodmode.svg', 'name': 'Mood Mode', 'tags': ['device']},
      {'file': 'mouse.svg', 'name': 'Mouse', 'tags': ['device']},
      {'file': 'move.svg', 'name': 'Move', 'tags': ['control']},
      {'file': 'move_cursor.svg', 'name': 'Move Cursor', 'tags': ['control']},
      {'file': 'movies.svg', 'name': 'Movies', 'tags': ['media']},
      {'file': 'music.svg', 'name': 'Music', 'tags': ['media']},
      {'file': 'musicsrc.svg', 'name': 'Music Source', 'tags': ['media']},
      {'file': 'mute.svg', 'name': 'Mute', 'tags': ['media']},
      {'file': 'mycontents.svg', 'name': 'My Contents', 'tags': ['device']},
      {'file': 'network.svg', 'name': 'Network', 'tags': ['device']},
      {'file': 'new_feature.svg', 'name': 'New Feature', 'tags': ['symbol']},
      {'file': 'now_playing.svg', 'name': 'Now Playing', 'tags': ['media']},
      {'file': 'oneminplay.svg', 'name': 'One Minute Play', 'tags': ['control']},
      {'file': 'oneminrecord.svg', 'name': 'One Minute Record', 'tags': ['control']},
      {'file': 'onnow.svg', 'name': 'On Now', 'tags': ['media']},
      {'file': 'ostsearch.svg', 'name': 'OST Search', 'tags': ['media']},
      {'file': 'pagewidth.svg', 'name': 'Page Width', 'tags': ['device']},
      {'file': 'pause.svg', 'name': 'Pause', 'tags': ['control']},
      {'file': 'pause_circle.svg', 'name': 'Pause Circle', 'tags': ['control']},
      {'file': 'pausebackward.svg', 'name': 'Pause Backward', 'tags': ['control']},
      {'file': 'pauseforward.svg', 'name': 'Pause Forward', 'tags': ['control']},
      {'file': 'pausejumpbackward.svg', 'name': 'Pause Jump Backward', 'tags': ['control']},
      {'file': 'pausejumpforward.svg', 'name': 'Pause Jump Forward', 'tags': ['control']},
      {'file': 'pc_not_connected.svg', 'name': 'PC Not Connected', 'tags': ['device']},
      {'file': 'picture.svg', 'name': 'Picture', 'tags': ['media']},
      {'file': 'picturemode.svg', 'name': 'Picture Mode', 'tags': ['device']},
      {'file': 'play.svg', 'name': 'Play', 'tags': ['control']},
      {'file': 'play_circle.svg', 'name': 'Play Circle', 'tags': ['control']},
      {'file': 'playspeed.svg', 'name': 'Play Speed', 'tags': ['control']},
      {'file': 'plus.svg', 'name': 'Plus', 'tags': ['symbol']},
      {'file': 'pointersize.svg', 'name': 'Pointer Size', 'tags': ['device']},
      {'file': 'pointerspeed.svg', 'name': 'Pointer Speed', 'tags': ['device']},
      {'file': 'popupscale.svg', 'name': 'Popup Scale', 'tags': ['device']},
      {'file': 'power.svg', 'name': 'Power', 'tags': ['device']},
      {'file': 'power_circle.svg', 'name': 'Power Circle', 'tags': ['device']},
      {'file': 'profile.svg', 'name': 'Profile', 'tags': ['device']},
      {'file': 'profilecheck.svg', 'name': 'Profile Check', 'tags': ['device']},
      {'file': 'quickstart.svg', 'name': 'Quick Start', 'tags': ['control']},
      {'file': 'r2rappcall.svg', 'name': 'R2R App Call', 'tags': ['device']},
      {'file': 'record.svg', 'name': 'Record', 'tags': ['control']},
      {'file': 'recording.svg', 'name': 'Recording', 'tags': ['media']},
      {'file': 'refresh.svg', 'name': 'Refresh', 'tags': ['control']},
      {'file': 'remotecontrol.svg', 'name': 'Remote Control', 'tags': ['device']},
      {'file': 'repeat_all.svg', 'name': 'Repeat All', 'tags': ['control']},
      {'file': 'repeat_none.svg', 'name': 'Repeat None', 'tags': ['control']},
      {'file': 'repeat_one.svg', 'name': 'Repeat One', 'tags': ['control']},
      {'file': 'replay.svg', 'name': 'Replay', 'tags': ['control']},
      {'file': 'rewind.svg', 'name': 'Rewind', 'tags': ['control']},
      {'file': 'rotate.svg', 'name': 'Rotate', 'tags': ['control']},
      {'file': 'router.svg', 'name': 'Router', 'tags': ['device']},
      {'file': 'samples.svg', 'name': 'Samples', 'tags': ['media']},
      {'file': 'scheduler.svg', 'name': 'Scheduler', 'tags': ['device']},
      {'file': 'screen_power.svg', 'name': 'Screen Power', 'tags': ['device']},
      {'file': 'see_more.svg', 'name': 'See More', 'tags': ['symbol']},
      {'file': 'selected.svg', 'name': 'Selected', 'tags': ['symbol']},
      {'file': 'share.svg', 'name': 'Share', 'tags': ['control']},
      {'file': 'shopping.svg', 'name': 'Shopping', 'tags': ['device']},
      {'file': 'show.svg', 'name': 'Show', 'tags': ['control']},
      {'file': 'shuffle.svg', 'name': 'Shuffle', 'tags': ['control']},
      {'file': 'shuffleon.svg', 'name': 'Shuffle On', 'tags': ['control']},
      {'file': 'sketch.svg', 'name': 'Sketch', 'tags': ['symbol']},
      {'file': 'skip.svg', 'name': 'Skip', 'tags': ['control']},
      {'file': 'smartfunction.svg', 'name': 'Smart Function', 'tags': ['device']},
      {'file': 'soccer.svg', 'name': 'Soccer', 'tags': ['sports']},
      {'file': 'sound.svg', 'name': 'Sound', 'tags': ['media']},
      {'file': 'sound_out.svg', 'name': 'Sound Out', 'tags': ['media']},
      {'file': 'soundmode.svg', 'name': 'Sound Mode', 'tags': ['media']},
      {'file': 'spanner.svg', 'name': 'Spanner', 'tags': ['device']},
      {'file': 'speaker.svg', 'name': 'Speaker', 'tags': ['device']},
      {'file': 'speaker_bassboost.svg', 'name': 'Speaker Bass Boost', 'tags': ['device']},
      {'file': 'speaker_center.svg', 'name': 'Speaker Center', 'tags': ['device']},
      {'file': 'speaker_surround.svg', 'name': 'Speaker Surround', 'tags': ['device']},
      {'file': 'star_empty.svg', 'name': 'Star Empty', 'tags': ['symbol']},
      {'file': 'star_full.svg', 'name': 'Star Full', 'tags': ['symbol']},
      {'file': 'star_group.svg', 'name': 'Star Group', 'tags': ['symbol']},
      {'file': 'star_half.svg', 'name': 'Star Half', 'tags': ['symbol']},
      {'file': 'stop.svg', 'name': 'Stop', 'tags': ['control']},
      {'file': 'subtitle.svg', 'name': 'Subtitle', 'tags': ['media']},
      {'file': 'subtitlecn.svg', 'name': 'Subtitle Chinese', 'tags': ['media']},
      {'file': 'subtitlekr.svg', 'name': 'Subtitle Korean', 'tags': ['media']},
      {'file': 'support.svg', 'name': 'Support', 'tags': ['device']},
      {'file': 'sync_demo.svg', 'name': 'Sync Demo', 'tags': ['device']},
      {'file': 'textinput.svg', 'name': 'Text Input', 'tags': ['device']},
      {'file': 'timer.svg', 'name': 'Timer', 'tags': ['device']},
      {'file': 'trailer.svg', 'name': 'Trailer', 'tags': ['media']},
      {'file': 'transponder.svg', 'name': 'Transponder', 'tags': ['device']},
      {'file': 'trash.svg', 'name': 'Trash', 'tags': ['control']},
      {'file': 'trash_lock.svg', 'name': 'Trash Lock', 'tags': ['device']},
      {'file': 'triagdn.svg', 'name': 'Triangle Down', 'tags': ['control']},
      {'file': 'triagleft.svg', 'name': 'Triangle Left', 'tags': ['control']},
      {'file': 'triagright.svg', 'name': 'Triangle Right', 'tags': ['control']},
      {'file': 'triagup.svg', 'name': 'Triangle Up', 'tags': ['control']},
      {'file': 'tvguide_fvp.svg', 'name': 'TV Guide FVP', 'tags': ['media']},
      {'file': 'uni2408.svg', 'name': 'Backspace', 'tags': ['control']},
      {'file': 'uni2420.svg', 'name': 'Space', 'tags': ['control']},
      {'file': 'uni2661.svg', 'name': 'Heart', 'tags': ['symbol']},
      {'file': 'unlock_circle.svg', 'name': 'Unlock Circle', 'tags': ['device']},
      {'file': 'usb.svg', 'name': 'USB', 'tags': ['device']},
      {'file': 'vertical_ellipsis.svg', 'name': 'Vertical Ellipsis', 'tags': ['symbol']},
      {'file': 'view_360.svg', 'name': '360 View', 'tags': ['media']},
      {'file': 'voice.svg', 'name': 'Voice', 'tags': ['media']},
      {'file': 'voiced.svg', 'name': 'Voiced', 'tags': ['media']},
      {'file': 'volleyball.svg', 'name': 'Volleyball', 'tags': ['sports']},
      {'file': 'wallpaper.svg', 'name': 'Wallpaper', 'tags': ['device']},
      {'file': 'wifi1_5g.svg', 'name': 'WiFi 1.5G', 'tags': ['device']},
      {'file': 'wifi2_5g.svg', 'name': 'WiFi 2.5G', 'tags': ['device']},
      {'file': 'wifi3_5g.svg', 'name': 'WiFi 3.5G', 'tags': ['device']},
      {'file': 'wifi4_5g.svg', 'name': 'WiFi 4.5G', 'tags': ['device']},
      {'file': 'wifilock1_5g.svg', 'name': 'WiFi Lock 1.5G', 'tags': ['device']},
      {'file': 'wifilock2_5g.svg', 'name': 'WiFi Lock 2.5G', 'tags': ['device']},
      {'file': 'wifilock3_5g.svg', 'name': 'WiFi Lock 3.5G', 'tags': ['device']},
      {'file': 'wifilock4_5g.svg', 'name': 'WiFi Lock 4.5G', 'tags': ['device']},
      {'file': 'wisa.svg', 'name': 'WISA', 'tags': ['device']},
      {'file': 'wow_cast.svg', 'name': 'Wow Cast', 'tags': ['media']},
      {'file': 'youtube.svg', 'name': 'YouTube', 'tags': ['media']},
      {'file': 'zoom.svg', 'name': 'Zoom', 'tags': ['control']},
      {'file': 'zoom_in.svg', 'name': 'Zoom In', 'tags': ['control']},
      {'file': 'zoom_out.svg', 'name': 'Zoom Out', 'tags': ['control']},
      
      // Unicode 기반 딩벳들
      {'file': '↩.svg', 'name': 'Undo', 'tags': ['control']},
      {'file': '↪.svg', 'name': 'Redo', 'tags': ['control']},
      {'file': '⇧.svg', 'name': 'Arrow Up', 'tags': ['control']},
      {'file': '▷.svg', 'name': 'Arrow Right', 'tags': ['control']},
      {'file': '◁.svg', 'name': 'Arrow Left', 'tags': ['control']},
      
      // Unicode 기호들 (파일명이 Unicode인 것들)
      {'file': '󰄅.svg', 'name': 'Symbol 1', 'tags': ['symbol']},
      {'file': '󰄖.svg', 'name': 'Symbol 2', 'tags': ['symbol']},
      {'file': '󰄗.svg', 'name': 'Symbol 3', 'tags': ['symbol']},
      {'file': '󰄘.svg', 'name': 'Symbol 4', 'tags': ['symbol']},
      {'file': '󰄙.svg', 'name': 'Symbol 5', 'tags': ['symbol']},
      {'file': '󰄚.svg', 'name': 'Symbol 6', 'tags': ['symbol']},
      {'file': '󰄛.svg', 'name': 'Symbol 7', 'tags': ['symbol']},
      {'file': '󰄜.svg', 'name': 'Symbol 8', 'tags': ['symbol']},
      {'file': '󰄝.svg', 'name': 'Symbol 9', 'tags': ['symbol']},
      {'file': '󰄞.svg', 'name': 'Symbol 10', 'tags': ['symbol']},
      {'file': '󰄟.svg', 'name': 'Symbol 11', 'tags': ['symbol']},
      {'file': '󰄠.svg', 'name': 'Symbol 12', 'tags': ['symbol']},
      {'file': '󰅻.svg', 'name': 'Symbol 13', 'tags': ['symbol']},
      {'file': '󰆚.svg', 'name': 'Symbol 14', 'tags': ['symbol']},
      {'file': '󰆛.svg', 'name': 'Symbol 15', 'tags': ['symbol']},
      {'file': '󰆜.svg', 'name': 'Symbol 16', 'tags': ['symbol']},
      {'file': '󰆝.svg', 'name': 'Symbol 17', 'tags': ['symbol']},
      {'file': '󰆻.svg', 'name': 'Symbol 18', 'tags': ['symbol']},
      {'file': '󰆼.svg', 'name': 'Symbol 19', 'tags': ['symbol']},
      {'file': '󰆽.svg', 'name': 'Symbol 20', 'tags': ['symbol']},
      {'file': '󰆾.svg', 'name': 'Symbol 21', 'tags': ['symbol']},
    ];
    
    // 딩벳 데이터를 Dingbat 객체로 변환
    for (final data in dingbatData) {
      final fileName = data['file'] as String;
      final name = data['name'] as String;
      final tags = List<String>.from(data['tags'] as List);
      
      // 파일명에서 확장자 제거하여 ID 생성
      final id = fileName.replaceAll('.svg', '');
      
      // asset 경로 생성
      final assetPath = 'assets/dingbats/$fileName';
      
      // Unicode 추출 (파일명이 Unicode인 경우)
      String unicode = '';
      if (fileName.startsWith('uni')) {
        // uni2661.svg -> ♥
        final code = fileName.replaceAll('uni', '').replaceAll('.svg', '');
        unicode = String.fromCharCode(int.parse(code, radix: 16));
      } else if (fileName.length == 1 && fileName != '⇧' && fileName != '▷' && fileName != '◁' && fileName != '↩' && fileName != '↪') {
        unicode = fileName;
      } else {
        // 기본 Unicode 설정
        unicode = '🔹';
      }
      
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