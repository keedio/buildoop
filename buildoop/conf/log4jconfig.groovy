log4j {
    // log file appender with file rotation.
    appender.scrlog = "org.apache.log4j.FileAppender"
    appender.scrlog = "org.apache.log4j.RollingFileAppender"
    appender."scrlog.MaxFileSize"="1MB"
    appender.'srclog.MaxBackupIndex'="1"
    appender."scrlog.layout"="org.apache.log4j.PatternLayout"
    appender."scrlog.layout.ConversionPattern"="%d %5p %r %c{1}: %m%n"
    appender."scrlog.file"="build/log/buildoop.log"
 
    // root logger level and appender attached.
    rootLogger="trace,scrlog"
}
