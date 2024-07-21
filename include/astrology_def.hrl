%%5月3日【xiaowu】

-define(CHANGE_POS,[[{1,0},{5,1},{4,5},{3,25},{2,31}],
					[{2,0},{5,1},{4,5},{3,25},{1,31}],
					[{3,0},{5,1},{4,5},{2,25},{1,31}],
					[{4,0},{5,1},{3,5},{2,25},{1,31}],
					[{5,0},{4,1},{3,5},{2,25},{1,31}]]).%%占出星槽概率计算

-define(CHOSE_QUALITY,[[{4,0},{3,0},{2,0},{1,15},{0,47}],
					   [{4,0},{3,0},{2,0},{1,25},{0,37}],
					   [{4,0},{3,0},{0,17},{1,20},{2,25}],
					   [{4,0},{0,7},{1,10},{2,20},{3,25}],
					   [{0,2},{1,5},{2,10},{3,20},{4,25}]]).%%占出星魂品质概率计算

-define(ALL_TID,[[{19000011,1,1200},{19000021,1,1200},{19000031,1,1200},{19000041,1,1200},{19000051,1,1200},{19000061,1,1200},{19000071,1,1200},{19000081,1,1200},{19000091,1,1200},{19000101,1,1200},{19000111,1,1200},{19000121,1,1200}],
				 [{19000012,2,2400},{19000022,2,2400},{19000032,2,2400},{19000042,2,2400},{19000052,2,2400},{19000062,2,2400},{19000072,2,2400},{19000082,2,2400},{19000092,2,2400},{19000102,2,2400},{19000112,2,2400},{19000122,2,2400}],
				 [{19000013,3,4800},{19000023,3,4800},{19000033,3,4800},{19000043,3,4800},{19000053,3,4800},{19000063,3,4800},{19000073,3,4800},{19000083,3,4800},{19000093,3,4800},{19000103,3,4800},{19000113,3,4800},{19000123,3,4800}],
				 [{19000014,4,9600},{19000024,4,9600},{19000034,4,9600},{19000044,4,9600},{19000054,4,9600},{19000064,4,9600},{19000074,4,9600},{19000084,4,9600},{19000094,4,9600},{19000104,4,9600},{19000114,4,9600},{19000124,4,9600}]]).
%%品质对应星魂Id和价值

-define(ALL_EFFECT,[{190000111,[{hpmax,160}]},{190000211,[{meleepower,16}]},{190000311,[{rangepower,16}]},{190000411,[{magicpower,16}]},{190000511,[{meleedefense,16}]},{190000611,[{rangedefense,16}]},{190000711,[{magicdefense,16}]},{190000811,[{hitrate,10}]},{190000911,[{dodge,10}]},{190001011,[{criticalrate,10}]},{190001111,[{criticaldestroyrate,10}]},{190001211,[{toughness,10}]},
					{190000112,[{hpmax,320}]},{190000212,[{meleepower,32}]},{190000312,[{rangepower,32}]},{190000412,[{magicpower,32}]},{190000512,[{meleedefense,32}]},{190000612,[{rangedefense,32}]},{190000712,[{magicdefense,32}]},{190000812,[{hitrate,20}]},{190000912,[{dodge,20}]},{190001012,[{criticalrate,20}]},{190001112,[{criticaldestroyrate,20}]},{190001212,[{toughness,20}]},
					{190000113,[{hpmax,480}]},{190000213,[{meleepower,48}]},{190000313,[{rangepower,48}]},{190000413,[{magicpower,48}]},{190000513,[{meleedefense,48}]},{190000613,[{rangedefense,48}]},{190000713,[{magicdefense,48}]},{190000813,[{hitrate,30}]},{190000913,[{dodge,30}]},{190001013,[{criticalrate,30}]},{190001113,[{criticaldestroyrate,30}]},{190001213,[{toughness,30}]},
					{190000114,[{hpmax,640}]},{190000214,[{meleepower,64}]},{190000314,[{rangepower,64}]},{190000414,[{magicpower,64}]},{190000514,[{meleedefense,64}]},{190000614,[{rangedefense,64}]},{190000714,[{magicdefense,64}]},{190000814,[{hitrate,40}]},{190000914,[{dodge,40}]},{190001014,[{criticalrate,40}]},{190001114,[{criticaldestroyrate,40}]},{190001214,[{toughness,40}]},
					{190000115,[{hpmax,800}]},{190000215,[{meleepower,80}]},{190000315,[{rangepower,80}]},{190000415,[{magicpower,80}]},{190000515,[{meleedefense,80}]},{190000615,[{rangedefense,80}]},{190000715,[{magicdefense,80}]},{190000815,[{hitrate,50}]},{190000915,[{dodge,50}]},{190001015,[{criticalrate,50}]},{190001115,[{criticaldestroyrate,50}]},{190001215,[{toughness,50}]},
					{190000116,[{hpmax,960}]},{190000216,[{meleepower,96}]},{190000316,[{rangepower,96}]},{190000416,[{magicpower,96}]},{190000516,[{meleedefense,96}]},{190000616,[{rangedefense,96}]},{190000716,[{magicdefense,96}]},{190000816,[{hitrate,60}]},{190000916,[{dodge,60}]},{190001016,[{criticalrate,60}]},{190001116,[{criticaldestroyrate,60}]},{190001216,[{toughness,60}]},
					{190000117,[{hpmax,1120}]},{190000217,[{meleepower,112}]},{190000317,[{rangepower,112}]},{190000417,[{magicpower,112}]},{190000517,[{meleedefense,112}]},{190000617,[{rangedefense,112}]},{190000717,[{magicdefense,112}]},{190000817,[{hitrate,70}]},{190000917,[{dodge,70}]},{190001017,[{criticalrate,70}]},{190001117,[{criticaldestroyrate,70}]},{190001217,[{toughness,70}]},
					{190000118,[{hpmax,1280}]},{190000218,[{meleepower,128}]},{190000318,[{rangepower,128}]},{190000418,[{magicpower,128}]},{190000518,[{meleedefense,128}]},{190000618,[{rangedefense,128}]},{190000718,[{magicdefense,128}]},{190000818,[{hitrate,80}]},{190000918,[{dodge,80}]},{190001018,[{criticalrate,80}]},{190001118,[{criticaldestroyrate,80}]},{190001218,[{toughness,80}]},
					{190000119,[{hpmax,1440}]},{190000219,[{meleepower,144}]},{190000319,[{rangepower,144}]},{190000419,[{magicpower,144}]},{190000519,[{meleedefense,144}]},{190000619,[{rangedefense,144}]},{190000719,[{magicdefense,144}]},{190000819,[{hitrate,90}]},{190000919,[{dodge,90}]},{190001019,[{criticalrate,90}]},{190001119,[{criticaldestroyrate,90}]},{190001219,[{toughness,90}]},
					{1900001110,[{hpmax,1600}]},{1900002110,[{meleepower,160}]},{1900003110,[{rangepower,160}]},{1900004110,[{magicpower,160}]},{1900005110,[{meleedefense,160}]},{1900006110,[{rangedefense,160}]},{1900007110,[{magicdefense,160}]},{1900008110,[{hitrate,100}]},{1900009110,[{dodge,100}]},{1900010110,[{criticalrate,100}]},{1900011110,[{criticaldestroyrate,100}]},{1900012110,[{toughness,100}]},
					{190000121,[{hpmax,320}]},{190000221,[{meleepower,32}]},{190000321,[{rangepower,32}]},{190000421,[{magicpower,32}]},{190000521,[{meleedefense,32}]},{190000621,[{rangedefense,32}]},{190000721,[{magicdefense,32}]},{190000821,[{hitrate,20}]},{190000921,[{dodge,20}]},{190001021,[{criticalrate,20}]},{190001121,[{criticaldestroyrate,20}]},{190001221,[{toughness,20}]},
					{190000122,[{hpmax,640}]},{190000222,[{meleepower,64}]},{190000322,[{rangepower,64}]},{190000422,[{magicpower,64}]},{190000522,[{meleedefense,64}]},{190000622,[{rangedefense,64}]},{190000722,[{magicdefense,64}]},{190000822,[{hitrate,40}]},{190000922,[{dodge,40}]},{190001022,[{criticalrate,40}]},{190001122,[{criticaldestroyrate,40}]},{190001222,[{toughness,40}]},
					{190000123,[{hpmax,960}]},{190000223,[{meleepower,96}]},{190000323,[{rangepower,96}]},{190000423,[{magicpower,96}]},{190000523,[{meleedefense,96}]},{190000623,[{rangedefense,96}]},{190000723,[{magicdefense,96}]},{190000823,[{hitrate,60}]},{190000923,[{dodge,60}]},{190001023,[{criticalrate,60}]},{190001123,[{criticaldestroyrate,60}]},{190001223,[{toughness,60}]},
					{190000124,[{hpmax,1280}]},{190000224,[{meleepower,128}]},{190000324,[{rangepower,128}]},{190000424,[{magicpower,128}]},{190000524,[{meleedefense,128}]},{190000624,[{rangedefense,128}]},{190000724,[{magicdefense,128}]},{190000824,[{hitrate,80}]},{190000924,[{dodge,80}]},{190001024,[{criticalrate,80}]},{190001124,[{criticaldestroyrate,80}]},{190001224,[{toughness,80}]},
					{190000125,[{hpmax,1600}]},{190000225,[{meleepower,160}]},{190000325,[{rangepower,160}]},{190000425,[{magicpower,160}]},{190000525,[{meleedefense,160}]},{190000625,[{rangedefense,160}]},{190000725,[{magicdefense,160}]},{190000825,[{hitrate,100}]},{190000925,[{dodge,100}]},{190001025,[{criticalrate,100}]},{190001125,[{criticaldestroyrate,100}]},{190001225,[{toughness,100}]},
					{190000126,[{hpmax,1920}]},{190000226,[{meleepower,192}]},{190000326,[{rangepower,192}]},{190000426,[{magicpower,192}]},{190000526,[{meleedefense,192}]},{190000626,[{rangedefense,192}]},{190000726,[{magicdefense,192}]},{190000826,[{hitrate,120}]},{190000926,[{dodge,120}]},{190001026,[{criticalrate,120}]},{190001126,[{criticaldestroyrate,120}]},{190001226,[{toughness,120}]},
					{190000127,[{hpmax,2240}]},{190000227,[{meleepower,224}]},{190000327,[{rangepower,224}]},{190000427,[{magicpower,224}]},{190000527,[{meleedefense,224}]},{190000627,[{rangedefense,224}]},{190000727,[{magicdefense,224}]},{190000827,[{hitrate,140}]},{190000927,[{dodge,140}]},{190001027,[{criticalrate,140}]},{190001127,[{criticaldestroyrate,140}]},{190001227,[{toughness,140}]},
					{190000128,[{hpmax,2560}]},{190000228,[{meleepower,256}]},{190000328,[{rangepower,256}]},{190000428,[{magicpower,256}]},{190000528,[{meleedefense,256}]},{190000628,[{rangedefense,256}]},{190000728,[{magicdefense,256}]},{190000828,[{hitrate,160}]},{190000928,[{dodge,160}]},{190001028,[{criticalrate,160}]},{190001128,[{criticaldestroyrate,160}]},{190001228,[{toughness,160}]},
					{190000129,[{hpmax,2880}]},{190000229,[{meleepower,288}]},{190000329,[{rangepower,288}]},{190000429,[{magicpower,288}]},{190000529,[{meleedefense,288}]},{190000629,[{rangedefense,288}]},{190000729,[{magicdefense,288}]},{190000829,[{hitrate,180}]},{190000929,[{dodge,180}]},{190001029,[{criticalrate,180}]},{190001129,[{criticaldestroyrate,180}]},{190001229,[{toughness,180}]},
					{1900001210,[{hpmax,3200}]},{1900002210,[{meleepower,320}]},{1900003210,[{rangepower,320}]},{1900004210,[{magicpower,320}]},{1900005210,[{meleedefense,320}]},{1900006210,[{rangedefense,320}]},{1900007210,[{magicdefense,320}]},{1900008210,[{hitrate,200}]},{1900009210,[{dodge,200}]},{1900010210,[{criticalrate,200}]},{1900011210,[{criticaldestroyrate,200}]},{1900012210,[{toughness,200}]},
					{190000131,[{hpmax,480}]},{190000231,[{meleepower,48}]},{190000331,[{rangepower,48}]},{190000431,[{magicpower,48}]},{190000531,[{meleedefense,48}]},{190000631,[{rangedefense,48}]},{190000731,[{magicdefense,48}]},{190000831,[{hitrate,30}]},{190000931,[{dodge,30}]},{190001031,[{criticalrate,30}]},{190001131,[{criticaldestroyrate,30}]},{190001231,[{toughness,30}]},
					{190000132,[{hpmax,960}]},{190000232,[{meleepower,96}]},{190000332,[{rangepower,96}]},{190000432,[{magicpower,96}]},{190000532,[{meleedefense,96}]},{190000632,[{rangedefense,96}]},{190000732,[{magicdefense,96}]},{190000832,[{hitrate,60}]},{190000932,[{dodge,60}]},{190001032,[{criticalrate,60}]},{190001132,[{criticaldestroyrate,60}]},{190001232,[{toughness,60}]},
					{190000133,[{hpmax,1440}]},{190000233,[{meleepower,144}]},{190000333,[{rangepower,144}]},{190000433,[{magicpower,144}]},{190000533,[{meleedefense,144}]},{190000633,[{rangedefense,144}]},{190000733,[{magicdefense,144}]},{190000833,[{hitrate,90}]},{190000933,[{dodge,90}]},{190001033,[{criticalrate,90}]},{190001133,[{criticaldestroyrate,90}]},{190001233,[{toughness,90}]},
					{190000134,[{hpmax,1920}]},{190000234,[{meleepower,192}]},{190000334,[{rangepower,192}]},{190000434,[{magicpower,192}]},{190000534,[{meleedefense,192}]},{190000634,[{rangedefense,192}]},{190000734,[{magicdefense,192}]},{190000834,[{hitrate,120}]},{190000934,[{dodge,120}]},{190001034,[{criticalrate,120}]},{190001134,[{criticaldestroyrate,120}]},{190001234,[{toughness,120}]},
					{190000135,[{hpmax,2400}]},{190000235,[{meleepower,240}]},{190000335,[{rangepower,240}]},{190000435,[{magicpower,240}]},{190000535,[{meleedefense,240}]},{190000635,[{rangedefense,240}]},{190000735,[{magicdefense,240}]},{190000835,[{hitrate,150}]},{190000935,[{dodge,150}]},{190001035,[{criticalrate,150}]},{190001135,[{criticaldestroyrate,150}]},{190001235,[{toughness,150}]},
					{190000136,[{hpmax,2880}]},{190000236,[{meleepower,288}]},{190000336,[{rangepower,288}]},{190000436,[{magicpower,288}]},{190000536,[{meleedefense,288}]},{190000636,[{rangedefense,288}]},{190000736,[{magicdefense,288}]},{190000836,[{hitrate,180}]},{190000936,[{dodge,180}]},{190001036,[{criticalrate,180}]},{190001136,[{criticaldestroyrate,180}]},{190001236,[{toughness,180}]},
					{190000137,[{hpmax,3360}]},{190000237,[{meleepower,336}]},{190000337,[{rangepower,336}]},{190000437,[{magicpower,336}]},{190000537,[{meleedefense,336}]},{190000637,[{rangedefense,336}]},{190000737,[{magicdefense,336}]},{190000837,[{hitrate,210}]},{190000937,[{dodge,210}]},{190001037,[{criticalrate,210}]},{190001137,[{criticaldestroyrate,210}]},{190001237,[{toughness,210}]},
					{190000138,[{hpmax,3840}]},{190000238,[{meleepower,384}]},{190000338,[{rangepower,384}]},{190000438,[{magicpower,384}]},{190000538,[{meleedefense,384}]},{190000638,[{rangedefense,384}]},{190000738,[{magicdefense,384}]},{190000838,[{hitrate,240}]},{190000938,[{dodge,240}]},{190001038,[{criticalrate,240}]},{190001138,[{criticaldestroyrate,240}]},{190001238,[{toughness,240}]},
					{190000139,[{hpmax,4320}]},{190000239,[{meleepower,432}]},{190000339,[{rangepower,432}]},{190000439,[{magicpower,432}]},{190000539,[{meleedefense,432}]},{190000639,[{rangedefense,432}]},{190000739,[{magicdefense,432}]},{190000839,[{hitrate,270}]},{190000939,[{dodge,270}]},{190001039,[{criticalrate,270}]},{190001139,[{criticaldestroyrate,270}]},{190001239,[{toughness,270}]},
					{1900001310,[{hpmax,4800}]},{1900002310,[{meleepower,480}]},{1900003310,[{rangepower,480}]},{1900004310,[{magicpower,480}]},{1900005310,[{meleedefense,480}]},{1900006310,[{rangedefense,480}]},{1900007310,[{magicdefense,480}]},{1900008310,[{hitrate,300}]},{1900009310,[{dodge,300}]},{1900010310,[{criticalrate,300}]},{1900011310,[{criticaldestroyrate,300}]},{1900012310,[{toughness,300}]},
					{190000141,[{hpmax,640}]},{190000241,[{meleepower,64}]},{190000341,[{rangepower,64}]},{190000441,[{magicpower,64}]},{190000541,[{meleedefense,64}]},{190000641,[{rangedefense,64}]},{190000741,[{magicdefense,64}]},{190000841,[{hitrate,40}]},{190000941,[{dodge,40}]},{190001041,[{criticalrate,40}]},{190001141,[{criticaldestroyrate,40}]},{190001241,[{toughness,40}]},
					{190000142,[{hpmax,1280}]},{190000242,[{meleepower,128}]},{190000342,[{rangepower,128}]},{190000442,[{magicpower,128}]},{190000542,[{meleedefense,128}]},{190000642,[{rangedefense,128}]},{190000742,[{magicdefense,128}]},{190000842,[{hitrate,80}]},{190000942,[{dodge,80}]},{190001042,[{criticalrate,80}]},{190001142,[{criticaldestroyrate,80}]},{190001242,[{toughness,80}]},
					{190000143,[{hpmax,1920}]},{190000243,[{meleepower,192}]},{190000343,[{rangepower,192}]},{190000443,[{magicpower,192}]},{190000543,[{meleedefense,192}]},{190000643,[{rangedefense,192}]},{190000743,[{magicdefense,192}]},{190000843,[{hitrate,120}]},{190000943,[{dodge,120}]},{190001043,[{criticalrate,120}]},{190001143,[{criticaldestroyrate,120}]},{190001243,[{toughness,120}]},
					{190000144,[{hpmax,2560}]},{190000244,[{meleepower,256}]},{190000344,[{rangepower,256}]},{190000444,[{magicpower,256}]},{190000544,[{hmeleedefense,256}]},{190000644,[{rangedefense,256}]},{190000744,[{magicdefense,256}]},{190000844,[{hitrate,160}]},{190000944,[{dodge,160}]},{190001044,[{criticalrate,160}]},{190001144,[{criticaldestroyrate,160}]},{190001244,[{toughness,160}]},
					{190000145,[{hpmax,3200}]},{190000245,[{meleepower,320}]},{190000345,[{rangepower,320}]},{190000445,[{magicpower,320}]},{190000545,[{meleedefense,320}]},{190000645,[{rangedefense,320}]},{190000745,[{magicdefense,320}]},{190000845,[{hitrate,200}]},{190000945,[{dodge,200}]},{190001045,[{criticalrate,200}]},{190001145,[{criticaldestroyrate,200}]},{190001245,[{toughness,200}]},
					{190000146,[{hpmax,3840}]},{190000246,[{meleepower,384}]},{190000346,[{rangepower,384}]},{190000446,[{magicpower,384}]},{190000546,[{meleedefense,384}]},{190000646,[{rangedefense,384}]},{190000746,[{magicdefense,384}]},{190000846,[{hitrate,240}]},{190000946,[{dodge,240}]},{190001046,[{criticalrate,240}]},{190001146,[{criticaldestroyrate,240}]},{190001246,[{toughness,240}]},
					{190000147,[{hpmax,4480}]},{190000247,[{meleepower,448}]},{190000347,[{rangepower,448}]},{190000447,[{magicpower,448}]},{190000547,[{meleedefense,448}]},{190000647,[{rangedefense,448}]},{190000747,[{magicdefense,448}]},{190000847,[{hitrate,280}]},{190000947,[{dodge,280}]},{190001047,[{criticalrate,280}]},{190001147,[{criticaldestroyrate,280}]},{190001247,[{toughness,280}]},
					{190000148,[{hpmax,5120}]},{190000248,[{meleepower,512}]},{190000348,[{rangepower,512}]},{190000448,[{magicpower,512}]},{190000548,[{meleedefense,512}]},{190000648,[{rangedefense,512}]},{190000748,[{magicdefense,512}]},{190000848,[{hitrate,320}]},{190000948,[{dodge,320}]},{190001048,[{criticalrate,320}]},{190001148,[{criticaldestroyrate,320}]},{190001248,[{toughness,320}]},
					{190000149,[{hpmax,5760}]},{190000249,[{meleepower,576}]},{190000349,[{rangepower,576}]},{190000449,[{magicpower,576}]},{190000549,[{meleedefense,576}]},{190000649,[{rangedefense,576}]},{190000749,[{magicdefense,576}]},{190000849,[{hitrate,360}]},{190000949,[{dodge,360}]},{190001049,[{criticalrate,360}]},{190001149,[{criticaldestroyrate,360}]},{190001249,[{toughness,360}]},
					{1900001410,[{hpmax,6400}]},{1900002410,[{meleepower,640}]},{1900003410,[{rangepower,640}]},{1900004410,[{magicpower,640}]},{1900005410,[{meleedefense,640}]},{1900006410,[{rangedefense,640}]},{1900007410,[{magicdefense,640}]},{1900008410,[{hitrate,400}]},{1900009410,[{dodge,400}]},{1900010410,[{criticalrate,400}]},{1900011410,[{criticaldestroyrate,400}]},{1900012410,[{toughness,400}]}]).
%星魂影响id对应的影响属性值	

-define(ALL_EXP,[[0,100,400,1200,2700,5100,8700,14100,23700,38100],
				 [0,200,800,2400,5400,10200,17400,28200,47400,76200],
				 [0,300,1200,3600,8100,15300,26100,42300,71100,114300],
				 [0,400,1600,4800,10800,20400,34800,56400,94800,152400]]).%%所有品质和等级所对应的经验值

-define(ALL_SELF_EXP,[10,20,80,640]).%%星魂自身经验值

-define(ALL_OPEN_BODY_STAR,[{50,{13110061,13110060},10,10000},
							{53,{13110061,13110060},30,40000},
							{56,{13110071,13110070},10,90000},
							{59,{13110071,13110070},20,160000},
							{62,{13110071,13110070},30,250000},
							{65,{13110081,13110080},20,360000},
							{68,{13110081,13110080},30,490000},
							{71,{13110081,13110080},40,640000}]).%%开启人物身上星槽条件{所需等级，{绑定物品Id，非绑定物品Id}，所需个数，所需钱币}

-define(ASTROLOGY_SLOT_ERROR,12190).%%占星位置错误
-define(ASTROLOGY_MONEY_NOT_ENOUGH,12191).%%星魂值不足
-define(ASTROLOGY_FACE_FULL,12192).%%占星面板空间已满
-define(NO_STAR_TO_SALL,12193).%%要卖出的星魂不存在
-define(NO_STAR_TO_PACK_UP,12194).%%要拾取的星魂不存在
-define(ASTROLOGY_PACKAGE_FULL,12195).%%占星背包空间已满
-define(STAR_HAVE_LOCKED,12196).%%星魂已经被锁定
-define(BAD_STAR_CAN_NOT_PACK_UP,12197).%% 扫把星不能拾取
-define(ASTROLOGY_PACKAGE_BIGGEST,12198).%%背包已经最大了
-define(STAR_CAN_NOT_MOVE,12199).%%不能移动
-define(STAR_CAN_NOT_MIX,12200).%%不能合成
-define(TODY_ASTROLOGY_MONEY_FULL,12201).%%当日充星魂值次数已满
-define(STAR_NOT_OPEN,12202).%%星魂未激活
-define(SLOT_OPEN_SUCCESS,12203).%%槽位激活成功


-define(STATUS_LOCK,1).%%星魂状态锁定
-define(STATUS_UNLOCK,0).%%星魂状态未锁定


-record(astrology,{roleid,starinfo,money,pos,start_time}).
-record(astrology_package,{roleid,packageinfo,unlocknum}).
-record(astrology_add_role_attribute,{roleid,star_use_info}).
-record(astrology_add_money_time,{roleid,starttime}).