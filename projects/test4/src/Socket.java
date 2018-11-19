import com.google.gson.Gson;

import javax.websocket.OnClose;
import javax.websocket.OnError;
import javax.websocket.OnMessage;
import javax.websocket.OnOpen;
import javax.websocket.Session;
import javax.websocket.server.ServerEndpoint;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;


import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

@ServerEndpoint("/actions")
public class Socket{
    class Pos{
        public float x;
        public float y;
    }
    class Data {
        public Pos hero;
        public Pos[] dots;
    }
    //ObjectMapper mapper = new ObjectMapper();

    @OnOpen
    public void open(Session session) {
        System.out.println("Opened");
    }
    @OnClose
    public void close(Session session) {
    }
    @OnError
    public void onError(Throwable error){
    }
    @OnMessage
    public void handleMessage(String message, Session session) {

        Gson gson =new Gson();
        System.out.println(message);
        String[] mess = message.split("\\|");
        System.out.println(mess[0]);

        switch(mess[0]) {
            case "CHOOSE_DOT" :
                Data dat = gson.fromJson(mess[1], Data.class);
                int i = 0;
                System.out.println("made");
                System.out.println("here is class :" + dat.dots.length);
                for (int j = 1; j < dat.dots.length; j++) {
                    if (((dat.dots[j].x - dat.hero.x) * (dat.dots[j].x - dat.hero.x) + (dat.dots[j].y - dat.hero.y) * (dat.dots[j].y - dat.hero.y)) <
                            ((dat.dots[i].x - dat.hero.x) * (dat.dots[i].x - dat.hero.x) + (dat.dots[i].y - dat.hero.y) * (dat.dots[i].y - dat.hero.y))) {
                        i = j;
                    }
                }
                String res = Integer.toString(i);
                System.out.println("here is  : " + res);
                try {
                    session.getBasicRemote().sendText(res);
                } catch (IOException e) {
                    e.printStackTrace();
                }
                break;
            case "LOAD_MODEL" :
                try {
                    String contents = new String(Files.readAllBytes(Paths.get("manifest.mf")));
                }catch (Exception e){

                }


        }


    }
}
