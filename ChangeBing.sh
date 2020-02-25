#原项目地址：https://github.com/kkkgo/DSM_Login_BingWallpaper
#Get_BingWallpaper(修改：jadgam 20200225)
#如需收集每日美图去掉下面注释设置保存文件夹路径
#savepath="/volume1/wallpaper"
#在FileStation里面右键文件夹属性可以看到路径
pic=$(wget -t 5 --no-check-certificate -qO- "https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1")
echo $pic|grep -q enddate||exit
link=$(echo https://www.bing.com$(echo $pic|sed 's/.\+"url"[:" ]\+//g'|sed 's/".\+//g'))
date=$(echo $pic|sed 's/.\+enddate[": ]\+//g'|grep -Eo 2[0-9]{7}|head -1)
tmpfile=/tmp/$date"_bing.jpg"
wget -t 5 --no-check-certificate  $link -qO $tmpfile
[ -s $tmpfile ]||exit
#替换桌面背景图片
rm -rf /usr/syno/etc/preference/admin/wallpaper
cp -f $tmpfile /usr/syno/etc/preference/admin/wallpaper &>/dev/null
sed -i s/customize_wallpaper\":false/customize_wallpaper\":true/ /usr/syno/etc/preference/admin/usersettings
#替换登录背景图片
rm -rf /usr/syno/etc/login_background*.jpg
cp -f $tmpfile /usr/syno/etc/login_background.jpg &>/dev/null
cp -f $tmpfile /usr/syno/etc/login_background_hd.jpg &>/dev/null
title=$(echo $pic|sed 's/.\+"title":"//g'|sed 's/".\+//g')
copyright=$(echo $pic|sed 's/.\+"copyright[:" ]\+//g'|sed 's/".\+//g')
word=$(echo $copyright|sed 's/(.\+//g')
if  [ ! -n "$title" ];then
cninfo=$(echo $copyright|sed 's/，/"/g'|sed 's/,/"/g'|sed 's/(/"/g'|sed 's/ //g'|sed 's/\//_/g'|sed 's/)//g')
title=$(echo $cninfo|cut -d'"' -f1)
word=$(echo $cninfo|cut -d'"' -f2)
fi
sed -i /login_background_customize=.*/d /etc/synoinfo.conf
sed -i /login_welcome_title=.*/d /etc/synoinfo.conf
sed -i /login_welcome_msg=.*/d /etc/synoinfo.conf
echo "login_background_customize=\"yes\"">>/etc/synoinfo.conf
echo "login_welcome_title=\"$title\"">>/etc/synoinfo.conf
echo "login_welcome_msg=\"$word\"">>/etc/synoinfo.conf
if (echo $savepath|grep -q '/') then
cp -f $tmpfile $savepath/$date@$title-$word.jpg
fi
rm -rf /tmp/*_bing.jpg
