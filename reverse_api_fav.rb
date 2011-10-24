# -*- coding:utf-8 -*-

miquire :mui, 'skin'
miquire :addon, 'addon'
miquire :addon, 'settings'

Module.new do
  
  plugin = Plugin::create(:reverse_api_Tofav)
  
  main = Gtk::TimeLine.new()
  service = nil
  
  querybox = Gtk::Entry.new()
  querycont = Gtk::VBox.new(false, 0)
  searchbtn = Gtk::Button.new('ふぁぼ候補')
  
  searchbtn.signal_connect('clicked'){ |elm|
    favnum = 10
    #ファイルから読み込んでみるよ
    begin
      text = []
      open("../plugin/reverse_favnum.txt") do |file|
        file.each do |read|
          text << read.chomp!
        end
      end
      favnum = text[1] #ふぁぼ数の設定
    rescue
      #読み込みが失敗したら1〜10秒の遅延で10個だけふぁぼるよ
    end
    
    main.clear
    #テキストボックスが空なら何もしないよ
    if querybox.text.size > 0 then
      screen_name = querybox.text
      user = User.findbyidname("#{screen_name}", true)
      user[:id] if user
      service.call_api(:user_timeline, :user_id => user[:id],
                       :no_auto_since_id => true,
                       :count => favnum.to_i){ |res|
        Delayer.new{
          main.add(res)
        }
        res.reverse_each do |mes|
          unless mes.favorite? || mes.retweet?
            @threadFav = SerialThreadGroup.new
            @threadFav.new{
              #ふぁぼふぁぼするよ
              mes.favorite(true)
            }
          end
        end
      }
    end
  }
  
  querycont.closeup(Gtk::HBox.new(false, 0).pack_start(querybox).closeup(searchbtn))
  
  plugin.add_event(:boot){ |s|
    service = s
    container = Gtk::VBox.new(false, 0).pack_start(querycont, false).pack_start(main, true)
    Plugin.call(:mui_tab_regist, container, 'Api_ToFav(reverse)', MUI::Skin.get("etc.png"))
    #同梱のtarget.pngをskin/data
    #に置いた時は上をコメントアウトしてこちらをお使いください
    #Plugin.call(:mui_tab_regist, container, 'Api_ToFav(reverse)', MUI::Skin.get("target_reverse.png"))
    
  }
  
end
