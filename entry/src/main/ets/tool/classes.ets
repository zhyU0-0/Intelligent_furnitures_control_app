////////////////////////////************/////////////////////////////////
//房间类
export class room{
  name:string = ''
  furniture_s:Furniture[] = []
  constructor(name:string,fnt:Furniture[]) {
    this.name = name
    this.furniture_s = fnt
  }
  get_lighting(){
    let max = 0
    for(let f of this.furniture_s){
      console.log("room max: "+f.lighting)
      if( f.lighting > max){
        console.log("room max11: "+f.lighting)
        max = f.lighting
      }
    }
    return max
  }
  go_bed(){
    for(let item of this.furniture_s){
      if(item.type_id < 2000&&item.type_id>999){//如果有灯就关掉
        item.close()
      }
    }
  }
  get_up(){
    for(let item of this.furniture_s){
      if(item.type_id < 2000&&item.type_id>999){//如果有灯就关掉
        item.open()
      }
    }
  }
  get_air_condition(){
    for(let item of this.furniture_s){
      if(item.type_id < 4000&&item.type_id>2999) { //如果有灯就关掉
        return item
      }
    }
    return new Furniture("null",0,0)
  }

  ex_air_condition(){
    for(let f of this.furniture_s){
      if(f.type_id>2999&&f.type_id<4000)
      {
        return true
      }else {
        return false
      }

    }
    return false
  }
}


/*export class bedroom extends room{


  //睡觉函数,可以让灯关闭
  go_bed(){
    for(let item of this.furniture_s){
      if(item.type_id<2000&&item.type_id>999){//如果有灯就关掉
        item.close()
      }
    }
  }

}*/
////////////////////////////************/////////////////////////////////


//家居类:
//type=
//00xx:普通家居
//10xx:LED
//20xx:窗帘
//30xx:空调
//40xx:风扇
//50xx:冰箱
//60XX:扫地机器人

export class Furniture {

  name:string = ''
  switch:number = 0
  type_id:number =0
  constructor(name:string,s:number,type:number) {
    this.name = name
    this.switch = s
    this.type_id = type
  }
  //Led
  public lighting:number = 0
  open(){
    this.switch = 1
    if(this.type_id<2000){this.lighting = 5}
  }
  close(){
    this.switch = 0
    if(this.type_id<2000){this.lighting = 0}
  }

  //air_condition
  public temp:number = 25;
  max_t:number = 30
  min_t:number = 17;
  mode:"zd"|"cs"|"zl"|"zr" = "zd";

  dry(){
    //打开除湿模式(>.<)
  }

  a_turnUp(){
    if(this.max_t>this.temp){
      this.temp++
    }
  }
  a_turnDown(){
    if(this.temp<this.min_t){
      this.temp--
    }
  }

}

export class LED extends Furniture{
  lighting:number = 100;
  turnUp(){
    if(this.lighting<100){
      this.lighting++
    }
  }
  turnDown(){
    if(this.lighting<100){
      this.lighting--
    }
  }
}


export class air_condition extends Furniture{





}