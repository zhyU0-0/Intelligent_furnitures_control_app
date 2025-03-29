import { Furniture, room } from "../tool/classes"

@Entry
@Component
export struct scene{

  @Link arr_room:room[]
  @State List_scene:string[] = ["睡眠模式","离家模式","娱乐模式"]
  @State is_show:boolean = false
  @State this_scene:string = ''
  @State _height:string = "0%"


  build() {
    Stack(){
      List(){
        ForEach(this.List_scene,(item:string,value)=>{
          ListItem(){
            Row(){
              Text(item)
            }.padding(10).width('100%').height("100%").backgroundColor(Color.White)
            .onClick(()=>{
              this.this_scene = item
              this.is_show = true
              animateTo({duration:200},()=>{
                this._height = "100%"
              })
            })
          }.width("100%").height("20%").padding(10).backgroundColor(value%2?Color.Pink:Color.Orange)
          ListItem().height(10)
        })



      }
      if(this.is_show){
        scenes({
          scene:this.this_scene,
          arr_room:this.arr_room,
          _height:this._height,
          is_show:this.is_show
        })
      }
    }
  }
}

@Component
struct scenes{
  @Link scene:string
  @Link arr_room:room[]
  @Link _height:string
  @Link is_show:boolean
  @State List_f:Furniture[] = []
  aboutToAppear(): void {
    for(let r of this.arr_room){
      for(let f of r.furniture_s){
        if(f.type_id>999&&f.type_id<3000){
          this.List_f.push(f)
        }
      }
    }
  }
  build() {
    Stack(){
      Column(){
        List(){
          ListItem(){
            Row(){
              Text("睡眠模式")
              Button().onClick(()=>{
                this.is_show = false
              })
            }.width("100%").height("20%")

          }
          ForEach(this.List_f,(item:Furniture,value)=>{
            ListItem(){
              Row(){
                Text(item.name)
              }
                .width("100%").height("20%")
            }
          })
        }
      }.width("100%").height(this._height).backgroundColor(Color.White)
    }
  }
}