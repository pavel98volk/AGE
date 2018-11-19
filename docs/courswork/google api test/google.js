


var locations =[' mountain',' swamp',' castle',' bridge',' forest',' valley',' garden',' fortress',' wasteland',' dungeon',' village',' city',' hill',' space',' lake',' sea ',' river'];
var powers = ['strong',' fire ','claws','agile','cunning','stealth','wise','speak','servants','civilization'];
var alignment = ['good','evil','neutral'];



function findPicture(race,callback=undefined){
    
   
     var searchUrl = "http://en.wikipedia.org/w/api.php?action=query&prop=images&titles="+race+"&format=json&callback=?";
    $.getJSON(searchUrl,function(data){
        // alert(JSON.stringify(data));
        var imarr =data.query.pages[Object.keys(data.query.pages)[0]].images;
        if(imarr.length==0)return;
       
        
        var imagename=(imarr.length>1)?imarr[Math.ceil(imarr.length/2)].title:imarr[0].title;
         
        for (i of imarr){
            if(i.title.match(race)!=null){
                imagename = i.title;
                break;
            }
        } 
        var imagesurl="http://en.wikipedia.org/w/api.php?action=query&titles="+imagename+"&prop=imageinfo&iilimit=5&iiprop=url&format=json&callback=?";
         $.getJSON(imagesurl,function(data){
             var url = data.query.pages[Object.keys(data.query.pages)[0]].imageinfo[0].url; 
             document.getElementById("image").src=url;   
         });
    })
}
function findConnections(race,connections,callback=undefined){  
     document.getElementById("image").src=""; 
   var searchUrl = "http://en.wikipedia.org/w/api.php?action=opensearch&search="+race+"&redirect=resolve&format=json&callback=?";
    $.ajax(searchUrl,{
     type: 'GET',
    url: 'whatever',
    dataType: 'json',
    success: (function(callback){ return function(data) {
    var article = data[3][0].split('/').pop();
   document.getElementById('wikitext').innerHTML="===="+article+"====\n";
    var parseUrl ="http://en.wikipedia.org/w/api.php?action=query&format=json&prop=extracts&titles="+article+"&callback=?"; 
    $.ajax(parseUrl,{
        type: 'GET',
        url: 'whatever',
        dataType: 'json',
        success: (function(callback){ return function(data) { 
            result={};
            for (i in connections){
                let j= JSON.stringify(data).match(RegExp(connections[i],"ig"));
                if(j) j=j.length;
                if(j!=null){
                    document.getElementById('wikitext').innerHTML+=connections[i]+" "+j+'\n';
                    result[connections[i]] = j;
                }
            }
            if(callback) callback(result);
        };})(callback),
    data: {}, 
    });  
};})(callback),
    data: {},
    });                           
}
function findPhrases(race){
//todo
}
                       
function createCreatureSpecs(race){
             findConnections(race,alignment,function(result){
                 var temp=0,tempval="";
                 for(i in result)if(result[i]>temp){temp=result[i];tempval=i;}
                 tempval+=" <h2>"+race+"</h2> ";
                 findConnections(race,powers,(function(finalstring){return function(result){
                    finalstring+="who has ";
                 for(i in result)finalstring+=i+" ";
                     findConnections(race,locations,(function(finalstring){return function(result){
                        finalstring+="and lives within ";
                        var temp=0,tempval="";
                        for(i in result)if(result[i]>temp){temp=result[i];tempval=i;}
                        finalstring+=tempval;  
                        document.getElementById('wikitext').innerHTML=finalstring;
                        findPicture(race);
                };})(finalstring));};})(tempval));});
                             
                             }
