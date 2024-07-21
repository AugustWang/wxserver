-record(country_proto,{post,	%%职位
					   num,		%%个数
					   items_l30,	%%level30专属道具
					   items_l50,	%%level50专属道具
					   items_l70,	%%level70专属道具
					   reward,	%%日常奖励
					   blocktalktimes,%%禁言次数
					   remittimes,	%%赦免次数
					   punishtimes, %%惩罚次数
					   appointtimes, %%任命次数
					   items_useful_time_s	%%专属道具有效时间
					  }).

-record(country_record,{countryid,postinfo,countryinfo,ext}).