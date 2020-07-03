# -*- coding: utf-8 -*-
# frozen_string_literal: true

require "diceBot/MeikyuKingdom"
require "utils/table"

class MeikyuKingdomBasic < MeikyuKingdom
  # ゲームシステムの識別子
  ID = 'MeikyuKingdomBasic'

  # ゲームシステム名
  NAME = '迷宮キングダム 基本ルールブック'

  # ゲームシステム名の読みがな
  SORT_KEY = 'めいきゆうきんくたむ きほんるうるふつく'

  # ダイスボットの使い方
  HELP_MESSAGE = <<INFO_MESSAGE_TEXT
・判定　(nMK+m)
　n個のD6を振って大きい物二つだけみて達成値を算出します。修正mも可能です。
　絶対成功と絶対失敗も自動判定します。
・各種表
　・視察表 RT
　・休憩表(〜BT)：才覚休憩表 TBT／魅力休憩表 CBT／探索休憩表 SBT／武勇休憩表 VBT
　・ハプニング表(〜HT)：才覚ハプニング表 THT／魅力ハプニング表 CHT／探索ハプニング表 SHT／武勇ハプニング表 VHT
　・王国災厄表 KDT  ／王国変動表 KCT
　・痛打表 CAT／致命傷表 FWT／戦闘ファンブル表 CFT
　・道中表 TT／交渉表 NT／感情表 ET／相場表 MPT
　・お宝表１／２／３／４／５ T1T／T2T／T3T／T4T／T5T
　・名前表 NAMEx (xは個数)
　・名前表A NAMEA／名前表B NAMEB／エキゾチック名前表 NAMEEX／ファンタジック名前表 NAMEFA
　・アイテム表（〜IT)：武具 WIT／生活 LIT／回復 RIT／探索 SIT／レア武具 RWIT／レア一般 RUIT
　・地名決定表　　　　PNTx (xは個数)
　・迷宮風景表　　　　MLTx (xは個数)
　・王国名決定表１／２／３／４／５ KNT1／KNT2／KNT3／KNT4
　・単語表１／２／３／４　WORD1／WORD2／WORD3／WORD4
　・殊遭遇表 ST／情報収集表 IG
・D66ダイスあり
INFO_MESSAGE_TEXT

  setPrefixes([
    '\d+MK',
    'RT',
    'TBT', 'CBT', 'SBT', 'VBT',
    'THT', 'CHT', 'SHT', 'VHT',
    'KDT', 'KCT',
    'CAT', 'FWT', 'CFT',
    'TT', 'NT', 'ET', 'MPT',
    'T1T', 'T2T', 'T3T', 'T4T', 'T5T',
    'NAME.*',
    'WIT', 'LIT', 'RIT', 'SIT', 'RWIT', 'RUIT',
    'PNT\d*', 'MLT\d*',
    'KNT\d+', 'WORD\d+',
    'SE', 'IG',
  ])

  def initialize
    super
    @sendMode = 2
    @sortType = 1
    @d66Type = 2
  end

  def getKiryokuResult(_total_n, dice_list, _diff)
    num_6 = dice_list.count(6)

    if num_6 == 0
      ""
    else
      " ＆ 《気力》#{num_6}点獲得"
    end
  end

  def rollDiceCommand(command)
    if (output = roll_tables(command, TABLES))
      return output
    end

    super(command)
  end

  # 才覚休憩表（2d6）
  # @override
  def mk_talent_break_table
    get_table_by_2d6([
      "寝付けないので、民と噂話に花を咲かせる。すると、経費削減のアイデアが……。[才覚/9]の判定を行う。成功すると、このセッションの《維持費》を（1D6）MG減少できる。",
      "自分の嫌いなものに追い回される夢を見る。心寂しくなったところに、仲間が様子を見に来てくれた。宮廷の中からキャラクター1人を選ぶ。そのキャラクターへの《好意》+1。",
      "好きなものの夢を見る。鳴呼、もっと……もっと……。好きなもの1つを選ぶ。その好きなものに関する幸せそうなシチュエーションを考え、他のプレイヤーやGMに伝える。その夢が幸せそうだと感じる者がいたら、《気力》+2。",
      "さて一眠りするか……というときに、1人の民が青い顔をして震えている。どうやら、 国に残した家族のことが心配なようだ。[才覚/11]の判定を行う。成功すると、《民の声》+2。",
      "「もう少しだ。頑張ろう」あなたは、あらん限りの力をこめて、仲間に呼びかけた。[才覚/9]の判定を行う。成功すると、宮廷のキャラクターは《気力》を1点ずつ消費できる。消費した《気力》と合計値だけ《民の声》が回復する。",
      "配下や仲間たちに指示を出し、休憩中も休む暇なく働く。くたくたになって、あくびをすると配下がお茶を差し入れてくれた。《民の声》+1。",
      "地図を前にして、今後の冒険について口角泡を飛ばす。意見の対立はあったが、あなたの意見が通った。我々に必要なのは英雄的死亡ではなく、卑劣な生存なのだ。 宮廷の好きなキャラクター1体を選ぶ。そのキャラクターの自分に対する《敵意》を好きなだけ上昇させ、上昇した値だけ《民の声》を回復する。",
      "たまには、わたしが料理してみるか……。【お弁当】か【フルコース】の効果を使用して、食事をとることができる。食事をしたら、（1D6）を振る。奇数だったら思いのほか美味しい出来映え。《民の声》+1。偶数だったら腹にはたまるが二度とごめんという出来映え。宮廷全員のあなたに対する《敵意》+1。",
      "配下の中でも年若い者たちがあなたの周りに群がり、冒険の話を聞かせてくれとせがむ。[才覚/現在の《民の声》の値+3] の判定を行う。成功すれば、《民の声》+（1D6）。失敗すると、次の1クォーターは行動ができない。",
      "迷宮に囚われた哀れな人々を見つける。助けたいのはやまやまだが、食料がやや心配だ。[才覚/9]の判定を行う。成功すると、自分の《配下》+（1D6）人。",
      "「やはりな……」迷宮は予想通り、一筋縄ではいかないようだ。こんなときこそ、準備しておいたアレが役に立つ。自分の修得しているスキル1種を選ぶ。そのスキルを喪失して、そのスキルと同じスキルグループのスキル1種を修得してもよい。この効果は永続する。",
    ])
  end

  # 魅力休憩表（2d6）
  # @override
  def mk_charm_break_table
    get_table_by_2d6([
      "妖精のワイン蔵を発見、酒盛りが始まる。宮廷全員の《気力》+1。[魅カ/9]の判定に失敗すると、酔っ払ったあなたは服を脱ぎはじめる。（1D6）を振る。自分を除く宮廷全員のあなたに対する《感情値》+1、奇数ならその属性が《好意》、偶数なら《敵意》になる。",
      "「実はわたし……むにゃむにゃむにゃ」休憩中、意外な寝言を言ってしまう。自分を除く宮廷全員は、自分に対する《好意》と《敵意》を反転させることができる。",
      "休憩中、冷たい床があなたの体温を奪っていく。あなたは、無意識のうちにぬくもりを求め、体を寄せ合う。あなたに《好意》を持っているキャラクターの数だけ、《気カ》と《HP》が回復する。",
      "こっそり2人で抜け出していい雰囲気に。その部屋の中に、自分と好きなものが同じキャラクターがいれば、そのキャラクター1体を選び、互いに対する《好意》+1。",
      "星の灯りがあなたの顔をロマンチックに照らし出す。その部屋にいる人物の中から好きなキャラクター1人を選び、[魅力/9+そのキャラクターのあなたに対する《好意》]の判定を行う。成功すると、そのキャラクターのあなたに対する《好意》+1。",
      "あいつと目が合う。[魅力/9]の判定を行う。成功したら、自分以外の宮廷の中から、ランダムにキャラクター1体を選ぶ。そのキャラクターから自分に対する《好意》か、自分からそのキャラクターに対する《好意》かのいずれかが1点上昇する。",
      "見張りの途中にうたた寝。目を覚ますと、誰かが毛布をかけてくれていた。ランダムにキャラクターを選ぶ。自分のそのキャラクターに対する《好意》+1。",
      "野営に最適な場所を見つける。たき火を囲みながら、思い思い会話を楽しむ。GMの左隣にいるプレイヤーから順番に、自分のPCが《好意》を持っているキャラクター1体を選ぶ。選ばれたキャラクターは、《気力》+1。誰からも選ばれなかったキャラクターは《気力》-1、宮廷の中からランダムにキャラクター1体を選ぶ。そのキャラクターに対する《敵意》+1。",
      "疲れた体を癒やすため、テントの中で楽な衣装に着替えよう。するとそこに侵入者が……。宮廷からランダムにキャラクターを1人選び（1D6）を振る。奇数ならあなたは大声を出し、宮廷全員のそのキャラクターに対する《敵意》+1。偶数ならそのキャラクターとあなたの互いに対する《好意》+1。",
      "部屋のすみに隠れていた怪物が現れた！ すぐには襲いかかってこないようだが……。[魅力/10]の判定を行う。成功すれば怪物と友好関係を結ぶことができる。自分のレベル以下のモンスター1体を選び、そのモンスターが自分の《配下》になる。失敗すると、モンスターに襲われる。宮廷全員の《HP》が（1D6）点減少する。",
      "ふとした拍子に唇が触れあう★ 好きなキャラクター1体を選ぶ。そのキャラクターの自分以外に対する《好意》を合計し、その値を自分に対する《好意》に加える。その後、そのキャラクターの自分以外に対する《好意》をすべて0にする。",
    ])
  end

  # 探索休憩表（2d6）
  # @override
  def mk_search_break_table
    get_table_by_2d6([
      "一休みする前に道具の手入れ。使い慣れた道具ほど手になじむ。ランダムに自分の装備しているアイテム1つを選ぶ。そのアイテムのレベルが1上昇する。",
      "寝床を探していたら、アルコーブがあり、その奥に宝箱をみつける。[探索/9]の判定を行う。成功すると、好きな素材1種類を選び、それを(1D6)個獲得する。",
      "民が寝静まったあと、あなたも一眠り。するとその夢の中で……。[探索/11]の判定を行う。成功したら、好きな部屋を指定する。その部屋の脅威情報を、GMから教えてもらうことができる。 ",
      "配下が眠りにつき、部屋が静寂に包まれると、隣の部屋から妙な音が聞こえる。この部屋に隣接する好きな部屋1つを選ぶ。[探索/9]の判定に成功すると、その部屋のモンスターの種類と数が分かる。",
      "一休みしようと思ったら、モンスターの墓場を発見！ みんなで捜索だ。好きな素材を1種類選ぶ。宮廷全員の中で、あなたに対する《好意》の合計値だけ、その素材が手に入る。",
      "この部屋はなぜか落ち着く。もしも、その部屋の中にあなたの好きなものがあれば、《気力》を（1D6）点回復することができる。あなたはGMにその部屋に自分の好きなものがないか質問してもよい。",
      "壁に描かれた奇妙な壁画が、あなたを見つめているような気がする……。[探索/9]の判定を行う。成功すると、【エレベータ】を発見する。",
      "白骨化した先客の死体が見つかる。使えそうな装備は、ありがたく頂戴しておこう。[探索/10]の判定を行う。成功したら、コモンアイテムのカテゴリの中から好きなもの1つを選び、その中からランダムに決めたアイテム1個を手に入れる。",
      "星の灯りで地図を眺める。この部屋の構造からすると、この辺りに何かあるはずなんだが……？ [探索/10]の判定に成功すると、この部屋に仕掛けられたイベント型のトラップをすべて発見する。",
      "自然の呼び声。休んでいる間にトイレにいきたくなった……。[探索/10]の判定を行う。成功すると、その部屋に迷宮のほころびを見つける。このセッションの間、この部屋から迷宮の外に帰還することができる。",
      "こ、これは秘密の扉！？ [探索/11]の判定を行う。成功すると、この部屋に隣接する好きな部屋に通路を伸ばすことができる。",
    ])
  end

  # 武勇休憩表（2d6）
  # @override
  def mk_valor_break_table
    get_table_by_2d6([
      "時が満ちるにつれ、闘志が高まる。現在の経過ターン数と等しい値だけ、《気力》が回復する。",
      "もっと……もっと敵と戦いたい。血に飢えた自分を発見する。[武勇/9]の判定を行う。成功すると、《気力》+1、《HP》が（1D6）点回復する。",
      "部屋の片隅にうち捨てられたむごたらしい亡骸を発見する。このマップの支配者の名前が分かっていれば、宮廷全員、このマップの支配者への《敵意》+1できる。",
      "部屋のすみに隠れていた怪物が、休憩中の民に襲いかかる！ あなたは、咄嗟に武器を手にし、怪物たちに躍りかかった！ [武勇/9]の判定を行う。成功すれば怪物を追い払い、《民の声》+1。失敗すると、自分の《配下》-（1D6）人、《民の声》-1。",
      "危ない！ 短剣があなたの横をかすめる。すると、そこにはあなたに躍りかかろうとしていた毒蛇が。もしかして、アイツのことを誤解していたかも……。自分が《敵意》を持っているキャラクター1体を選び、そのキャラクターに対する《好意》+2。",
      "少し見ないうちに、恐るべき実力を身につけている。今のうちに潰しておくか……。あなたの中にドス黒い気持ちがわき上がる。名前を知っているキャラクター1体を選び、そのキャラクターへの《敵意》+1。",
      "ちょっとした行き違いから、軽い口論になってしまう。宮廷の中からランダムにキャラクターを1体選ぶ。そのキャラクターとあなたの互いに対する《敵意》+1。",
      "ライバルの活躍が気になる。宮廷全員の中で、あなたに対する最も高い《敵意》の値と同じだけ《気力》を獲得する。",
      "休むときに休まなければ、いざというときに戦えない。他の仲間にまかせて、しっかりと体を休めることにする。《HP》を（2D6）点回復することができる。",
      "この足跡は……もしや？ 怪物のいた痕跡を発見する。[武勇/10]の判定を行う。成功すると、このゲームで遭遇する予定のまだ種類の分かっていないモンスターを1種類、GMから教えてもらうことができる。",
      "……殺気！ あなたは、毛布をはねのけ、戦闘態勢を整えるよう指示した。「特殊遭遇表」を1回使用し、その後、好きな素材を（1D6）個獲得する。さらに、ランダムにレアアイテム1種を選び、それを手に入れる。",
    ])
  end

  # 才覚ハプニング表（2d6）
  # @override
  def mk_talent_happening_table
    get_table_by_2d6([
      "自分に王国を導くことなど可能なのだろうか……。【お酒】を1個消費することができなければ、このセッションの間、[才覚]-1。",
      "国王の威信が問われる。（2D6）を振り、その値が[《民の声》+宮廷全員の国王に対する《好意》の合計]以上だった場合、《民の声》-（1D6）、さらにもう1度（2D6）を振って、才覚ハプニング表の効果を適用する。",
      "思考に霧の帳が降りる。「散漫2」の変調を受ける。",
      "重大な裏切りを犯してしまう！ あなたに対する《好意》が最も高いキャラクターを1人選ぶ。そのキャラクターのあなたに対する《感情値》を《敵意》に反転させる。",
      "この人についていっていいのだろうか……？ 宮廷全員のあなたに対する《好意》-1(0未満にはならない)。その結果、誰かの《好意》が0になると《民の声》-1。",
      "宮廷のスキャンダルが暴露される！ 宮廷全員のあなたに対する《敵意》の中で、最も高い値と同じだけ《民の声》が減少する。",
      "あなたの失策が近隣で噂になる。近隣の国からランダムに国を1つ選ぶ。その国との関係が1段階悪化する。",
      "王国の経済に破綻の危険が発見される。[生活レベル/9+現在の経過ターン数]の判定を行う。失敗すると、維持費が（1D6）MG上昇する。",
      "この区画一帯の疲労が一層激しくなる。1クォーターが経過する。",
      "逸材の賃上げ要求が始まる。終了フェイズの予算会議のとき、[今回使用した逸材の数×1]MGだけ維持費が上昇する。",
      "今の自分に自信が持てなくなる。生まれ表からランダムにジョブを1つ選び、現在のジョブをそのジョブに変更する。",
    ])
  end

  # 魅力ハプニング表（2d6）
  # @override
  def mk_charm_happening_table
    get_table_by_2d6([
      "民同士のいさかいに心を痛め、頭髪にダメージが！ 【お酒】を1個消費することができなければ、このセッションの間、[魅力]-1。",
      "あなたの何気ない一言が不和の種に……。好きなキャラクター1人選ぶ。そのキャラクターに対する宮廷全員の《敵意》+1。",
      "あなたの美しさに嫉妬した迷宮が、あなたの姿を変える。「呪い3」の変調を受ける。",
      "可愛さあまって憎さ百倍。あなたに対する《好意》が最も高いキャラクターを1人選ぶ。そのキャラクターのあなたに対する《感情値》を《敵意》に反転する。",
      "あなたをめぐって不穏な空気……。宮廷全員のあなたに対する愛情の《好意》を比べ、上から2人を選ぶ。その2人の互いに対する《敵意》+1。",
      "いがみ合う宮廷の面々を見て、民の士気が減少する。宮廷全員のあなたに対する《敵意》の中で、最も高い値と同じだけ、自分の《配下》が減少する。",
      "宮廷に嫉妬の嵐が巻き起こる。宮廷の中で、あなたに対して《好意》を持つキャラクターの数を数える。このセッションの間、行為判定を行うとき、サイコロの目の合計がこの数以下だった場合、絶対失敗となる(2未満にはならない)。",
      "愛想をつかされる。宮廷全員のあなたに対する《好意》-1(0未満にはならない)。",
      "あなたの指揮に疑問を訴える者が……。[魅力/自分の《配下》の値×1]の判定を行う。失敗した場合、[難易度-達成値]人の《配下》が減少する。",
      "あなたの恋人だという異性が現れる！ 宮廷全員のあなたに対する《好意》を比べ、最も高いキャラクターを1人選ぶ。そのキャラクターの[武勇]の値と同じだけ《HP》を減少する。",
      "他人が信用できなくなる。このセッションの間、協調行動を行えなくなる。",
    ])
  end

  # 探索ハプニング表（2d6）
  # @override
  def mk_search_happening_table
    get_table_by_2d6([
      "指の震えが止まらない……。【お酒】を1個消費することができなければ、このセッション中、[探索]-1。",
      "流れ星に直撃。《HP》-（1D6）。",
      "敵の過去を知り、相手に同情してしまう。あなたは、このマップの支配者に対する《好意》+1。このセッションの間、《好意》を持ったキャラクターに対して攻撃を行い、絶対失敗した場合、その《好意》の値だけ《気力》が減少する。",
      "昨日の友は今日の敵。あなたに対する《好意》が最も高いキャラクターを1人選ぶ。そのキャラクターのあなたに対する《感情値》を《敵意》に反転する。",
      "うっかりアイテムを落として壊してしまう。ランダムにアイテムスロットを1つ選ぶ。そのスロットにアイテムが入っていれば、そのアイテムをすべて破壊する。",
      "カーネルが活性化し、トラップが強化される。このセッションの間、トラップを解除するための難易度+1。",
      "友情にヒビが！ 宮廷全員のあなたに対する《敵意》+1。",
      "敵の疲労攻撃！ 宮廷全員は[探索/11]の判定を行う。失敗したキャラクターは（2D6）点のダメージを受ける。",
      "つい出来心から、国費に手を出してしまう。GMは好きなコモンアイテム1つを選ぶ。そのキャラクターはそのアイテムを入手するが、維持費+（1D6）、《民の声》-1。同じ部屋に別のPCがいれば、《希望》1点消費し、[探索/9]の判定に成功すればそれを止めることができる。",
      "封印されていたトラップを作動させてしまう。ランダムに災害系トラップの中から1つ選ぶ。そのトラップが発動する。",
      "あなたを憎む迷宮支配者が、あなたの首に賞金をかけた。このセッションの間、モンスターの攻撃やトラップの目標をランダムに決める場合、その目標は必ずあなたになる(この効果を2人以上が受けた場合、この効果を受けた者の中でランダムに決定する)。",
    ])
  end

  # 武勇ハプニング表（2d6）
  # @override
  def mk_valor_happening_table
    get_table_by_2d6([
      "つい幼児退行を起こしそうになる。【お酒】を1個消費することができなければ、このセッション中、[武勇]-1。",
      "バカな！ 不意打ちか！？ 次に行う戦闘は奇襲扱いとなる。",
      "配下の期待が、あなたの重荷となる。[現在の《民の声》-1D6]点だけ《気力》が減少する。",
      "「あ、危ないッ！」配下があなたをかばう！ 自分の《配下》-（1D6）。",
      "ムカついたので思わず殴る。自分の《敵意》の中で、最も高いキャラクターをランダムに1人選ぶ。そのキャラクターの《HP》が、自分の[武勇]と等しい値だけ減少する。",
      "決闘だッ！ 宮廷全員のあなたに対する《敵意》の中で、最も高い値を選ぶ。その値の分だけ、あなたの《HP》が減少し、《気力》+2。",
      "豚どもめ……。宮廷全員に対する《敵意》+1。",
      "古傷が痛み出す。このセッションの間、戦闘であなたに対する敵の攻撃が成功すると、常に1点余分にダメージを受ける。",
      "不意に絶望と虚無感が襲い、あなたたちの心が折れる。宮廷全員の《気力》-1。",
      "あなたの親の仇を名乗るものたちが現れた。ランダムにセッション中に倒したモンスターの中から1種類を選ぶ。そのモンスター（1D6）体と戦闘を行うこと。",
      "自分の失敗が許せない。このセッションの間、《器》が1点減少したものとして扱う。",
    ])
  end

  # 王国災厄表（2d6）
  # @override
  def mk_kingdom_disaster_table
    get_table_by_2d6([
      "王国の悪い噂が蔓延する。既知の土地にある他国との関係が、すべて1段階悪化する。",
      "自国のモンスターが凶暴化する！ 自国の《モンスターの民》の中からランダムに1種類のモンスターを選ぶ。自国の《民》を[そのモンスターのレベル]人減少する。また、そのモンスターと同じ種類の《モンスターの民》は、すべて王国からいなくなる。",
      "王国に疫病が大流行……。自国に残した《民》を[自国に残した《民》の数×1/10]人減少する。",
      "自国の疲労が進行する。自国の領土のマップ数と等しい値のMGだけ維持費が上昇する。",
      "敵国のテロリズムが横行！ [治安レベル/9]の判定を行う。失敗すると、ランダムに選んだ施設1件が破壊される。",
      "敵国の襲来！ あなたがたの留守を狙って、敵国が同盟を結んで奇襲を行う。[軍事レベル/9]の判定を行う。失敗すると、ランダムに選んだ自国の領土1つを失う。",
      "敵国が陰謀を仕掛けてくる。[文化レベル/9]の判定を行う。失敗すると、ランダムに選んだ逸材1人を失う。",
      "食糧危機が発生！ [生活レベル/9]の判定を行う。失敗すると、自国に残した《民》を[自国に残した《民》×1/5]人減少する。王国にある「肉」の素材1個を消費するたびに、《民》の減少を5人軽減することができる。",
      "王国が何者かに呪われる。このセッションの間、国力を使った行為判定で選んだ(2D6)の目が3以下だと、絶対失敗になる。",
      "極地的な迷宮津波が発生。ランダムに自国の領土のマップ1つを選ぶ。その後、既知の土地の中からランダムに土地1つを選ぶ。その2つの場所を入れ替える。",
      "敵国の勢力が強大化する。GMは、関係が敵対の国すべてについて、その国の領土に接する好きな土地1つを選ぶ。その土地をその国の領土にする。",
    ])
  end

  # 王国変動表(2d6)
  # @override
  def mk_kingdom_change_table
    get_table_by_2d6([
      "列強のプロパガンダが現れる。（1D6）を振り、その目が現在の《民の声》以下で、現在列強の属国になっていたら属国から抜けることができる。上回っていたら、ランダムに列強を1つ選びその属国になる。",
      "冒険の成功を祝う民たちが出迎えてくれる。《民の声》+2。この結果を出したプレイヤー以外の全員は、今回の冒険を振り返り当プレイヤーのPCが《好意》を得るとしたら誰が一番ふさわしいかを協議する。決定したキャラへのPCの《好意》+1",
      "唐突な奇襲。周辺階域の中からランダムに自国の領土を選び[軍事レベル/9]の判定を行う。成功すれば（1D6）MG獲得。失敗すると選ばれた領土の入口から順番に通路を辿り失われる部屋を（[王国レベル+1]D6）個選ぶ。（同じ部屋は2度選べない）。失われた部屋の施設と部屋につながる道が全て破壊される。その部屋からすべての部屋がなくなり、終了フェイズで入口が1個もなければ自国の領土でなくなる。",
      "民の労働の結果が明らかに。[生活レベル/9]の判定に成功すると《予算》が自国の領土のマップ数と同じだけ増える。失敗したら《予算》が同じだけ減る。",
      "あなたの活躍を耳にした者たちがやってくる。シナリオの目的を満たしている場合、関係が良好・同盟の国の数だけ（1D6）を振り、[合計値+治安レベル]人だけ《民》が増える。",
      "王国の子どもたちが宮廷をあなた方を見て成長する。《民》が([王国に残した《民》の数÷10＋治安レベル]D6)人増える。",
      "民は領土を渇望していた。5MGを支払えば、隣接する未知の土地1つを領土にできる。（1D6）を振り、その数だけ通路を引くことができる。通路でつながっていない部屋は自国の領土として扱わない。",
      "街の機能に異変が！？ [治安レベル/9]の判定に成功すると、自国の好きな施設1軒を選び、その施設のレベルを1点上昇する。失敗したら、自国のタイプ：部屋の施設をランダムに1軒選び、破壊する。",
      "王国同士の交流が行われた。[文化レベル/9]の判定に成功すると、生まれ表でランダムにジョブを決めた逸材が1人増え、好きな国1つとの関係を1段階良好にする。失敗すると、自国の逸材1人を選んで失い、ランダムに決めた国1つとの関係が1段階悪化する。",
      "ただ無為に時が過ぎていたわけではない。冒険フェイズで過ごした1ターンにつき予算が1MG増える。",
      "民の意識が大きく揺れる。（1D6）を振り、その目が現在の《民の声》以下だったら、好きな国力を選び基本値が1点上昇する（基本値を3点以上にはできない）。出目が上回っていたら、好きな国力が1点減少する。",
    ])
  end

  # 痛打表（2d6）
  # @override
  def mk_critical_attack_table
    get_table_by_2d6([
      "あなたの攻撃の手応えが、武器に刻まれる。その攻撃に使用した武具アイテムのレベルが1点上昇する。",
      "電光石火の一撃。攻撃の処理が終了した後、もう一度、行動を行うことができる。",
      "凄まじい一撃は、相手の姿形を変えるほどだ。攻撃目標に「呪い4」の変調を与える。",
      "乾坤一擲！ その攻撃のダメージを算出したあと、それをさらに2倍にすることができる。",
      "凄まじい威力で相手を吹き飛ばす。攻撃目標を好きなエリアに移動させる。",
      "会心の一撃！！ ダメージが（1D6）点上昇する。",
      "敵の勢いを利用し、大ダメージ！ ダメージが攻撃目標のレベルと同じ値だけ上昇する。",
      "あと1歩まで追い詰める。ダメージを与える代わりに、攻撃目標の残り《HP》を（1D6）点にすることができる。",
      "狙いが的中！ 敵の技を封じる！ 攻撃目標のスキル1種を選ぶ。その戦闘の間、そのスキルを喪失させる。",
      "怒りの一撃！ ダメージが（2D6）点上昇する。",
      "敵の急所をとらえ、一撃のもとに斬り伏せる。攻撃目標の《HP》を0点にする。",
    ])
  end

  # 致命傷表（2d6）
  # @override
  def mk_fatal_wounds_table
    get_table_by_2d6([
      "圧倒的な攻撃が、急所を貫く。死亡する。",
      "致命的な一撃が、頭をかすめる。[探索/5+受けたダメージ]の判定に成功すると、行動不能になる。判定に失敗すると、死亡する。",
      "昏睡し、体中から血と生命の息吹が失われつつある。行動不能になる。この戦闘が終了するまでに《HP》を1点以上にしないと、そのキャラクターは死亡する。",
      "頭を強くうちつけ、昏睡している。行動不能になる。このクォーターが終了するまでに《HP》を1点以上にしないと、そのキャラクターは死亡する。",
      "重傷を負い、意識を失う。行動不能になる。（1D6）クォーターが経過するまでに《HP》を1点以上にしないと、そのキャラクターは死亡する。",
      "すさまじい一撃に意識を失う。行動不能になる。",
      "偶然、アイテムが衝撃からキミを護る。装備しているアイテムから、ランダムに1つを選ぶ。そのアイテムを破壊し、ダメージを無効にする。もし、破壊できるアイテムを1つも装備していないと行動不能になる。",
      "《民》たちが、その身を犠牲にしてキミを護る。自分の《配下》を（2D6）人減少し、ダメージを無効にする。もし、《配下》が1人もいなければ、行動不能になる。",
      "根性で攻撃を跳ね返す！ [探索/5+受けたダメージ]の判定を行う。成功すると、《HP》が1点になる。失敗すると、行動不能になる。",
      "精神力だけで耐え忍ぶ。[武勇/5+受けたダメージ]の判定を行う。成功すると、《HP》が1点になる。失敗すると、行動不能になる。",
      "幸運なことに、ダメージは避けられる。しかし、ランダムに変調1つを選び、それを受ける。数値がある場合、3になる。",
    ])
  end

  # 戦闘ファンブル表（2d6）
  # @override
  def mk_combat_fumble_table
    get_table_by_2d6([
      "敵に援軍が現れる！ 敵軍の中でもっともレベルの低いモンスターが（1D6）体増える。モンスターがこの結果になった場合、好きなPCの《配下》が（1D6）体上昇する。",
      "敵の士気がおおいに揺らぐ。自軍のキャラクター全員は1マス後退する。",
      "勢いあまって仲間を攻撃！ 自分のいるエリアの中から、ランダムに自軍キャラクター1人を選ぶ。そのキャラクターに使用している武器と同じ威力のダメージを与える。",
      "つい仲間と口論に。自軍の未行動のキャラクターの中からランダムに1人選ぶ。そのキャラクターが行動済みになる。",
      "馬鹿な！ 魔法の効果が！ 自軍のキャラクターが使用したスキルやアイテムの効果で、その戦闘の間持続するものが、全て無効になる。",
      "いてててて。自分を傷つけてしまう。自分に（1D6）点ダメージ。",
      "自分の攻撃の勢いを利用され、相手の反撃を受ける。自分の《HP》を現在の値の半分にする。",
      "おおっと、アイテムを落っことした。自分が装備しているアイテムからランダムに1個を選ぶ。そのアイテムが破壊される。モンスターの場合、自分に（1D6）ダメージ。",
      "激しい戦いに、カーネルが活性化。戦闘系トラップからランダムに1種類を選ぶ。その場に、トラップが配置される。",
      "あなたの攻撃は空をきり、絶望に囚われる。自分と、自分に対して1点以上《好意》を持ったキャラクター全員の《気力》-1 。モンスター側の場合、自分に（1D6）点ダメージ。",
      "あっ！ 武器がすっぽぬけた。攻撃に使用していたアイテムが破壊される。モンスターの場合、自分に（1D6）点ダメージ。さらに、戦場シートにいるキャラクターの中からランダムにキャラクター1体を選ぶ。そのキャラクターの《HP》が1点になる。",
    ])
  end

  # 道中表（2d6）
  # @override
  def mk_travel_table
    get_table_by_2d6([
      "道中の時間が、人間関係に変化をもたらす。全員、好きなキャラクター1人を選ぶ。そのキャラクターに対する《感情値》が1点上昇する。",
      "ん？ 何かの死体が転がっている。好きな素材1種類を選ぶ。宮廷のPC1人は、その素材を（1D6）個手に入れる。",
      "カーネルの異常が発生し、あたりが闇に包まれる。宮廷の中から、ランダムにPC1人を選ぶ。そのPCが【星の欠片】を持っていたら、それが1個破壊される。",
      "迷宮災厄のせいか、道に迷いそうになる。全員、[才覚/9]の判定を行う。[（1D6）-成功したPCの数]クォーターの時間が経過する(0クォーター未満にはならない)。",
      "陰湿なトラップにひっかかる。全員、[探索/9]の判定を行う。失敗したPCは、《HP》を（1D6）点減少する。",
      "迷宮は不気味に静まり返っている……。特に何も起こらなかった。",
      "モンスターの襲撃を受ける。全員、[武勇/9]の判定を行う。失敗したPCは、《HP》を（1D6）点減少する。",
      "恐ろしげな咆哮があたりに響き、すぐに静まり返る。全員、[魅力/9]の判定を行う。失敗したPCは、《配下》が（1D6）人自国に逃走する。",
      "迷宮災厄発生！ 気がつくと自分たちの王国に戻っていた。",
      "を？ 何かが落ちてるぞ。ランダムにコモンアイテム1個を選ぶ。そのアイテムを手に入れる。",
      "ラッキー♪ 1MGを拾った。",
    ])
  end

  # 交渉表（2d6）
  # @override
  def mk_negotiation_table
    get_table_by_2d6([
      "中立的な態度は偽装だった。彼らは油断をついて不意打ちを行う。奇襲扱いで戦闘を行うこと。",
      "交渉は決裂！ 戦闘を行うこと。",
      "交渉は決裂！ 戦闘を行うこと。",
      "「贄をささげれば話を聞こう」モンスターの中でもっともレベルが高いもののレベルと等しい数だけ《配下》を消費すれば、モンスターたちは友好的になる。ただし《民の声》を（1D6）点減少する。《配下》を消費しない場合、戦闘を行うこと。",
      "「……お前の趣味、なに？」好きな単語表1個を選び、（D66）を振る。宮廷の中に、その項目を好きなものにしているPCがいれば、モンスターたちは友好的になる。そうでなければ、戦闘を行うこと。",
      "怪物たちは、物欲しそうにこちらを見ている。「肉」の素材をモンスターの数だけ消費するか、【お弁当】、【フルコース】1個を消費すれば、モンスターたちは友好的になる。消費しなければ、戦闘を行うこと。",
      "怪物たちは、値踏みするようにこちらを見ている。維持費を（1D6）MG上昇させれば、モンスターたちは友好的になる。上昇させなければ、戦闘を行うこと。",
      "「何かいいもんよこせ」モンスターの中でもっともレベルが高いもののレベル以上の価格のアイテムを消費すれば、モンスターたちは友好的になる。レアアイテムは、()内の数字に10を足したものとして考える。それを渡せなければ、戦闘を行うこと。",
      "「面白い話を聞かせろよ」怪物たちは、面白い話を要求してきた。プレイヤーたちは、モンスターたちが興味のありそうな話を聞かせること。GMはその話を聞いて面白いと思えば、宮廷の代表に[魅力/9]の判定を行わせること。成功した場合、モンスターたちは友好的になる。失敗した場合、戦闘を行うこと。",
      "「俺に勝てたら話を聞いてやろう」怪物が一騎打ちを申し込んできた。宮廷の代表は[武勇/モンスターの中で最も高い[武勇]+7]の判定を行う。判定に成功すると、モンスターたちは友好的になる。失敗すると、判定を行った者が《HP》を（1D6）点減少した後、全員で戦闘を行うこと。",
      "運命の出会い。一目見た瞬間、うち解け合った。モンスターたちの宮廷の代表に対する《好意》+1、さらにモンスターたちは友好的になる。",
    ])
  end

  TABLES = {
    'RT' => Table.new(
      '視察表',
      '2D6',
      [
        "神託が下る。苦難がPCを襲うが、それは救いのための試練である。このセッションの間、PCが10点以上のダメージをモンスターから受けるたび《民の声》+1。",
        "長老が迷宮の昔話をしてくれた。この表を使用したPCが判定で失敗したとき、その判定のサイコロを振り直すことができる。この効果は、このセッションの間に1回だけ使用できる。",
        "民は怪物の脅威に怯えている。この表を使用したPCがモンスターの《HP》を0点にすると、《民の声》+2。この効果は、このセッションの間に1回だけ使用できる。",
        "日用品が不足しているという不満を持つ民がいるようだ。このセッションの間、自国に「革」を5個輸送するたび《民の声》+1。",
        "民たちは王国の守りが薄いのではという不安を抱えていた。このセッションの間、自国に「鉄」を5個輸送するたび《民の声》+1。",
        "主婦たちが食糧不足に対する不安を訴えてきた。このセッションの間、自国に「肉」を5個輸送するたび《民の声》+1。",
        "民たちは新しい施設の建設を望んでいる。このセッションの間、自国に「木」を5個輸送するたび《民の声》+1。",
        "武器の備えが乏しいのではないかという不安があるようだ。このセッションの間、自国に「牙」を5個輸送するたび《民の声》+1。",
        "配下にした若者が熱心に未来を語る。この表を使用したPCは《配下》を1人消費して、《特殊配下》を1人増やす。その《特殊配下》に名前をつけ、「生まれ表」でなりたいジョブを決定すること。なりたいジョブに対応した能力値(その《特殊配下》がなりたいジョブの能力値ボーナス欄に書いてある能力値)を使った判定で、このセッションの間に自分が絶対成功すると、その《特殊配下》は、そのジョブの逸材になる。",
        "王国は活気に満ちている。この表を使用したPCは《気力》+1、もう一度王国フェイズに行動することができる。",
        "民たちはワクワクするような冒険譚を求めている！ このセッションのシナリオの目的を達成していたら、終了フェイズの円卓会議の開始時に、（1D6）MGが手に入る。",
      ]
    ),
    'SE' => Table.new(
      '特殊遭遇表',
      '1D6',
      [
        "宙を舞う【グレムリン】が、宮廷の方を物欲しそうに眺めている。宮廷の中で、素材欄に「機械」が含まれているアイテムを持っているPC全員は、[才覚/7+装備している素材欄に「機械」が含まれるアイテムの数]の判定を行う。失敗したPCは、そのアイテムをすべて破壊し、[装備している素材欄に「機械」が含まれるアイテムの数]D6点のダメージを受ける。",
        "迷宮の壁や床の中に隠れた【群狼】が、キミたちを待ち伏せていた！ 【狼牙】にさらされた宮廷全員は、[探索/5+宮廷の人数]の判定を行う。失敗したPCは、自分の《HP》が（1D6）点になる。",
        "部屋を埋め尽くすほど大勢の【小鬼】の群れに遭遇する。【小鬼】たちは瞳を赤くし、我を忘れて襲いかかってくる。宮廷全員は[武勇/5+宮廷の人数]の判定を行う。成功したキャラクターは、「牙」の素材を（1D6）個獲得する。失敗したキャラクターは、[（1D6）+宮廷の平均レベル]点のダメージを受ける。",
        "【鬼婆】の奴隷商人に出会う。鎖につながれた無数の奴隷が、恨めしそうにこちらを見ている。宮廷の代表は、[魅力/7+宮廷の人数]の判定を行う。成功すれば、【鬼婆】から奴隷を購入することができる。《予算》を1MG消費するたびに、（1D6）人の《民》を獲得できる。その場で自由に宮廷の《配下》として編成すること。判定に失敗すると、【鬼婆】は奴隷を差し向け、襲いかかってくる。宮廷全員は[武勇/9]の判定を行う。失敗したPCは[（1D6）+宮廷の平均レベル]点のダメージを受けた上、《配下》-（1D6）。",
        "年若い娘が1人倒れている。宮廷の中で誰か彼女を助ける者がいるなら、（1D6）を振ること。その目が奇数なら、彼女は有能な逸材だった。彼女はお礼を言い、王国に仕えさせてくれという。「生まれ表」でランダムに選んだジョブの逸材になる。偶数なら、彼女は【メデューサ】だった。【石化の視線】が襲いかかる。彼女を助けようとした者は[才覚/7+宮廷の人数]、残りのPCは[才覚/5+宮廷の人数]の判定を行う。失敗した者は、（1D6）点のダメージを受け、「呪い3」の変調を受ける。この判定に宮廷全員が失敗すると宮廷は全滅する。",
        "災厄教の巡礼者の一団に出会う。彼らは、迷宮災厄こそおごり高ぶった人類への罰であり、悔い改めよとその教えを説いた。《配下》を1人以上連れているキャラクターは、[魅力/自分の《配下》の数+5]の判定を行う。失敗したPC1人につき、《民の声》-1。",
      ]
    ),
    'IG' => Table.new(
      '情報収集表',
      '2D6',
      [
        "調査隊は、伝説の財宝の噂を聞きつける。《配下》を（1D6）人消費すると、迷宮マップの中からランダムに部屋を1つ目標に選ぶことができる。冒険フェイズに目標の捜索に成功すると、ランダムに選んだレアアイテム1個を獲得する。",
        "素材のある部屋を見つける。迷宮マップの中からランダムに部屋を1つ目標に選び、好きな素材を1種類選ぶ。冒険フェイズに目標の捜索に成功すると、その素材を[（1D6）+宮廷の平均レベル]個獲得する。",
        "噂に聞いたことのある怪物を発見する。迷宮マップの中からランダムに部屋を1つ目標に選ぶ。その部屋に、レベルが[PCの平均レベル+5]以下の好きなモンスターを1体、中立的なモンスターとして配置することができる。",
        "調査隊は、怪物にまつわる情報を入手した！ 迷宮マップの中から好きな部屋を2つ目標に選ぶ。目標の脅威情報をGMに教えてもらう。",
        "危険な迷宮を調査隊は進む。《配下》を1人消費すると、迷宮マップの中から好きな部屋を1つ目標に選ぶことができる。目標の脅威情報と通路情報をGMに教えてもらう。目標から他の部屋に通路がつながっていない場合、PCは行動済みにならず、もう一度、指揮判定を行うことができる。",
        "入り口にたどりつく。迷宮マップの中から【入り口】のある部屋1つをGMに教えてもらい、その部屋を目標に選ぶ。目標の脅威情報をGMに教えてもらう。その後、《配下》を消費することができる。《配下》を（1D6）人消費すると、PCは行動済みにならず、もう一度、指揮判定を行うことができる。",
        "調査隊は不慮の事故に巻き込まれる。《配下》を1人消費すると、迷宮マップの中から好きな部屋を1つ目標に選ぶことができる。目標の脅威情報と通路情報をGMに教えてもらう。",
        "調査隊は無事、迷宮にたどりつく。迷宮マップの中から好きな部屋を1つ目標に選ぶ。目標の脅威情報と通路情報をGMに教えてもらう。",
        "難民のいる部屋を発見する。迷宮マップの中からランダムに部屋を1つ目標に選ぶ。冒険フェイズに目標の捜索に成功すると、宮廷の1人は《配下》を（1D6）人獲得する。",
        "調査隊は隠し財産がある部屋に接近した！ 迷宮マップの中からランダムに部屋を1つ目標に選ぶ。冒険フェイズに目標の捜索に成功すると（1D6）MGを獲得する。",
        "調査隊の素晴らしい活躍！ 迷宮マップの中から好きな部屋を1つ目標に選ぶ。目標の脅威情報と通路情報をGMに教えてもらう。さらに、「情報収集表」をもう1回使用できる。",
      ]
    )
  }.freeze
end
