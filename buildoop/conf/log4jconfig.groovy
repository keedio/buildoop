log4j {
    appender.stdout = "org.apache.log4j.ConsoleAppender"
    appender."stdout.layout"="org.apache.log4j.PatternLayout"
    appender.scrlog = "org.apache.log4j.FileAppender"
    appender."scrlog.layout"="org.apache.log4j.TTCCLayout"
    appender."scrlog.file"="build/log/buildoop.log"
 
    rootLogger="debug,scrlog,stdout"
}
