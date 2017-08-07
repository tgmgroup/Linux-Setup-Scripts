# ================================================================== #
#                   Install Packages - Utilities/PostFix             #
# ================================================================== #
#       PostFix	
#               https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-postfix-as-a-send-only-smtp-server-on-ubuntu-16-04
#               https://coderwall.com/p/lryimq/postfix-silent-install-on-ubuntu	
#               https://www.linode.com/docs/email/postfix/postfix-smtp-debian7
#               http://library.linode.com/email/postfix/gateway-ubuntu-10.04-lucid
#               https://help.ubuntu.com/lts/serverguide/postfix.html
#               https://www.linode.com/docs/email/postfix/configure-postfix-to-send-mail-using-gmail-and-google-apps-on-debian-or-ubuntu
#               http://serverfault.com/questions/510251/postfix-gmail-authentication-required-error
#               https://www.digitalocean.com/community/tutorials/how-to-use-an-spf-record-to-prevent-spoofing-improve-e-mail-reliability
#               http://serverfault.com/questions/768005/restrict-sender-and-recipient-with-postfix
#               http://thinlight.org/2012/03/10/postfix-only-allow-whitelisted-recipient-domains/
#               http://www.linuxmail.info/postfix-restrict-sender-recipient/
#               https://www.linode.com/docs/email/postfix/postfix-smtp-debian7
#               shttps://wiki.centos.org/HowTos/postfix_restrictions


# ================================================================== #
#                   Notes for Gmail                     	     #
# ================================================================== #
#   To make Gmail secure, please set up 2-factor authentication.
#       Link: https://myaccount.google.com/security
#   You will need to generate an app password for PostFix.
#       Link: https://security.google.com/settings/security/apppasswords
#   Gmail may block PostFix. If so, try the following, one at a time.
#       Enable “Less secure apps” access (If no 2FA)
#           Link: https://www.google.com/settings/security/lesssecureapps
#       Disable captcha from new application login attempts
#           Link: https://accounts.google.com/DisplayUnlockCaptcha


# ================================================================== #
#                   Define system specific details in this section   #
# ================================================================== #
#   Necessary Variables:
#       REMOTEEMAIL=
#       REMOTEEMAILISP=
#       REMOTEEMAILPASS=
#       REMOTEEMAILPORT=
#       HOSTNAME=
#       DOMAIN=
#       ADMINEMAIL=
#       USERNAME=
#       CONFIGLOCATION=
#       BACKUPLOCATION=
#


# ================================================================== #
#                   Backup Operations   #
# ================================================================== #
#       Postfix Config
#   sudo cp /etc/postfix/main.cf /etc/postfix/main.cf.bak.default
#   sudo ln -s /etc/postfix/main.cf $CONFIGLOCATION/postfix/main.cf 
#   sudo ln -s /etc/postfix/main.cf.bak.default $BACKUPLOCATION/postfix/main.cf 
#       System Aliases
#   sudo cp /etc/aliases /etc/aliases.bak.default
#   sudo ln -s /etc/aliases $CONFIGLOCATION/aliases 
#   sudo ln -s /etc/aliases.bak.default $BACKUPLOCATION/aliases.bak.default 



# ================================================================== #
#                   Install                                          #
# ================================================================== #
echo
echo
echo "Install PostFix: Install and configure PostFix as email gateway/relay."
echo "      Note: The value you assign as your system's FQDN should"
echo "            have an \"A\" record in DNS pointing to your IPv4 address."


echo "  1. set default configuration to prevent user interaction."
sudo echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections
#sudo echo "postfix postfix/mailname string $REMOTEEMAIL" | debconf-set-selections
#sudo echo "postfix postfix/destinations string $REMOTEEMAIL localhost.localdomain, localhost" | debconf-set-selections
echo "                          		... done"


echo "  2. get packages."
sudo apt install mailutils -y
echo "                          		... done"


echo "  3. backup and set configs."

#       Create PostFix Directories
sudo mkdir -p $BACKUPLOCATION/postfix/
sudo mkdir -p $CONFIGLOCATION/postfix/

#       Backups
sudo cp /etc/postfix/main.cf /etc/postfix/main.cf.bak.default
sudo ln -s /etc/postfix/main.cf $CONFIGLOCATION/postfix/main.cf 
sudo ln -s /etc/postfix/main.cf.bak.default $BACKUPLOCATION/postfix/main.cf 

#       Send-only options
sudo postconf -e 'myhostname=$MAILDOMAIN.$DOMAIN'
#sed -i "s/#inet_interfaces = all/inet_interfaces = loopback-only/g" /etc/postfix/main.cf
sudo ln -s /usr/bin/mail /bin/mail
#sed -i "s|#myorigin = /etc/mailname|myorigin = $MAILDOMAIN.$DOMAIN|g" /etc/postfix/main.cf
echo "                          		... done"


echo "  4. set up PostFix as a remote relay."

#       Login Details
sudo touch /etc/postfix/sasl/sasl_passwd
sudo echo "[$REMOTEEMAILISP]:$REMOTEEMAILPORT $REMOTEEMAIL:$REMOTEEMAILPASS" >> /etc/postfix/sasl/sasl_passwd
sudo postmap /etc/postfix/sasl/sasl_passwd

#       Secure Files
sudo chown root:root /etc/postfix/sasl/sasl_passwd /etc/postfix/sasl/sasl_passwd.db
sudo chmod 0600 /etc/postfix/sasl/sasl_passwd /etc/postfix/sasl/sasl_passwd.db

#       Configure PostFix
sudo postconf -e "relayhost = [$REMOTEEMAILISP]:$REMOTEEMAILPORT"
echo "                          		... done"


echo "  5. enable authentication (SASL, noanonymous,sasl_passwd)."
sudo postconf -e 'smtp_sasl_auth_enable = yes'
sudo postconf -e 'smtp_sasl_security_options = noanonymous'
sudo postconf -e 'smtp_sasl_tls_security_options = noanonymous'
sudo postconf -e 'smtp_sasl_password_maps = hash:/etc/postfix/sasl/sasl_passwd'
echo "                          		... done"


echo "  6. enable STARTTLS encryption with CA certificates." 
sudo sed -i "s/smtpd_use_tls=yes/smtp_use_tls=yes/g" /etc/postfix/main.cf
#sudo postconf -e 'smtp_use_tls = yes'
sudo postconf -e 'smtp_tls_security_level = encrypt'
sudo postconf -e 'smtp_tls_CAfile = /etc/ssl/certs/ca-certificates.crt'
echo "                          		... done"


echo "  7. allow PostFix to send only from and to listed email accounts."
        # Can use domains or email addresses

#       Limit destinations
sudo touch /etc/postfix/recipient_domains
sudo echo "$REMOTEEMAIL allowed" >> /etc/postfix/recipient_domains
sudo echo "$ADMINEMAIL allowed" >> /etc/postfix/recipient_domains
sudo echo "root allowed" >> /etc/postfix/recipient_domains
sudo echo "$USERNAME allowed" >> /etc/postfix/recipient_domains
sudo echo "$DOMAIN allowed" >> /etc/postfix/recipient_domains
sudo postmap /etc/postfix/recipient_domains
sudo chown root:root /etc/postfix/recipient_domains
sudo chmod 0600 /etc/postfix/recipient_domains
sudo postconf -e 'smtpd_recipient_restrictions = permit_mynetworks, permit_sasl_authenticated, reject_unauth_destination, check_recipient_access hash:/etc/postfix/recipient_domains, reject'

#       Limit senders
sudo touch /etc/postfix/restricted_senders
sudo echo "$REMOTEEMAIL allowed" >> /etc/postfix/restricted_senders
sudo echo "$ADMINEMAIL allowed" >> /etc/postfix/restricted_senders
sudo echo "root allowed" >> /etc/postfix/restricted_senders
sudo echo "$USERNAME allowed" >> /etc/postfix/restricted_senders
sudo postmap /etc/postfix/restricted_senders
sudo chown root:root /etc/postfix/restricted_senders
sudo chmod 0600 /etc/postfix/restricted_senders
sudo postconf -e 'smtpd_sender_restrictions =  permit_mynetworks, check_sender_access hash:/etc/postfix/restricted_senders, reject'
echo "                          		... done"


echo "  8. test configuration."
sudo systemctl restart postfix
echo "PostFix works!" | mail -s "Testing PostFix - Setup" -a "From: $REMOTEEMAIL" $ADMINEMAIL
echo "                          		... done"


echo "  9. backup and add aliases."

#       Backup
sudo cp /etc/aliases /etc/aliases.bak.default
sudo ln -s $CONFIGLOCATION/aliases /etc/aliases
sudo ln -s $BACKUPLOCATION/aliases.bak.default /etc/aliases.bak.default

#       Add Aliases
echo "root:			$ADMINEMAIL" >> /etc/aliases
echo "$USERNAME:		$ADMINEMAIL" >> /etc/aliases
sudo newaliases
echo "                          		... done"


echo "  10. test aliases."
echo "root alias works!" | mail -s "Testing PostFix - Mail to root" -a "From: $REMOTEEMAIL" root
echo "$USERNAME alias works!" | mail -s "Testing PostFix - Mail to $USERNAME" -a "From: $REMOTEEMAIL" $USERNAME
echo "                          		... done"


#
echo "---------------------------------------------------------------"

