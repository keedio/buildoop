@Grab('org.codehaus.groovy:groovy-xmlrpc:0.8')

import groovy.net.xmlrpc.*

def serverProxy = new XMLRPCServerProxy("http://localhost:15000")
println serverProxy.echo("Hello World!")
