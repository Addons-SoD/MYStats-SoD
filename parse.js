const db=require('./db.json');
let jisu={}
let jingzhun={}

db.items.forEach(item=>{
    if(item.stats[15]>0){
        console.log('急速',item.name);
        jisu[item.id]=item.stats[15]
    }
    if(item.stats[22]>0){
        console.log('精准',item.name);
        jisu[item.id]=item.stats[22]
    }
})