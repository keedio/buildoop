import com.sun.net.httpserver.*
import groovy.json.*

HTTP_SERVER_PORT=8080
println "Create server port " + HTTP_SERVER_PORT
server = HttpServer.create(new InetSocketAddress(HTTP_SERVER_PORT),0);

server.createContext("/", new MyHandler(server:server));
//server.createContext("/kill", new KillHandler(server:server));
server.setExecutor(null); // creates a default executor
println "Starting server"
server.start();

class MyHandler implements HttpHandler {

    def server

    public void handle(HttpExchange exchange) throws IOException {
	println "getRequestMethod:"
	println exchange.getRequestMethod() 
	println "getRequestHeaders:"
	println exchange.getRequestHeaders()
	println "getRequestURI:"
	def fileName = exchange.getRequestURI()
	println fileName 

	def file = new File("." + fileName)
      	def bytearray  = new byte [(int)file.length()]
      	def fis = new FileInputStream(file)
      	def bis = new BufferedInputStream(fis);
      	bis.read(bytearray, 0, bytearray.length);

      	// ok, we are ready to send the response.
      	exchange.sendResponseHeaders(200, file.length());
      	def os = exchange.getResponseBody();
      	os.write(bytearray,0,bytearray.length);
      	os.close()
    }
}

class KillHandler implements HttpHandler {

    def server

    public void handle(HttpExchange exchange) throws IOException {
        exchange.responseHeaders['Content-Type'] = 'application/json'
        def builder = new JsonBuilder()
        builder {
            success true
            msg "Killing server..."
        }
        def response = builder.toString()
        exchange.sendResponseHeaders(200, response.length());
        exchange.getResponseBody().write(response.bytes);
        exchange.close();
        server.stop(3) //max wait 3 second
    }
}
