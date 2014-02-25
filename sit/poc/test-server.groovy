@Grab('org.codehaus.groovy:groovy-xmlrpc:0.8')

import groovy.net.xmlrpc.*
import java.net.ServerSocket

def XMLRPCServer server = new XMLRPCServer()

server.echo = {
	file = new File("/tmp")
	return ["mierda":"para ti"]
	println "server.echo invoked"
}

server.dos = {
	def file = newFile("hola")
	println "server.dos invoked"
	println file
}

def serverSocket = new ServerSocket(15000)   // Open a server socket on a free port
println "server listening - localhost:15000"
server.startServer(serverSocket) 
