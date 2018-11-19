

public class ModuleDecision {
	
	
	private String S;
	private String Note_Link_VM [];
	private String Note_Perf_VM [];
	private int Nb_VM;
	private String Etat_VM [];
	// L'utilisation du mot cl� volatile permet, en Java version 5 et sup�rieur, 
    // permet d'�viter le cas o� "Singleton.instance" est non-nul,
    // mais pas encore "r�ellement" instanci�.
    // De Java version 1.2 � 1.4, il est possible d'utiliser la classe ThreadLocal.
    private static volatile ModuleDecision instance = null;

	private ModuleDecision(){
		
		
		 S="";
		 Note_Link_VM = null;
		 Note_Perf_VM = null;
		 Nb_VM = 0;
		 Etat_VM= null;
	}
	
	
	/**
     * M�thode permettant de renvoyer une instance de la classe Singleton
     * @return Retourne l'instance du singleton.
     */
    public final static ModuleDecision getInstance() {
        //Le "Double-Checked Singleton"/"Singleton doublement v�rifi�" permet 
        //d'�viter un appel co�teux � synchronized, 
        //une fois que l'instanciation est faite.
        if (ModuleDecision.instance == null) {
           // Le mot-cl� synchronized sur ce bloc emp�che toute instanciation
           // multiple m�me par diff�rents "threads".
           // Il est TRES important.
           synchronized(ModuleDecision.class) {
             if (ModuleDecision.instance == null) {
            	 ModuleDecision.instance = new ModuleDecision();
             }
           }
        }
        return ModuleDecision.instance;
    }
	
	
	public void setParametres(String S,String[] Note_Link_VM,String[] Note_Perf_VM,int Nb_VM,String[] Etat_VM){
		this.S=S;
		this.Note_Link_VM=Note_Link_VM;
		this.Note_Perf_VM=Note_Perf_VM;
		this.Nb_VM=Nb_VM;
		this.Etat_VM=Etat_VM;
		
	}
	
	
	public void setAlert(String S){
		this.S=S;
	}
	public String getAlert(){
	   return	this.S;
	}
	
	
	
	public Object getParametres(){
		return this;}
	

}
