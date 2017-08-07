# ================================================================== #
#                      Install Packages - Monitoring/Logwatch		 #
# ================================================================== #
#		LogWatch	
#			https://help.ubuntu.com/community/Logwatch
#			http://www.badpenguin.org/configure-logwatch-for-weekly-email-and-html-output-format


# ================================================================== #
#                   Define system specific details in this section   #
# ================================================================== #
#   Necessary Variables:
       ADMINEMAIL=
       HOSTNAME=
       PORTRANGEUPPER=
       CONFIGLOCATION=
       BACKUPLOCATION=
#


# ================================================================== #
#                   Backup Operations   #
# ================================================================== #
    sudo cp /etc/logwatch/conf/logwatch.conf /etc/logwatch/conf/logwatch.conf.bak.default
    sudo cp /etc/logwatch/conf/logfiles/http.conf /etc/logwatch/conf/logfiles/http.conf.bak.default
    sudo ln -s $CONFIGLOCATION/etc/logwatch/conf/logwatch.conf /etc/logwatch/conf/logwatch.conf
    sudo ln -s $CONFIGLOCATION/etc/logwatch/conf/logfiles/http.conf /etc/logwatch/conf/logfiles/http.conf
    sudo ln -s $BACKUPLOCATION/etc/logwatch/conf/logwatch.conf.bak.default /etc/logwatch/conf/logwatch.conf.bak.default
    sudo ln -s $BACKUPLOCATION/etc/logwatch/conf/logfiles/http.conf.bak.default /etc/logwatch/conf/logfiles/http.conf.bak.default



# ================================================================== #
#                   Install                                          #
# ================================================================== #
echo
echo
echo "Install and configure LogWatch for log monitoring."


echo "  1. get packages."
    sudo apt -y install logwatch
    echo "                          		... done"


echo "  2. create directories and backup default configs."

#   Create LogWatch Directories
    sudo mkdir -p $CONFIGLOCATION/etc/logwatch/conf/
    sudo mkdir -p $CONFIGLOCATION/etc/logwatch/conf/logfiles/
    sudo mkdir -p $BACKUPLOCATION/etc/logwatch/conf/
    sudo mkdir -p $BACKUPLOCATION/etc/logwatch/conf/logfiles/

#   Copy default configs
    sudo mkdir -p /var/cache/logwatch
    sudo cp /usr/share/logwatch/default.conf/logwatch.conf /etc/logwatch/conf/
    sudo cp /usr/share/logwatch/default.conf/logfiles/http.conf to /etc/logwatch/conf/logfiles

#   Backup default configs
    sudo cp /etc/logwatch/conf/logwatch.conf /etc/logwatch/conf/logwatch.conf.bak.default
    sudo cp /etc/logwatch/conf/logfiles/http.conf /etc/logwatch/conf/logfiles/http.conf.bak.default
    sudo ln -s $CONFIGLOCATION/etc/logwatch/conf/logwatch.conf /etc/logwatch/conf/logwatch.conf
    sudo ln -s $CONFIGLOCATION/etc/logwatch/conf/logfiles/http.conf /etc/logwatch/conf/logfiles/http.conf
    sudo ln -s $BACKUPLOCATION/etc/logwatch/conf/logwatch.conf.bak.default /etc/logwatch/conf/logwatch.conf.bak.default
    sudo ln -s $BACKUPLOCATION/etc/logwatch/conf/logfiles/http.conf.bak.default /etc/logwatch/conf/logfiles/http.conf.bak.default

    echo "                          		... done"


echo "  3. edit configs (email to $ADMINEMAIL, medium details, html, weekly)."

#   Set Logwatch to send to $ADMINEMAIL"
    sed -i "s/MailTo = root/MailTo = $ADMINEMAIL/g" /etc/logwatch/conf/logwatch.conf

# 	Set Logwatch to send from "Servers @ $HOSTNAME - Logwatch"
    sed -i "s/MailFrom = Logwatch/MailFrom = $REMOTEEMAIL - Logwatch/g" /etc/logwatch/conf/logwatch.conf
    
# 	Set Logwatch to use medium detail level (Low, Medium, High)
    sed -i "s/Detail = Low/Detail = Medium/g" /etc/logwatch/conf/logwatch.conf

# 	Set Logwatch to send as html
    sed -i "s/Format = text/Format = html/g" /etc/logwatch/conf/logwatch.conf

# 	Set Logwatch to send weekly reports
    sed -i "s/Range = yesterday/Range = between -7 days and -1 days/g" /etc/logwatch/conf/logwatch.conf
    mv /etc/cron.daily/00logwatch /etc/cron.weekly/
    
    echo "                          		... done"


#
echo "---------------------------------------------------------------"

