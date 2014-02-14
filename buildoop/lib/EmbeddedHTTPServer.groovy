import com.sun.net.httpserver.*
import groovy.json.*

println "Create server port 8000"
HttpServer server = HttpServer.create(new InetSocketAddress(8000),0);
server.createContext("/test", new MyHandler(server:server));
server.createContext("/kill", new KillHandler(server:server));
server.setExecutor(null); // creates a default executor
println "Starting server"
server.start();

class MyHandler implements HttpHandler {

    def server

    public void handle(HttpExchange exchange) throws IOException {
        def requestMethod = exchange.requestMethod
        exchange.responseHeaders['Content-Type'] = 'application/json'
        def builder = new JsonBuilder()
        builder {
            success true
            method requestMethod
        }
        def response = builder.toString()
        exchange.sendResponseHeaders(200, response.length());
        exchange.getResponseBody().write(response.bytes);
        exchange.close();
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
