

import javax.websocket.OnClose;
import javax.websocket.OnError;
import javax.websocket.OnMessage;
import javax.websocket.OnOpen;
import javax.websocket.Session;
import javax.websocket.server.ServerEndpoint;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import java.io.IOException;

@ServerEndpoint("/actions")
public class CustomSocket{
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
        System.out.println("onMessage::From=" + session.getId() + " Message=" + message);
        Gson gson = new Gson();
        System.out.println("hello");
        try {
            gson = new GsonBuilder().create();
        }catch(Exception e){
            System.out.println("wrong");
        }
        System.out.println("Gson created");
        Data dat = new Data();
            /*
            try{
              dat  = mapper.readValue(message, Data.class);
            }catch (Exception e){

            }catch (Throwable e){

            }*/
        gson = new Gson();
        dat =gson.fromJson(message,Data.class);
        int i = 0;
        for(int j = 1;j<dat.dots.length;i++) {
            if ((dat.dots[j].x - dat.hero.x) * (dat.dots[j].x - dat.hero.x) + (dat.dots[j].y - dat.hero.y) * (dat.dots[j].y - dat.hero.y) <
                    (dat.dots[i].x - dat.hero.x) * (dat.dots[i].x - dat.hero.x) + (dat.dots[i].y - dat.hero.y) * (dat.dots[i].y - dat.hero.y)) {
                i = j;
            }
        }
        String res = Integer.toString(i);
        System.out.println("here is  : "+res);
        try{
            session.getBasicRemote().sendText(res);
        } catch (IOException e) {
            e.printStackTrace();
        }

    }
}
