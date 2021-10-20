#!/bin/bash
#https://www.ietf.org/rfc/rfc5545.txt
#time format: 20211021T090000
start_time=$1
end_time=$2
until_time=$3
interval_days=$4

echo BEGIN:VCALENDAR
echo VERSION:2.0
echo CALSCALE:GREGORIAN
echo METHOD:PUBLISH
echo X-WR-CALNAME:吃药
echo X-WR-TIMEZONE:Asia/Shanghai
echo BEGIN:VEVENT
echo "UID:`cat /proc/sys/kernel/random/uuid`@test.com"
echo DTSTAMP:`date +%Y%m%dT%H%M%S`
echo SUMMARY:吃药
echo STATUS:CONFIRMED
echo DTSTART:${start_time}
echo DTEND:${end_time}
echo -e "RRULE:FREQ=DAILY;INTERVAL=${interval_days};UNTIL=${until_time}"
echo BEGIN:VALARM
echo TRIGGER:-PT5M
echo DURATION:PT30M
echo ACTION:DISPLAY
echo DESCRIPTION:你该吃药了
echo END:VALARM
echo END:VEVENT
echo END:VCALENDAR
