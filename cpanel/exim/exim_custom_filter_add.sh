#!/bin/bash
echo '########### '$1' TO '$2' ################' >> /etc/cpanel_exim_system_filter_custom
echo 'if first_delivery' >> /etc/cpanel_exim_system_filter_custom
echo '        and ("$h_from:" contains "'$1'")' >> /etc/cpanel_exim_system_filter_custom
echo '        and not ("$h_X-Spam-Checker-Version:" begins "SpamAssassin")' >> /etc/cpanel_exim_system_filter_custom
echo 'then' >> /etc/cpanel_exim_system_filter_custom
echo '        unseen deliver "'$2'"' >> /etc/cpanel_exim_system_filter_custom
echo 'endif' >> /etc/cpanel_exim_system_filter_custom
echo '########### '$1' END '$2' ################' >> /etc/cpanel_exim_system_filter_custom
