# frozen_string_literal: true

require "bcdice/game_system/Cthulhu7th"

module BCDice
  module GameSystem
    class PulpCthulhu < Cthulhu7th
      # ゲームシステムの識別子
      ID = 'PulpCthulhu'

      # ゲームシステム名
      NAME = 'パルプ・クトゥルフ'

      # ゲームシステム名の読みがな
      SORT_KEY = 'はるふくとうるふ'

      # ダイスボットの使い方
      HELP_MESSAGE = <<~INFO_MESSAGE_TEXT
        ※私家翻訳のため、用語・ルールの詳細については原本を参照願います。
        ※コマンドは入力内容の前方一致で検出しています。
        ・判定　CC(x)<=（目標値）
        　x：ボーナス・ペナルティダイス (2～－2)。省略可。
        　目標値が無くても1D100は表示される。
        　ファンブル／失敗／
        　成功／ハード成功／イクストリーム成功／クリティカル を自動判定。
        例）CC<=30　CC(2)<=50　CC(-1)<=75 CC-1<=50 CC1<=65 CC

        ・組み合わせ判定　(CBR(x,y))
        　目標値 x と y で％ロールを行い、成否を判定。
        　例）CBR(50,20)

        ・自動火器の射撃判定　FAR(w,x,y,z,d)
        　w：弾丸の数(1～100）、x：技能値（1～100）、y：故障ナンバー、
        　z：ボーナス・ペナルティダイス(-2～2)。省略可。
        　d：指定難易度で連射を終える（レギュラー：r,ハード：h,イクストリーム：e）。省略可。
        　命中数と貫通数、残弾数のみ算出。ダメージ算出はありません。
        例）FAR(25,70,98)　FAR(50,80,98,-1)　far(30,70,99,1,R)
        　　far(25,88,96,2,h)　FaR(40,77,100,,e)

        ・各種表
        　【狂気関連】
        　・狂気の発作（リアルタイム）（Bouts of Madness Real Time）　BMR
        　・狂気の発作（サマリー）（Bouts of Madness Summary）　BMS
        　・恐怖症（Sample Phobias）表　PH／マニア（Sample Manias）表　MA
        　・狂気のタレント（Insane Talents）表　IT
        　【魔術関連】
        　・プッシュ時のキャスティング・ロールの失敗（Failed Casting Effects）表　FCE
      INFO_MESSAGE_TEXT

      register_prefix('CC', 'CBR', 'FAR', 'BMR', 'BMS', 'FCE', 'PH', 'MA', 'IT')

      def eval_game_system_specific_command(command)
        case command
        when /^CC/i
          return skill_roll(command)
        when /^CBR/i
          return combine_roll(command)
        when /^FAR/i
          return getFullAutoResult(command)
        when /^BMR/i # 狂気の発作（リアルタイム）
          return roll_bmr_table()
        when /^BMS/i # 狂気の発作（サマリー）
          return roll_bms_table()
        when /^FCE/i # キャスティング・ロールのプッシュに失敗した場合
          return roll_1d20_table("キャスティング・ロール失敗表", FAILED_CASTING_EFFECTS_TABLE)
        when /^PH/i # 恐怖症表
          return roll_1d100_table("恐怖症表", PHOBIAS_TABLE)
        when /^MA/i # マニア表
          return roll_1d100_table("マニア表", MANIAS_TABLE)
        when /^IT/i # 狂気のタレント表
          return roll_1d20_table("狂気のタレント表", INSANE_TALENTS_TABLE)
        else
          return nil
        end
      end

      private

      def roll_1d20_table(table_name, table)
        total_n = @randomizer.roll_once(20)
        index = total_n - 1

        text = table[index]

        return "#{table_name}(#{total_n}) ＞ #{text}"
      end

      # 表一式
      # 即時の恐怖症表
      def roll_bmr_table()
        total_n = @randomizer.roll_once(10)
        text = MADNESS_REAL_TIME_TABLE[total_n - 1]

        time_n = @randomizer.roll_once(10)

        return "狂気の発作（リアルタイム）(#{total_n}) ＞ #{text}(1D10＞#{time_n}ラウンド)"
      end

      MADNESS_REAL_TIME_TABLE = [
        '健忘症：ヒーローは自分自身がヒーローである考えをやめ、1D10ラウンドの間パルプのタレントを失う。',
        '狂った計画：1D10ラウンドの間ヒーローは不合理的または非効率的な計画を考えつく。その計画は敵を有利にするものかもしれないし、ヒーローの仲間に対して危険を高めるものかもしれない。',
        '怒り：頭に血が上り1D10ラウンドの間、周囲の人間、味方、敵問わず暴力と破壊を振りまく。',
        'おごり高ぶる：1D10ラウンドの間ヒーローは威張り散らし、自らの計画を大声で叫ぶように強制される。「私と私の盟友達がこの巣穴に潜むグール達を一掃する！！　だがしかし、その前に一言言わせてもらいたい」',
        'リラックス：ヒーローが目の前の驚異が気にするほどの物でないと思い1D10ラウンドの間その場に座り込む。彼は葉巻を吸ったり、スキットルで乾杯するのに時間を使うかもしれない。',
        'パニックになって逃亡する:1台のみの車に乗り、例え仲間を置き去りにしていくことになっても、ヒーローは手段さえあれば可能な限り遠くへ行こうとします。1D10ラウンドの間、逃げ続ける。',
        '注目を集めたがる：ヒーローは1D10ラウンドの間注目を集めようとする。恐らく無謀な事を行うことだろう。',
        'アルター・エゴ（もう一人の僕！）：ヒーローは完全な変化を受け、1D10ラウンドの間、完全に別の人格に入れ替わる。入れ替わった人格はヒーローの性格と真逆のものだ。そのヒーローが親切であれば、もう１人の自分は不親切だ。一方が利己的であれば、もう１人の自分は利他的となる。もし特定のヒーローが永久的な狂気に陥った場合、キーパーは原因である怪物の自我を生み出すことに使用する事もできる。',
        '恐怖症：ヒーローは新しい恐怖症に陥る。恐怖症表（PHコマンド）をロールするか、キーパーが恐怖症を1つ選ぶ。恐怖症の原因は存在しなくとも、その探索者は次の1D10ラウンドの間、それがそこにあると思い込む。',
        'マニア：ヒーローは新しいマニアに陥る。マニア表（MAコマンド）をロールするか、キーパーがマニアを1つ選ぶ。その探索者は次の1D10ラウンドの間、自分の新しいマニアに没頭しようとする。',
      ].freeze

      # 略式の恐怖表
      def roll_bms_table()
        total_n = @randomizer.roll_once(10)
        text = MADNESS_SUMMARY_TABLE[total_n - 1]

        time_n = @randomizer.roll_once(10)

        return "狂気の発作（サマリー）(#{total_n}) ＞ #{text}(1D10＞#{time_n}時間)"
      end

      MADNESS_SUMMARY_TABLE = [
        '健忘症：ヒーローは自分が誰であるかの記憶を失い、パルプのタレントを失い、自分のいる場所に大きな違和感を覚える。彼らの記憶は時間の経過と共にゆっくりと戻る。彼らのパルプのタレントは危機的な状況でのみ戻る。この場合、危機的状況とは誰かの命が晒されているなどの場合と定義する。誰かの命が脅かされるとヒーローは〈幸運〉ロールをう。成功すればタレントは戻る。失敗すれば1D10ラウンド後にもう一度行うことができる。',
        '盗難：1D10時間後にヒーローは意識を取り戻す。彼は無傷だ。彼が宝物を持っている場合それが盗まれたかどうかを知るために〈幸運〉ロールを行う。価値のあるものは全て自動的に失われる。',
        '暴行：ヒーローは1D10時間後に目覚め、体中が痣や傷だらけであることに気づく。耐久力が半分になる。物は奪われていない。どの様な被害にあったかは、キーパーに委ねられる。',
        '暴力：暴力と破壊衝動をヒーローは爆発させる。1D10時間後にヒーローの意識が戻るとき、彼らが行った行動を覚えているかもしれない。ヒーローが誰に対して暴力を振るったか、誰を殺したかはキーパーに委ねられる。',
        'イデオロギー／信念：ヒーローのイデオロギーと信念、背景を証明しようとする。ヒーローは極端に狂い、実証的なやり方でこれらの１つを証明しようとする。一般的にこのような結果はヒーローが人類を傷つけ、正義という名の誇大妄想を抱く事につながる。',
        '重要な人々：ヒーローの背景情報を見て関係を持つ重要な人々を参照する。（1D10時間以上）ヒーローはその人物に近づき、その人の為に最善を尽くす。',
        '収容：ヒーローは高セキュリティの精神病院または警察の監獄で目を覚ます。彼らはそこで自分が犯した出来事をゆっくりと思い出すかもしれない。',
        'パニック：ヒーローが目覚めると元いた場所から遠く離れた場所にいることに気づく。彼らはエンパイア・ステート・ビルの屋上、ホワイト・ハウスの中、または軍事本部の中心にいるかもしれない。それは注目を集める事になるだろう、何故彼らがその場にいるのかは彼らにもわからない。',
        '恐怖症：ヒーロー新たな恐怖症を獲得する。恐怖症表（PHコマンド）をロールするか、キーパーがどれか1つ選ぶ。探索者は1D10時間後に意識を取り戻し、この新たな恐怖症の対象を避けるためにあらゆる努力をしている。',
        'マニア：ヒーローは新たなマニアを獲得する。マニア表（MAコマンド）をロールするか、キーパーがどれか1つ選ぶ。この狂気の発作の間、探索者はこの新たなマニアに完全に溺れているだろう。これがほかの人々に気づかれるかどうかは、キーパーとプレイヤーに委ねられる。',
      ].freeze

      # キャスティング・ロールのプッシュに失敗した場合
      FAILED_CASTING_EFFECTS_TABLE = [
        '叙事詩的な雷と稲光。',
        '1D6ラウンドの一時的な盲目（成功難易度を変化させる/ペナルティ・ダイスを1つ加える）。',
        'どこかから強い風が吹きつける（幸運ロールに失敗すると紙や本などの軽い持ち物を失う）。',
        '壁や床や窓などから輝く緑の粘体が発生する（0/1D3の正気度喪失）',
        'キーパーが選んだ奇妙な幻覚に襲われる（見たものに適した正気度喪失）',
        'その付近の小動物たちが爆発する（0/1D3の正気度喪失）。',
        '呪文の使い手の髪が真っ白になる。',
        '大きな姿のない悲鳴が聞こえる（0/1の正気度喪失）',
        '1D4ラウンドの間、目から血を流す（成功難易度を変化させる/ペナルティ・ダイスを1つ加える）。',
        '硫黄の臭いがする。',
        '大地が震え、壁に亀裂が入って崩れる。',
        '呪文の使い手の手がしおれて、燃え（どちらの手なのか幸運ロールで決定する）、1D2のHPを失う。（キーパーの裁量で、手が一時的に燃えるか（手を使用する必要がある技能ロールとDEXロールのすべてにペナルティ・ダイスが加わる）、または永久にしおれて黒くなる（DEXと手を使用する必要がある技能のすべてを20ポイント減少する。））',
        '1D6ラウンドの間、血が空から降る。',
        '呪文の使い手は異常に年をとる（+2D10歳と能力値の修正）。',
        '呪文の使い手の皮膚が永久的に半透明になる（その呪文の使い手を見た者は1/1D4の正気度喪失）。',
        '呪文の使い手は1D10のPOWを獲得するが、1D10の正気度も失う。',
        'クトゥルフ神話の怪物が偶然召喚される。',
        'キーパーはランダムに2つの呪文を選び、両方が発動する（呪文の使い手を中心に）。',
        '呪文の使い手と近くの全員が、別の場所に吸い込まれる（キーパーがどこかは決定する）。',
        'クトゥルフ神話の神格が偶然招来される。',
      ].freeze

      # 狂気のタレント表
      INSANE_TALENTS_TABLE = [
        '狂気的筋力：「私は無尽蔵の内なる力の蓄えを引き出す！」1つのSTRロールにボーナス・ダイスを1つ得る。ロールが失敗した場合、何かがうまくいかない。キーパーは、ヒーローが負傷した（1D3+ヒーローのDBのダメージを筋断裂等により受ける）か、働きかけたものが壊れるかを選ぶ。',
        '狂気的敏捷性：「私の手は目で見えるよりも素早く動く！」1つのDEXロールにボーナス・ダイスを1つ得る。ロールに失敗した場合、何かがうまくいかない。キーパーは、ヒーローが負傷した（1D4のダメージを受ける）か、彼らが働きかけていたものを壊してしまう。',
        '狂気的精神力：「私を流れるパワーを感じることができる！」1つのPOWロールにボーナス・ダイスを1つ得る。ロールに失敗した倍、何かがうまくいかない。キーパーは、ヒーローが意識を失うか、達成しようとしていた効果が、意図していた以上にかなり危険になる。',
        '狂気的体力：「歯軋りをしても痛みを感じない！」かなりのダメージを受けたときに、ヒーローはCONロールをすることを選ぶかもしれない。成功すれば、苦痛に耐え、ダメージを半減させる。ロールに失敗した場合は、ロールしたダメージを受け、地面へと倒れ、1D3ラウンド無能力化される。',
        '狂気的外見：「くそ、私がかわい子ちゃんに！」ヒーローは、どういうわけかとても違って見える。これは純粋に表情と姿勢に現れるか、あるいは彼らの服や髪が何か根本的に時間をかけて変わる（服が魔法のように変わるのではなく、彼らが自分で変える）。APPや魅惑や言いくるめなどの彼らの外見によって影響を受けるかもしれないロールにボーナス・ダイスを1つ得る。この効果は短命だが、1つのシーンや会議などの一定の時間内の全ての交流に適応される。『改善された』外見のためにこのボーナス・ダイスを使用し、ロールに失敗した場合、彼らは社会的な不名誉や悪い結果に苦しめられることになる。',
        '狂気的回想力：「私は全てを完全に覚えている！」ヒーローがこれまでに聞いた事実と記憶をすぐに手に入れられる。顔、数字、細部の情報が、情報の洪水の中で彼らの精神に押し寄せてくる。ヒーローが一度聞いたあるいは見たことのありそうな情報を思い出そうとする時の、EDUか知識か技能ロール1つにボーナス・ダイスを1つ得る。ロールに失敗した場合、情報の洪水は多すぎた！1正気度ポイントを失い、1つの狂気の発作に苦しむ。ヒーローがまだ狂気でないのであれば、彼らは今や一時的な狂人となる。',
        '狂気的スピード：「私を見ろ、私は弾丸よりも早いぞ！」1つのチェイスに入った時に、ヒーローは移動率を決めるためのCONロールにボーナス・ダイスを1つ得る。ロールが成功すれば、1移動率が上がる。ロールが極限の成功をした場合には、2上がる。ロールが失敗した場合は、彼らは何かをしくじって、少なくとも1D3回の行動を失う。',
        '狂気的運転手：「今や私を止められるものなど誰もいない！」あるチェイスにおけるヒーローの全ての運転ロールにボーナス・ダイスを1つ得る。運転ロールが失敗した場合、彼らはどういうわけか（キーパーの裁量で）車両のコントロールを失う。',
        '狂気的言語：「いやはや、スワヒリ語の勉強をこれまでしたことはないのですが、これは難しいのでしょうかね？」ヒーローは短期間、全ての現代の言語（あるいは古風なある言語、またはあるクトゥルフ神話の言語）を一時的に理解する。この効果は魔道書を最初に読んだり、会話を行ったり、スピーチを聞けるくらいに十分な長さがある。事実上の技能としては75％だ。新たな言語の使用に技能ロールが必要な場合、その失敗は、ヒーローが1D6日間の間母国語を忘れ、その時に使用された新たな言語が代わりに母国語になるということを意味する。',
        '狂気的精度：「私には当たる気しかしないよ！」ヒーローは彼らの銃が空になるまで、全ての火器ロールにボーナス・ダイスを1つ得る。彼らの射撃がターゲットの1つに当たらないか、弾薬がなくなるまで、ボーナス・ダイスを使い続けることができる。その当たらなかった弾丸は当たって欲しくないものに当たる（味方の1人かすごく価値のある何かに、極限の成功（貫通）をしたかのようにダメージを与える）。',
        '狂気的脅し：「お前、俺が愉快なんだと思うかい？どこが愉快なんだ？」ヒーローは威圧ロールにボーナスを1つ得る。ロールに失敗した場合、彼らは短期間彼らの行動を制御できなくなる。キーパーが何が起こるか（彼らが暴力的に激怒する（会話している人にダメージを与える可能性がある）か、見くびられ恥を受けるか）を決める。',
        '狂気的回避：「蝶のように舞う！」ヒーローは回避ロールに失敗するまで、現在の戦闘シーンにおける全ての回避ロールにボーナス・ダイスを1つ得る。この失敗は、攻撃に自ら突っ込んでいくことを示しており、その場合、攻撃が極限の成功を収めたかのようにダメージを受ける。',
        '狂気的方向感覚：「ついて来て、こっちがそうだよ！」ヒーローのプレイヤーはキーパーに彼らがどこに行きたいのか、あるいは何に向かいたいのかを伝える。キーパーはこれが達成されるであろう方向を示す。ヒーローは幸運ロールをし、ロールに失敗した場合は、彼らは何かしらの種類の罠や危険な遭遇へと直進していく。',
        '狂気的理解：「ああ、今それが分かった！」ヒーローのプレイヤーはプロットに関する質問をすることができる。「なぜ敵が～をしているの？」、「敵は～によって達成しようとしていることは何です？」、「我々が敵の計画を妨害することができる最良の行動は何です？」、「敵の最大の弱点は何です？」などだ。質問はかなり具体的でなければならず、キーパーは正直に答えるべきである。このタレントは一度しか使用できず、使用すれば失われる。',
        '狂気的視界：「光？誰が必要なんだい？」ヒーローは1つの目星ロールにボーナス・ダイスを1つ得る。完全な暗闇の中でさえも、彼らは夕暮れのようにロールすることができる。ロールに失敗した場合、キーパーは、目が敏感になりすぎて痛みが生じる（1D10ラウンドの間事実上に盲目になる）、またはこれから1時間妄想に悩ませられることになるかを決定する。',
        '狂気的聴覚：「みんな静かにして、何かカチカチ音がしない？」ヒーローは、1つの聞き耳ロールにボーナス・ダイスを1つ得る。周囲の騒音や他の音によらずに、彼らはその中で最も静かな音でさえも拾うことができる。キーパーは、何らかの突発的なノイズが1D10分間彼らを聴覚障害にするか、またはこれから1時間聴覚的な妄想にとらわれるかを決定する。',
        '狂気的隠密：「私のこと見えてないんだよね？」ヒーローは1つのステルスロールにボーナス・ダイスを1つ得る。彼らは猫のような優雅さで移動し、丸見えのような場所にさえ隠れようとするかもしれない。ロールが失敗したのであれば、彼らは誤って何かを壊したり、大きな騒ぎを引き起こす。',
        '狂気的獰猛さ：「お前を粉みじんに叩き切ってみせるぜ！」ヒーローは全ての近接攻撃のダメージロールを2回行い、最良の結果を得る。欠点としては、いったん命中すると彼らは止められないことだ！彼らは最後の一撃を与えるまで、攻撃し続ける。これを止めるための方法は2つしかない。彼らが意識不明になるか、誰かが困難難易度の言いくるめか、魅惑か、威圧ロールを彼らに成功させた場合がそうだ（1戦闘ラウンドで、1人の人物のみがこれらの状態のヒーローの1人に試みることができる）。',
        '狂気的技能増強：「あんたは私が狂ってると思うのか？だがあんたに教えることができるぞ！」狂気の副作用として、ヒーローはクトゥルフ神話のいくつかの側面を伴う、彼らの技能の1つ（プレイヤーが選び、キーパーが許可を与えたもの）を強化することができる。これはその技能で達成できることの範囲に影響する。ハーバート・ウェストとクロフォード・ティリンギャーストの両方が、これがどのようにその人物に影響を与えるかについての事前研究の良い候補者となる。',
        '狂気的技能増強：「あんたは私が狂ってると思うのか？だがあんたに教えることができるぞ！」狂気の副作用として、ヒーローはクトゥルフ神話のいくつかの側面を伴う、彼らの技能の1つ（プレイヤーが選び、キーパーが許可を与えたもの）を強化することができる。これはその技能で達成できることの範囲に影響する。ハーバート・ウェストとクロフォード・ティリンギャーストの両方が、これがどのようにその人物に影響を与えるかについての事前研究の良い候補者となる。',
      ].freeze
    end
  end
end
