**********************************************************************************************************************************
*						                                                                                 *
*						                                                                                 *
*                                                    LOGSTASH EXAMPLE USE		                                         *
*						                                                                                 *
*						                                                                                 *
**********************************************************************************************************************************

1. Start daemon
	# /etc/init.d/logstash start

2. Check daemon status
	# /etc/init.d/logstash status

3. Use telnet to sent messages:
	# telnet localhost 5000

4. Send this syslog example lines:

Dec 23 12:11:43 louis postfix/smtpd[31499]: connect from unknown[95.75.93.154]
Dec 23 14:42:56 louis named[16000]: client 199.48.164.7#64817: query (cache) 'amsterdamboothuren.com/MX/IN' denied
Dec 23 14:30:01 louis CRON[619]: (www-data) CMD (php /usr/share/cacti/site/poller.php >/dev/null 2>/var/log/cacti/poller-error.log)
Dec 22 18:28:06 louis rsyslogd: [origin software="rsyslogd" swVersion="4.2.0" x-pid="2253" x-info="http://www.rsyslog.com"] rsyslogd was HUPed, type 'lightweight'.

5. Check file /var/log/logstash/example.out (something similar to lines below will be write):

{"message":"Dec 23 12:11:43 louis postfix/smtpd[31499]: connect from
unknown[95.75.93.154]\r","@version":"1","@timestamp":"2014-12-23T11:11:43.000Z","host":"127.0.0.1:58850","type":"syslog","syslog_timestamp":"Dec
23
12:11:43","syslog_hostname":"louis","syslog_program":"postfix/smtpd","syslog_pid":"31499","syslog_message":"connect
from unknown[95.75.93.154]\r","received_at":"2014-09-12 10:07:27
UTC","received_from":"127.0.0.1:58850","syslog_severity_code":5,"syslog_facility_code":1,"syslog_facility":"user-level","syslog_severity":"notice"}
{"message":"Dec 23 14:42:56 louis named[16000]: client 199.48.164.7#64817:
query (cache) 'amsterdamboothuren.com/MX/IN'
denied\r","@version":"1","@timestamp":"2014-12-23T13:42:56.000Z","host":"127.0.0.1:58850","type":"syslog","syslog_timestamp":"Dec
23
14:42:56","syslog_hostname":"louis","syslog_program":"named","syslog_pid":"16000","syslog_message":"client
199.48.164.7#64817: query (cache) 'amsterdamboothuren.com/MX/IN'
denied\r","received_at":"2014-09-12 10:07:27
UTC","received_from":"127.0.0.1:58850","syslog_severity_code":5,"syslog_facility_code":1,"syslog_facility":"user-level","syslog_severity":"notice"}
{"message":"Dec 23 14:30:01 louis CRON[619]: (www-data) CMD (php
/usr/share/cacti/site/poller.php >/dev/null
2>/var/log/cacti/poller-error.log)\r","@version":"1","@timestamp":"2014-12-23T13:30:01.000Z","host":"127.0.0.1:58850","type":"syslog","syslog_timestamp":"Dec
23
14:30:01","syslog_hostname":"louis","syslog_program":"CRON","syslog_pid":"619","syslog_message":"(www-data)
CMD (php /usr/share/cacti/site/poller.php >/dev/null
2>/var/log/cacti/poller-error.log)\r","received_at":"2014-09-12 10:07:27
UTC","received_from":"127.0.0.1:58850","syslog_severity_code":5,"syslog_facility_code":1,"syslog_facility":"user-level","syslog_severity":"notice"}
{"message":"Dec 22 18:28:06 louis rsyslogd: [origin software=\"rsyslogd\"
swVersion=\"4.2.0\" x-pid=\"2253\" x-info=\"http://www.rsyslog.com\"] rsyslogd
was HUPed, type
'lightweight'.\r","@version":"1","@timestamp":"2014-12-22T17:28:06.000Z","host":"127.0.0.1:58850","type":"syslog","syslog_timestamp":"Dec
22
18:28:06","syslog_hostname":"louis","syslog_program":"rsyslogd","syslog_message":"[origin
software=\"rsyslogd\" swVersion=\"4.2.0\" x-pid=\"2253\"
x-info=\"http://www.rsyslog.com\"] rsyslogd was HUPed, type
'lightweight'.\r","received_at":"2014-09-12 10:07:29
UTC","received_from":"127.0.0.1:58850","syslog_severity_code":5,"syslog_facility_code":1,"syslog_facility":"user-level","syslog_severity":"notice"}


